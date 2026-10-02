#!/bin/bash
set -e

# Define and create the local binary directory to store user scripts
DIR="$HOME/.local/bin"
mkdir -p "$DIR"
cd "$DIR" || exit

# Download utility scripts from the repository
sudo wget -c -O clear_docker.sh "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/clear_docker.sh"
sudo wget -c -O sync_hard_drive.sh "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/sync_hard_drive.sh"
sudo wget -c -O update.sh "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/update.sh"

# Download environment setup scripts (Plasma, NVIDIA drivers, and auto-update configuration)
sudo wget -c -O setup_plasma.sh "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/setup_plasma.sh"
sudo wget -c -O setup_nvidia_driver.sh "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/setup_nvidia_driver.sh"
sudo wget -c -O setup_packages.sh "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/setup_packages.sh"

# Grant execution permissions to all downloaded scripts
sudo chmod +x ./*.sh

# Run the primary configuration and setup scripts
bash setup_packages.sh
bash setup_plasma.sh
bash setup_nvidia_driver.sh

# Append PATH to .bashrc and .zshrc if not already present
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"

# Reboot the system to apply all changes
sudo reboot
