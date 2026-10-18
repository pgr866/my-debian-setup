#!/bin/bash
set -e

# Update the local package index
sudo apt-get update

# Conectarse con ssh user@192.168.122.217
# sudo apt-get install -y --no-install-recommends openssh-server

sudo apt-get install -y --no-install-recommends sway foot wmenu libpam-systemd

mkdir -p ~/.config/sway
[ -f ~/.config/sway/config ] || cp /etc/sway/config ~/.config/sway/config

grep -q 'xkb_layout' ~/.config/sway/config || cat >> ~/.config/sway/config <<'EOF'
input type:keyboard {
    xkb_layout es
}
EOF

grep -q 'exec sway' ~/.profile 2>/dev/null || cat >> ~/.profile <<'EOF'
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec sway
fi
EOF
