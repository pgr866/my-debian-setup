#!/bin/bash
set -e

# Ask for sudo privileges
sudo -v

# Install wget
sudo apt-get install -y --no-install-recommends wget

# Usage: wget -qO- https://raw.githubusercontent.com/pgr866/my-debian-setup/main/install.sh | bash -s wallpaper.png
# Optional wallpaper: a file in the repository root or a URL (none by default)
WALLPAPER="$1"

REPO="https://raw.githubusercontent.com/pgr866/my-debian-setup/main"

# Define and create the local binary directory to store user scripts
DIR="$HOME/.local/bin"
mkdir -p "$DIR"
cd "$DIR"

# Download utility and setup scripts, replacing old copies
for script in clear_docker.sh sync_hard_drive.sh update.sh \
    setup_packages.sh setup_plasma.sh setup_nvidia_driver.sh; do
    rm -f "$script"
    wget -nv --tries=3 -O "$script" "$REPO/$script"
done

# Download the chosen wallpaper, if any
if [ -n "$WALLPAPER" ]; then
    case "$WALLPAPER" in http://*|https://*) url="$WALLPAPER" ;; *) url="$REPO/$WALLPAPER" ;; esac
    mkdir -p "$HOME/.local/share/wallpapers"
    wget -nv --tries=3 -O "$HOME/.local/share/wallpapers/wallpaper.png" "$url" ||
        { rm -f "$HOME/.local/share/wallpapers/wallpaper.png"; exit 1; }
fi

# Grant execution permissions to all downloaded scripts
chmod +x ./*.sh

# Run the primary configuration and setup scripts
bash setup_plasma.sh
bash setup_packages.sh
bash setup_nvidia_driver.sh

# Append PATH to .bashrc and .zshrc if not already present
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"

# Reboot the system to apply all changes
sudo reboot
