#!/bin/bash
set -e

# Update the local package index
sudo apt-get update

# Conectarse con ssh user@192.168.122.217
# sudo apt-get install -y --no-install-recommends openssh-server

sudo apt-get install -y --no-install-recommends wget ca-certificates

sudo apt-get install -y --no-install-recommends sway foot wmenu libpam-systemd

sudo apt-get install -y --no-install-recommends \
    grim slurp \
    xdg-desktop-portal-wlr wireplumber \
    wl-clipboard \
    sway-notification-center \
    thunar ranger \
    waybar \
    fonts-font-awesome

# Aplicar barra waybar y notificaciones
sudo tee /etc/sway/config.d/30-waybar.conf >/dev/null <<'EOF'
bar bar-0 mode invisible
exec waybar
exec swaync
EOF

# Config de waybar con icono de notificaciones (swaync)
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config.jsonc <<'EOF'
{
    "layer": "top",
    "position": "top",
    "modules-right": [
        "custom/notification",
        "idle_inhibitor",
        "pulseaudio",
        "network",
        "cpu",
        "memory",
        "clock",
        "tray"
    ],
    "custom/notification": {
        "format": "{icon}",
        "format-icons": {
            "notification": "\uf0f3 •",
            "none": "\uf0f3",
            "dnd-notification": "\uf1f6 •",
            "dnd-none": "\uf1f6"
        },
        "return-type": "json",
        "exec": "swaync-client -swb",
        "on-click": "swaync-client -t -sw",
        "escape": true
    }
}
EOF

# Fondo de pantalla
sudo mkdir -p /usr/local/share/backgrounds
sudo wget -q -O /usr/local/share/backgrounds/wallpaper.png https://i.postimg.cc/gr97QKdZ/wallpaper.png
echo 'output * bg /usr/local/share/backgrounds/wallpaper.png fill' | sudo tee /etc/sway/config.d/20-wallpaper.conf >/dev/null

# Teclado en español
sudo tee /etc/sway/config.d/10-input.conf >/dev/null <<'EOF'
input type:keyboard {
    xkb_layout es
}
EOF

# Arranca sway automáticamente al entrar en tty1
grep -q 'exec sway' ~/.profile 2>/dev/null || cat >> ~/.profile <<'EOF'
[ -z "${WAYLAND_DISPLAY:-}" ] && [ "${XDG_VTNR:-}" = 1 ] && exec sway
EOF
