#!/bin/bash
set -e

# Usage: wget -qO- https://raw.githubusercontent.com/pgr866/my-debian-setup/main/install.sh | bash -s [WALLPAPER]
# WALLPAPER (optional): a file in the repository root or a URL. No wallpaper is set by default.

# Optional wallpaper argument
WALLPAPER="$1"

# Ask for sudo privileges
sudo -v

# Install wget for downloading files
sudo apt-get install -y --no-install-recommends wget ca-certificates

# Base URL of the repository raw files
REPO="https://raw.githubusercontent.com/pgr866/my-debian-setup/main"

# Define and create the local binary directory to store user scripts
DIR="$HOME/.local/bin"
mkdir -p "$DIR"
cd "$DIR"

# Append PATH to .bashrc and .zshrc if not already present
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
if command -v zsh >/dev/null; then grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"; fi

# Download utility and setup scripts, replacing old copies
for script in clear_docker.sh sync_hard_drive.sh update.sh \
    setup_packages.sh setup_plasma.sh setup_nvidia_driver.sh; do
    rm -f "$script"
    wget -nv --tries=3 -O "$script" "$REPO/$script"
done

# Grant execution permissions to all downloaded scripts
chmod +x ./*.sh

# Run the primary configuration and setup scripts
bash setup_plasma.sh "$WALLPAPER"
bash setup_packages.sh
bash setup_nvidia_driver.sh

# Reboot the system to apply all changes
sudo reboot
