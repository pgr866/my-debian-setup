#!/bin/bash
set -e

# Desktop environment to set up: plasma (default) or gnome
# Optional wallpaper from the wallpapers folder, e.g. wallpaper3 (none by default)
# Usage: wget -qO- https://raw.githubusercontent.com/pgr866/my-debian-setup/main/install.sh | bash -s gnome wallpaper3
DESKTOP="${1:-plasma}"
WALLPAPER="$2"
case "$DESKTOP" in
    plasma|gnome) ;;
    *) echo "Unknown desktop '$DESKTOP'. Use: plasma or gnome" >&2; exit 1 ;;
esac

REPO="https://raw.githubusercontent.com/pgr866/my-debian-setup/main"

# Define and create the local binary directory to store user scripts
DIR="$HOME/.local/bin"
mkdir -p "$DIR"
cd "$DIR"

# Download utility and setup scripts, replacing old copies
for script in clear_docker.sh sync_hard_drive.sh update.sh \
    setup_packages.sh "setup_$DESKTOP.sh" setup_nvidia_driver.sh; do
    rm -f "$script"
    wget -O "$script" "$REPO/$script"
done

# Download the chosen wallpaper, if any
if [ -n "$WALLPAPER" ]; then
    mkdir -p "$HOME/.local/share/wallpapers"
    wget -O "$HOME/.local/share/wallpapers/wallpaper.png" "$REPO/wallpapers/$WALLPAPER.png" ||
        { rm -f "$HOME/.local/share/wallpapers/wallpaper.png"; exit 1; }
fi

# Grant execution permissions to all downloaded scripts
chmod +x ./*.sh

# Run the primary configuration and setup scripts
bash setup_packages.sh
bash "setup_$DESKTOP.sh"
bash setup_nvidia_driver.sh

# Append PATH to .bashrc and .zshrc if not already present
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"

# Reboot the system to apply all changes
sudo reboot
