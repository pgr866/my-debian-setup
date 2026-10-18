#!/bin/bash
set -e

# Update the local package index
sudo apt-get update

# Conectarse con ssh user@192.168.122.217
# sudo apt-get install -y --no-install-recommends openssh-server

sudo apt-get install -y --no-install-recommends wget ca-certificates

sudo apt-get install -y --no-install-recommends sway foot fuzzel libpam-systemd

sudo apt-get install -y --no-install-recommends \
    grim slurp \
    xdg-desktop-portal-wlr wireplumber \
    wl-clipboard cliphist \
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

# Config de waybar (ligera: sin polling innecesario)
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config.jsonc <<'EOF'
{
    "layer": "top",
    "position": "top",
    "modules-left": [
        "sway/workspaces"
    ],
    "modules-center": [
        "clock"
    ],
    "modules-right": [
        "custom/notification",
        "custom/volume",
        "custom/mic",
        "backlight",
        "network",
        "cpu",
        "memory",
        "battery",
        "tray",
        "custom/power"
    ],
    "sway/workspaces": {
        "format": "{name}",
        "disable-scroll": true,
        "persistent-workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": [],
            "5": []
        }
    },
    "custom/notification": {
        "format": "{icon}",
        "format-icons": {
            "notification": " •",
            "none": "",
            "dnd-notification": " •",
            "dnd-none": ""
        },
        "return-type": "json",
        "exec": "swaync-client -swb",
        "on-click": "swaync-client -t -sw",
        "escape": true
    },
    "clock": {
        "format": "{:%d/%m/%Y %H:%M}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>",
        "calendar": {
            "mode": "month",
            "format": {
                "today": "<span color='#7aa2f7'><b><u>{}</u></b></span>"
            }
        },
        "actions": {
            "on-scroll-up": "shift_up",
            "on-scroll-down": "shift_down"
        }
    },
    "custom/volume": {
        "format": " {}",
        "exec": "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ if ($3) print \"mute\"; else print int($2*100)\"%\" }'",
        "interval": "once",
        "signal": 8,
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; pkill -RTMIN+8 waybar",
        "on-scroll-up": "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+; pkill -RTMIN+8 waybar",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; pkill -RTMIN+8 waybar"
    },
    "custom/mic": {
        "format": "\uf130 {}",
        "exec": "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{ if ($3) print \"mute\"; else print int($2*100)\"%\" }'",
        "interval": "once",
        "signal": 9,
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; pkill -RTMIN+9 waybar",
        "on-scroll-up": "wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+; pkill -RTMIN+9 waybar",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-; pkill -RTMIN+9 waybar"
    },
    "custom/power": {
        "format": "\uf011",
        "tooltip": false,
        "menu": "on-click",
        "menu-file": "~/.config/waybar/power_menu.xml",
        "menu-actions": {
            "logout": "swaymsg exit",
            "suspend": "sudo systemctl suspend",
            "reboot": "sudo systemctl reboot",
            "shutdown": "sudo systemctl poweroff"
        }
    },
    "network": {
        "format": "",
        "format-wifi": " {signalStrength}%",
        "tooltip": false
    },
    "backlight": {
        "format": " {percent}%"
    },
    "cpu": {
        "format": " {usage}%"
    },
    "memory": {
        "format": " {percentage}%"
    },
    "battery": {
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    }
}
EOF

# Permisos del menu de apagado (no hay polkit): sudo sin contrasena solo para estas 3 ordenes
echo "$USER ALL=(root) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend" | sudo tee /etc/sudoers.d/power >/dev/null
sudo chmod 440 /etc/sudoers.d/power
sudo visudo -cf /etc/sudoers.d/power

# Menu de apagado (modulo custom/power)
cat > ~/.config/waybar/power_menu.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <object class="GtkMenu" id="menu">
    <child>
      <object class="GtkMenuItem" id="logout">
        <property name="label">Logout</property>
      </object>
    </child>
    <child>
      <object class="GtkMenuItem" id="suspend">
        <property name="label">Suspend</property>
      </object>
    </child>
    <child>
      <object class="GtkSeparatorMenuItem" id="delimiter1"/>
    </child>
    <child>
      <object class="GtkMenuItem" id="reboot">
        <property name="label">Reboot</property>
      </object>
    </child>
    <child>
      <object class="GtkMenuItem" id="shutdown">
        <property name="label">Shutdown</property>
      </object>
    </child>
  </object>
</interface>
EOF

# Estilo de waybar (tipo Omarchy, Tokyo Night)
cat > ~/.config/waybar/style.css <<'EOF'
/* Estilo tipo Omarchy: Tokyo Night */
* {
    border: none;
    border-radius: 0;
    min-height: 0;
    font-family: "FontAwesome", "monospace";
    font-size: 12px;
}

