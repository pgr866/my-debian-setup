#!/bin/bash
set -e

# Conectarse con ssh user@192.168.122.217, contraseña 1234
# sudo apt-get install -y --no-install-recommends openssh-server
# grep -q WLR_RENDERER ~/.profile || sed -i '/exec sway/i export WLR_NO_HARDWARE_CURSORS=1 WLR_RENDERER=pixman' ~/.profile

# Update the local package index
sudo apt-get update

# Install utilities for downloading files
sudo apt-get install -y --no-install-recommends wget ca-certificates

# Minimal Sway: compositor, terminal, launcher and session support
sudo apt-get install -y --no-install-recommends sway foot fuzzel libpam-systemd

# Install screenshot tools
sudo apt-get install -y --no-install-recommends grim slurp

# Setup screen sharing on Wayland and file dialogs
sudo apt-get install -y --no-install-recommends xdg-desktop-portal-wlr xdg-desktop-portal-gtk

# Use GNOME Keyring for app passwords, unlocked at login
sudo apt-get install -y --no-install-recommends gnome-keyring libpam-gnome-keyring

# Install authentication agent (brings polkit: apps ask for permissions, power menu and energy profiles work)
sudo apt-get install -y --no-install-recommends lxpolkit

# Setup sound
sudo apt-get install -y --no-install-recommends wireplumber

# Install clipboard history
sudo apt-get install -y --no-install-recommends cliphist

# Install notification daemon and its sound
sudo apt-get install -y --no-install-recommends mako-notifier sound-theme-freedesktop

# Install file manager
sudo apt-get install -y --no-install-recommends ranger

# Install image viewer
sudo apt-get install -y --no-install-recommends swayimg

# Install video player
sudo apt-get install -y --no-install-recommends mpv

# Install partition manager and bootable USB creator
sudo apt-get install -y --no-install-recommends gnome-disk-utility

# Install automounting of USB drives and other removable media (gir1.2-notify: notifications)
sudo apt-get install -y --no-install-recommends udiskie gir1.2-notify-0.7

# Install system monitor
sudo apt-get install -y --no-install-recommends btop

# Install screen locker (manual lock on Mod+Escape, and before suspending)
sudo apt-get install -y --no-install-recommends swaylock swayidle

# Setup screen brightness control (brightness keys are already bound in the default Sway config)
sudo apt-get install -y --no-install-recommends brightnessctl

# Install status bar
sudo apt-get install -y --no-install-recommends waybar

# Setup Wi-Fi
sudo apt-get install -y --no-install-recommends network-manager

# Setup Bluetooth (libspa-0.2-bluetooth: Bluetooth headphones as audio devices)
sudo apt-get install -y --no-install-recommends bluez libspa-0.2-bluetooth

# Setup energy profiles
sudo apt-get install -y --no-install-recommends power-profiles-daemon

# Install fonts: bar icons (FontAwesome, plus Material Design Icons for Wi-Fi and Bluetooth) and system font Inter
sudo apt-get install -y --no-install-recommends fonts-font-awesome fonts-materialdesignicons-webfont fonts-inter

# Start Sway automatically when logging in on tty1
grep -q 'exec sway' ~/.profile 2>/dev/null || cat >> ~/.profile <<'EOF'
[ -z "${WAYLAND_DISPLAY:-}" ] && [ "${XDG_VTNR:-}" = 1 ] && exec sway
EOF

# Launcher: hide the apps whose program is not installed (e.g. vim.desktop without vim)
mkdir -p ~/.local/share/applications
for f in /usr/share/applications/*.desktop; do
    bin=$(grep -m1 '^TryExec=' "$f" | cut -d= -f2-)
    [ -n "$bin" ] || bin=$(grep -m1 '^Exec=' "$f" | cut -d= -f2- | cut -d' ' -f1)
    command -v "$bin" >/dev/null 2>&1 || \
        printf '[Desktop Entry]\nType=Application\nName=hidden\nNoDisplay=true\n' > ~/.local/share/applications/"$(basename "$f")"
done

# Customization: configuration files from the sway folder next to this script, if there is one
SRC=
[ -f "${BASH_SOURCE[0]}" ] && SRC=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/sway
if [ -d "$SRC" ]; then
    sudo cp -rT "$SRC/etc" /etc
    cp -rT "$SRC/home" ~

    # GTK apps: same settings for GTK 4 as for GTK 3
    install -Dm644 ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini
fi

# Desktop wallpaper
sudo mkdir -p /usr/local/share/backgrounds
sudo wget -nv --tries=3 -O /usr/local/share/backgrounds/wallpaper.png \
    https://raw.githubusercontent.com/pgr866/my-debian-setup/main/wallpaper.png

echo "Done. Sway has been customized. Log out and back in so everything picks up the changes."
