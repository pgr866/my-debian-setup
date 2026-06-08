#!/bin/bash
set -e

# Install GNOME minimal setup
sudo apt-get install -y --no-install-recommends gnome-shell gnome-session gnome-terminal gnome-control-center nautilus gdm3

# Setup desktop preferences
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

# Disable Automatic Screen Blank
gsettings set org.gnome.desktop.session idle-delay 0

# Disable Automatic Suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Set desktop wallpaper
WALLPAPER="$HOME/wallpaper.png"
if [ -f "$WALLPAPER" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
fi

# Enable dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Disable Bluetooth
bluetoothctl power off

# Enable Network Manager for GNOME
sudo apt-get install -y network-manager-gnome
echo -e "auto lo\niface lo inet loopback" | sudo tee /etc/network/interfaces
sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf

# Install GNOME extensions
sudo apt-get install -y git gnome-shell-extension-dash-to-dock gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator
EXT_PATH="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXT_PATH"
if [ ! -d "$EXT_PATH/clipboard-indicator@tudmotu.com" ]; then
  git clone https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git "$EXT_PATH/clipboard-indicator@tudmotu.com"
else
  git -C "$EXT_PATH/clipboard-indicator@tudmotu.com" pull
fi

echo "\n----------IMPORTANT (ONLY FIRST TIME)----------\n"
echo "Restart your system and enable the GNOME extensions via the Extensions app, or by running the following commands:"
echo "gnome-extensions enable dash-to-dock@micxgx.gmail.com"
echo "gnome-extensions enable ding@rastersoft.com"
echo "gnome-extensions enable ubuntu-appindicators@ubuntu.com"
echo "gnome-extensions enable clipboard-indicator@tudmotu.com"
echo "\n-----------------------------------------------\n"