window#waybar {
    background-color: transparent;
    color: #ffffff;
}

#workspaces button {
    padding: 0 6px;
    margin: 0 1px;
    background: transparent;
    color: #ffffff;
}

#workspaces button.focused {
    color: #ffffff;
    font-weight: bold;
}

#workspaces button.urgent {
    color: #f7768e;
}

#workspaces button:hover {
    background: #24283b;
    color: #ffffff;
}

#custom-notification,
#custom-volume,
#custom-mic,
#custom-power,
#backlight,
#network,
#cpu,
#memory,
#battery,
#clock,
#tray {
    padding: 0 4px;
    background-color: transparent;
    color: #ffffff;
}

#battery.charging,
#battery.plugged {
    color: #ffffff;
}

#battery.critical:not(.charging) {
    color: #f7768e;
}

tooltip {
    background-color: #1a1b26;
    border: 1px solid #33467c;
}

tooltip label {
    color: #c0caf5;
}
EOF

# Modo oscuro GTK3/GTK4 (sin paquetes adicionales)
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cat > ~/.config/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

# Fondo de pantalla
sudo mkdir -p /usr/local/share/backgrounds
sudo wget -q -O /usr/local/share/backgrounds/wallpaper.png https://raw.githubusercontent.com/pgr866/my-debian-setup/main/wallpaper.png
echo 'output * bg /usr/local/share/backgrounds/wallpaper.png fill' | sudo tee /etc/sway/config.d/20-wallpaper.conf >/dev/null

# Sin cabeceras en las ventanas: solo un borde fino
sudo tee /etc/sway/config.d/40-borders.conf >/dev/null <<'EOF'
default_border pixel 1
default_floating_border pixel 1
client.focused          #7aa2f7 #7aa2f7 #c0caf5 #7aa2f7 #7aa2f7
client.focused_inactive #33467c #33467c #a9b1d6 #33467c #33467c
client.unfocused        #33467c #1a1b26 #565f89 #33467c #33467c
client.urgent           #f7768e #f7768e #1a1b26 #f7768e #f7768e
EOF

# Lanzador: fuzzel en lugar de wmenu ($mod+d)
sudo mkdir -p /etc/sway/config-vars.d
echo 'set $menu fuzzel' | sudo tee /etc/sway/config-vars.d/10-menu.conf >/dev/null

# fuzzel: oculta las apps cuyo programa no esta instalado (p. ej. vim.desktop sin vim)
mkdir -p ~/.local/share/applications
for f in /usr/share/applications/*.desktop; do
    bin=$(grep -m1 '^TryExec=' "$f" | cut -d= -f2-)
    [ -n "$bin" ] || bin=$(grep -m1 '^Exec=' "$f" | cut -d= -f2- | cut -d' ' -f1)
    command -v "$bin" >/dev/null 2>&1 || \
        printf '[Desktop Entry]\nType=Application\nName=hidden\nNoDisplay=true\n' > ~/.local/share/applications/"$(basename "$f")"
done

# fuzzel en modo oscuro
mkdir -p ~/.config/fuzzel
cat > ~/.config/fuzzel/fuzzel.ini <<'EOF'
[main]
terminal=foot -e
prompt="> "
width=40
lines=10
horizontal-pad=8
vertical-pad=8
inner-pad=4

[colors]
background=1a1b26e6
text=c0caf5ff
prompt=7aa2f7ff
input=c0caf5ff
match=7aa2f7ff
selection=33467cff
selection-text=c0caf5ff
selection-match=7aa2f7ff
border=7aa2f7ff

[border]
width=1
radius=10
EOF

# Espacio pequeno entre ventanas
sudo tee /etc/sway/config.d/45-gaps.conf >/dev/null <<'EOF'
gaps inner 6
exec_always swaymsg 'gaps inner all set 6'
EOF

# Historial del portapapeles (cliphist): $mod+Shift+v abre el historial en fuzzel
sudo tee /etc/sway/config.d/60-clipboard.conf >/dev/null <<'EOF'
exec wl-paste --watch cliphist store
bindsym $mod+Shift+v exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
EOF

# Terminal foot con colores Tokyo Night
mkdir -p ~/.config/foot
cat > ~/.config/foot/foot.ini <<'EOF'
[colors]
background=1a1b26
foreground=c0caf5
regular0=15161e
regular1=f7768e
regular2=9ece6a
regular3=e0af68
regular4=7aa2f7
regular5=bb9af7
regular6=7dcfff
regular7=a9b1d6
bright0=414868
bright1=f7768e
bright2=9ece6a
bright3=e0af68
bright4=7aa2f7
bright5=bb9af7
bright6=7dcfff
bright7=c0caf5
EOF

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
