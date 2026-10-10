#!/bin/bash
set -e

# Minimal GNOME: desktop, login manager, settings, file manager and terminal
sudo apt-get install -y --no-install-recommends gnome-shell gnome-session gdm3 gnome-control-center nautilus gnome-terminal

# Install system font, Inter
sudo apt-get install -y --no-install-recommends fonts-inter

# Install GNOME Keyring PAM module for automatic keyring unlock at login
sudo apt-get install -y --no-install-recommends gnome-keyring libpam-gnome-keyring

# Install image format support (HEIF, WebP, AVIF)
sudo apt-get install -y --no-install-recommends heif-gdk-pixbuf webp-pixbuf-loader libavif-gdk-pixbuf

# Install video codecs
sudo apt-get install -y --no-install-recommends gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav

# Install image thumbnails
sudo apt-get install -y --no-install-recommends libgdk-pixbuf2.0-bin

# Install video thumbnails
sudo apt-get install -y --no-install-recommends ffmpegthumbnailer

# Install PDF viewer and thumbnails
sudo apt-get install -y --no-install-recommends papers

# Install image viewer
sudo apt-get install -y --no-install-recommends loupe

# Install video player
sudo apt-get install -y --no-install-recommends showtime

# Install disk utility: partitions and bootable USB creator
sudo apt-get install -y --no-install-recommends gnome-disk-utility

# Install system monitor
sudo apt-get install -y --no-install-recommends gnome-system-monitor

# Setup Wi-Fi
sudo apt-get install -y --no-install-recommends network-manager-gnome
echo -e "auto lo\niface lo inet loopback" | sudo tee /etc/network/interfaces
sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
# Disable Wi-Fi Power Saving (fixes suspend bug)
sudo mkdir -p /etc/modprobe.d
echo "options rtw88_core disable_lps_deep=y" | sudo tee /etc/modprobe.d/rtw88.conf
sudo mkdir -p /etc/NetworkManager/conf.d
echo -e "[connection]\nwifi.powersave = 2" | sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf

# Disable Automatic Screen Blank
gsettings set org.gnome.desktop.session idle-delay 0

# Disable Automatic Suspend
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Setup desktop preferences
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"

# Set system font: interface, documents and window titles
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Bold 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font false

# Set desktop wallpaper, if one was chosen
WALLPAPER="$HOME/.local/share/wallpapers/wallpaper.png"
if [ -f "$WALLPAPER" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
fi

# Set dock favorite apps
gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'com.microsoft.VSCode.desktop', 'spotify.desktop']"

# Enable dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Install GNOME extensions
sudo apt-get install -y --no-install-recommends git gnome-shell-extension-dash-to-dock gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator
EXT_PATH="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXT_PATH"
if [ ! -d "$EXT_PATH/clipboard-indicator@tudmotu.com" ]; then
  git clone https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git "$EXT_PATH/clipboard-indicator@tudmotu.com"
else
  git -C "$EXT_PATH/clipboard-indicator@tudmotu.com" pull
fi

echo -e "\n----------IMPORTANT (ONLY FIRST TIME)----------\n"
echo "Restart your system and enable the GNOME extensions via the Extensions app, or by running the following commands:"
echo "gnome-extensions enable dash-to-dock@micxgx.gmail.com"
echo "gnome-extensions enable ding@rastersoft.com"
echo "gnome-extensions enable ubuntu-appindicators@ubuntu.com"
echo "gnome-extensions enable clipboard-indicator@tudmotu.com"
echo -e "\n-----------------------------------------------\n"
