#!/bin/bash
set -e

TITLE="Debian USB Maker"
SCRIPT_DIR=$(dirname "$(realpath "$0")")

if ! command -v whiptail >/dev/null; then
  echo "Error: whiptail is required (sudo apt install whiptail). Exiting..."
  exit 1
fi

# Expand a leading ~ in user-entered paths
expand_path() {
  echo "${1/#\~/$HOME}"
}

# Show paths relative to ~ to keep menu entries short
shorten_path() {
  echo "${1/#$HOME/\~}"
}

# Collapse the column padding of lsblk output
squeeze() {
  awk '{$1=$1; print}'
}

# whiptail draws on the terminal and prints the selection to stdout
wt() {
  whiptail --title "$TITLE" "$@" 3>&1 1>&2 2>&3
}

cancel() {
  echo "Operation canceled."
  exit 0
}

# Show an error dialog, keep it in the terminal output and abort
die() {
  wt --ok-button "Exit" --msgbox "Error: $1" "${2:-10}" 78 || true
  echo "Error: $1"
  exit 1
}

# Always release mounts, temp files and the sudo keep-alive, even if a step fails
cleanup() {
  if [ -n "$SUDO_KEEPALIVE" ]; then
    kill "$SUDO_KEEPALIVE" 2>/dev/null || true
  fi
  if [ -n "$WORK_DIR" ]; then
    local dir
    for dir in "$MOUNT_USB" "$MOUNT_ISO"; do
      if mountpoint -q "$dir"; then
        sudo umount "$dir" >/dev/null 2>&1 || sudo umount -l "$dir" >/dev/null 2>&1 || true
      fi
    done
    rm -f "$ERROR_FILE" "$WARN_FILE"
    if [ -z "$KEEP_LOG" ]; then
      rm -f "$LOG"
    fi
    rmdir "$MOUNT_ISO" "$MOUNT_USB" "$WORK_DIR" 2>/dev/null || true
  fi
}

# ISO image: pick one found nearby or type a path
select_iso() {
  local items=() f choice
  while IFS= read -r f; do
    items+=("$(shorten_path "$f")" "$(stat -c %s "$f" | numfmt --to=iec)")
  done < <({
    find "$PWD" "$SCRIPT_DIR" -maxdepth 1 -type f -name '*.iso' -exec realpath {} +
    find "$HOME" -maxdepth 2 -type f -name '*.iso' -exec realpath {} +
  } 2>/dev/null | sort -u)
  items+=("Other..." "Enter a path manually")

  while true; do
    choice=$(wt --menu "Select the ISO image:" 20 78 10 "${items[@]}") || cancel
    if [ "$choice" = "Other..." ]; then
      choice=$(wt --inputbox "Path to the ISO file:" 10 78) || continue
    fi
    ISO_FILE=$(expand_path "$choice")
    if [ -f "$ISO_FILE" ]; then
      return
    fi
    wt --msgbox "The ISO file '$ISO_FILE' does not exist." 10 78 || true
  done
}

# Preseed (optional): defaults to the first one found
select_preseed() {
  local items=("None" "Manual installation") f choice default="None"
  while IFS= read -r f; do
    items+=("$(shorten_path "$f")" "Automated installation")
    if [ "$default" = "None" ]; then
      default=$(shorten_path "$f")
    fi
  done < <(find "$PWD" "$SCRIPT_DIR" -maxdepth 1 -type f -name '*.cfg' -exec realpath {} + 2>/dev/null | sort -u)
  items+=("Other..." "Enter a path manually")

  while true; do
    choice=$(wt --default-item "$default" --menu "Select a preseed file (optional):" 20 78 10 "${items[@]}") || cancel
    case "$choice" in
      None) PRESEED_FILE=""; return ;;
      Other...) choice=$(wt --inputbox "Path to the preseed file:" 10 78) || continue ;;
    esac
    PRESEED_FILE=$(expand_path "$choice")
    if [ -f "$PRESEED_FILE" ]; then
      return
    fi
    wt --msgbox "The preseed file '$PRESEED_FILE' does not exist." 10 78 || true
  done
}

