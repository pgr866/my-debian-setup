#!/bin/bash
set -e

# Input ISO path
echo "=========================================="
echo " ISO Image Configuration"
echo "=========================================="
read -p "Enter the path to the ISO file (e.g., debian.iso): " ISO_FILE

if [ ! -f "$ISO_FILE" ]; then
  echo "Error: The ISO file does not exist. Exiting..."
  exit 1
fi

# Optional Preseed configuration
echo ""
echo "=========================================="
echo " Preseed Configuration (Optional)"
echo "=========================================="
read -p "Enter the path to preseed.cfg (Leave blank to skip): " PRESEED_FILE

if [ -n "$PRESEED_FILE" ]; then
  if [ ! -f "$PRESEED_FILE" ]; then
    echo "Error: The preseed file does not exist. Exiting..."
    exit 1
  fi
fi

# Input USB path
echo ""
echo "=========================================="
echo " Target Device Configuration"
echo "=========================================="
read -p "Enter the USB partition path (e.g., /dev/sdb1): " TARGET_DEVICE

if [ ! -b "$TARGET_DEVICE" ]; then
  echo "Error: The partition '$TARGET_DEVICE' does not exist. Exiting..."
  exit 1
fi

# Confirmation and Formatting Warning
echo ""
echo "WARNING: All data on '$TARGET_DEVICE' will be COMPLETELY ERASED."
echo "The script will format it to FAT32."
read -p "Are you sure you want to proceed? (Y/n): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Operation canceled."
  exit 0
fi

# Unmounting and Formatting the partition
echo "Preparing $TARGET_DEVICE..."
if mount | grep -q "$TARGET_DEVICE"; then
  echo "Device is mounted. Unmounting via udisksctl..."
  # Using udisksctl unmounts it from the user space safely without hanging
  udisksctl unmount -b "$TARGET_DEVICE" 2>/dev/null
  sleep 1
fi

echo "Formatting $TARGET_DEVICE to FAT32..."
sudo mkfs.vfat -I "$TARGET_DEVICE"

if [ $? -ne 0 ]; then
  echo "Error: Failed to format $TARGET_DEVICE. Exiting..."
  exit 1
fi

# Mount and Copy Process
MOUNT_ISO="/tmp/iso_source"
MOUNT_USB="/tmp/usb_target"

sudo mkdir -p "$MOUNT_ISO"
sudo mkdir -p "$MOUNT_USB"

echo "Checking ISO mount status..."
if ! mountpoint -q "$MOUNT_ISO"; then
  echo "Mounting ISO image..."
  sudo mount -o loop "$ISO_FILE" "$MOUNT_ISO"
else
  echo "ISO image is already mounted, reusing mount point."
fi

echo "Mounting USB device ($TARGET_DEVICE)..."
if ! sudo mount "$TARGET_DEVICE" "$MOUNT_USB" 2>/dev/null; then
  echo "Error: Could not mount $TARGET_DEVICE after formatting."
  sudo umount -l "$MOUNT_ISO" 2>/dev/null
  exit 1
fi

echo "Copying files safely..."
sudo cp -rvL --no-preserve=all "$MOUNT_ISO/." "$MOUNT_USB/" || true

# Copy preseed file and configure GRUB if it was provided
if [ -n "$PRESEED_FILE" ]; then
  echo "Copying preseed file to the root of the USB..."
  # Always named preseed.cfg regardless of source name
  sudo cp -v "$PRESEED_FILE" "$MOUNT_USB/preseed.cfg"
  GRUB_CFG="$MOUNT_USB/boot/grub/grub.cfg"
  if [ -f "$GRUB_CFG" ]; then
    echo "Modifying grub.cfg idempotently..."
    sudo sed -i "/menuentry .*'Graphical install'/,/}/ { /linux/ { /auto=true/! s/$/ auto=true file=\/cdrom\/preseed.cfg/ } }" "$GRUB_CFG"
    sudo sed -i "/menuentry .*'Install'/,/}/ { /linux/ { /auto=true/! s/$/ auto=true file=\/cdrom\/preseed.cfg/ } }" "$GRUB_CFG"
  else
    echo "Warning: grub.cfg not found at $GRUB_CFG"
  fi
fi

echo "------------------------------------------"
echo "Writing data to physical drive (syncing)..."
echo "This step may take several minutes. Please do not unplug the USB."
echo "------------------------------------------"
sync

echo "Unmounting devices safely..."
sudo umount -l "$MOUNT_ISO" 2>/dev/null
sudo umount -l "$MOUNT_USB" 2>/dev/null

sudo rmdir "$MOUNT_ISO" 2>/dev/null || true
sudo rmdir "$MOUNT_USB" 2>/dev/null || true

echo "Process completed successfully. You can now remove your USB."