# Target: only partitions on USB disks are offered
select_target() {
  local items name disk text choice
  while true; do
    items=()
    while read -r name disk; do
      if [ "$(lsblk -dno TRAN "$disk")" = "usb" ]; then
        items+=("$name" "$(lsblk -no SIZE,FSTYPE,LABEL "$name" | squeeze) | $(lsblk -dno MODEL "$disk" | squeeze)")
      fi
    done < <(lsblk -lnpo NAME,PKNAME,TYPE | awk '$3 == "part" { print $1, $2 }')

    if [ ${#items[@]} -eq 0 ]; then
      text="No USB partitions found. Plug in the USB drive and choose Rescan."
    else
      text="Select the USB partition. ALL DATA ON IT WILL BE ERASED."
    fi
    items+=("Rescan" "Refresh the device list")

    choice=$(wt --menu "$text" 20 78 10 "${items[@]}") || cancel
    if [ "$choice" != "Rescan" ]; then
      TARGET_DEVICE=$choice
      return
    fi
  done
}

# Gauge update: percentage followed by up to 3 lines of text (fd 3 is the gauge)
progress() {
  { echo XXX; echo "$1"; printf '%s\n' "${@:2}"; echo XXX; } >&3
}

# Record why the install steps stopped so the main shell can report it
fail() {
  echo "$1" > "$ERROR_FILE"
  exit 1
}

# Bytes the kernel still has to write to disk
pending_bytes() {
  awk '/^(Dirty|Writeback):/ {s += $2} END {print s * 1024}' /proc/meminfo
}

# Copy the ISO contents, moving the gauge from $1 to $2 by bytes copied
copy_files() {
  local start=$1 end=$2 total copied pid
  # Estimate: symlinked files count twice, as cp -L copies them twice
  total=$(sudo find -L "$MOUNT_ISO" -path "$MOUNT_ISO/debian" -prune -o -type f -printf '%s\n' | awk '{s += $1} END {print s + 0}')
  [ "$total" -gt 0 ] || total=1

  # FAT32 has no symlinks, so they are dereferenced (-L). The ISO's
  # self-referencing 'debian -> .' link is skipped to avoid recursion.
  find "$MOUNT_ISO" -mindepth 1 -maxdepth 1 ! \( -type l -name debian \) \
    -exec sudo cp -rvL --no-preserve=all -t "$MOUNT_USB/" {} + &
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    copied=$(du -sb "$MOUNT_USB" 2>/dev/null | cut -f1)
    copied=$(( ${copied:-0} < total ? ${copied:-0} : total ))
    progress $(( start + (end - start) * copied / total )) \
      "Copying files to the USB..." \
      "$(numfmt --to=iec "$copied") of $(numfmt --to=iec "$total")"
    sleep 1
  done
  wait "$pid" || fail "Failed to copy the ISO files to the USB."
}

# Flush cached writes, moving the gauge from $1 to $2 as pending data drains
sync_to_disk() {
  local start=$1 end=$2 initial pending pid
  initial=$(pending_bytes)
  [ "$initial" -gt 0 ] || initial=1

  sync &
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    pending=$(pending_bytes)
    pending=$(( pending < initial ? pending : initial ))
    progress $(( start + (end - start) * (initial - pending) / initial )) \
      "Writing data to physical drive (syncing)..." \
      "This step may take several minutes. Please do not unplug the USB." \
      "$(numfmt --to=iec "$pending") left to write"
    sleep 1
  done
  wait "$pid" || fail "Failed to write the data to the USB."
}

# Runs as the producer of the gauge: progress goes to fd 3, command output to the log
install_steps() {
  exec 3>&1 >>"$LOG" 2>&1

  progress 0 "Preparing $TARGET_DEVICE..."
  if findmnt -rn -S "$TARGET_DEVICE" >/dev/null; then
    progress 1 "Device is mounted. Unmounting via udisksctl..."
    # Using udisksctl unmounts it from the user space safely without hanging
    udisksctl unmount -b "$TARGET_DEVICE" || fail "Failed to unmount $TARGET_DEVICE."
    sleep 1
  fi

  progress 3 "Formatting $TARGET_DEVICE to FAT32..."
  sudo mkfs.vfat -F 32 -I "$TARGET_DEVICE" || fail "Failed to format $TARGET_DEVICE."

  progress 6 "Mounting ISO image..."
  sudo mount -o loop,ro "$ISO_FILE" "$MOUNT_ISO" || fail "Could not mount the ISO image."

  progress 8 "Mounting USB device ($TARGET_DEVICE)..."
  sudo mount "$TARGET_DEVICE" "$MOUNT_USB" || fail "Could not mount $TARGET_DEVICE after formatting."

  copy_files 10 70

  # Copy preseed file and configure GRUB if it was provided
  if [ -n "$PRESEED_FILE" ]; then
    progress 71 "Copying preseed file to the root of the USB..."
    # Always named preseed.cfg regardless of source name
    sudo cp -v "$PRESEED_FILE" "$MOUNT_USB/preseed.cfg" || fail "Failed to copy the preseed file."
    GRUB_CFG="$MOUNT_USB/boot/grub/grub.cfg"
    if [ -f "$GRUB_CFG" ]; then
      progress 72 "Modifying grub.cfg idempotently..."
      sudo sed -i "/menuentry .*'Graphical install'/,/}/ { /linux/ { /auto=true/! s/$/ auto=true file=\/cdrom\/preseed.cfg/ } }" "$GRUB_CFG" ||
        fail "Failed to modify grub.cfg."
      sudo sed -i "/menuentry .*'Install'/,/}/ { /linux/ { /auto=true/! s/$/ auto=true file=\/cdrom\/preseed.cfg/ } }" "$GRUB_CFG" ||
        fail "Failed to modify grub.cfg."
    else
      echo "boot/grub/grub.cfg not found on the USB, the preseed will not load automatically." >> "$WARN_FILE"
    fi
  fi

  sync_to_disk 73 98

  progress 99 "Unmounting devices safely..."
  sudo umount "$MOUNT_USB" || fail "Could not unmount $TARGET_DEVICE. Do not remove the USB yet."

  progress 100 "Done."
  : > "$ERROR_FILE"
}

# Ask for the sudo password up front, before any dialog is shown
echo "Administrator privileges are required to format and mount the USB."
if ! sudo -v; then
  echo "Error: Could not obtain sudo privileges. Exiting..."
  exit 1
fi
# Keep the sudo timestamp fresh so long copies never prompt again
while kill -0 $$ 2>/dev/null && sleep 60; do sudo -n true; done 2>/dev/null &
SUDO_KEEPALIVE=$!
trap cleanup EXIT

select_iso
select_preseed
select_target

if [ ! -b "$TARGET_DEVICE" ]; then
  die "The partition '$TARGET_DEVICE' does not exist."
fi

if [ "$(lsblk -no TYPE "$TARGET_DEVICE")" != "part" ]; then
  die "'$TARGET_DEVICE' is not a partition."
fi

# Refuse anything that is not on a USB disk to avoid wiping internal drives
PARENT_DISK="/dev/$(lsblk -no PKNAME "$TARGET_DEVICE")"
if [ "$(lsblk -dno TRAN "$PARENT_DISK")" != "usb" ]; then
  die "'$TARGET_DEVICE' is not on a USB device."
fi

# Confirmation and Formatting Warning
wt --defaultno --yes-button "Erase" --no-button "Cancel" --yesno \
"ISO:      $ISO_FILE
Preseed:  ${PRESEED_FILE:-none}
Target:   $TARGET_DEVICE
Disk:     $PARENT_DISK ($(lsblk -dno SIZE,MODEL "$PARENT_DISK" | squeeze))

WARNING: All data on '$TARGET_DEVICE' will be COMPLETELY ERASED.
The script will format it to FAT32.

Are you sure you want to proceed?" 16 78 || cancel

WORK_DIR=$(mktemp -d --tmpdir debian_usb_maker.XXXXXX)
MOUNT_ISO="$WORK_DIR/iso"
MOUNT_USB="$WORK_DIR/usb"
LOG="$WORK_DIR/install.log"
ERROR_FILE="$WORK_DIR/error"
WARN_FILE="$WORK_DIR/warnings"
mkdir "$MOUNT_ISO" "$MOUNT_USB"

# install_steps clears this file only when every step succeeded
echo "The process was interrupted unexpectedly." > "$ERROR_FILE"
install_steps | wt --gauge "Starting...
 
 " 11 78 0 || true

if [ -s "$ERROR_FILE" ]; then
  KEEP_LOG=1
  die "$(<"$ERROR_FILE")

Last lines of the log ($LOG):
$(tail -n 5 "$LOG")" 20
fi

MESSAGE="Process completed successfully. You can now remove your USB."
if [ -s "$WARN_FILE" ]; then
  MESSAGE+="

Warning: $(<"$WARN_FILE")"
fi
wt --ok-button "Exit" --msgbox "$MESSAGE" 12 78 || true
echo "$MESSAGE"
