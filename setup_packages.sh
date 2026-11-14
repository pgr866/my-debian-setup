#!/bin/bash
set -e
cd /tmp

# Update APT repositories and system packages
sudo apt-get update
sudo apt-get dist-upgrade -y

# Install basic command-line tools
sudo apt-get install -y --no-install-recommends wget ca-certificates curl openssh-client unzip xz-utils

# Install clock synchronization over the network
sudo apt-get install -y --no-install-recommends systemd-timesyncd

# Install fastfetch for system information display
sudo apt-get install -y --no-install-recommends fastfetch

# Install exFAT support
sudo apt-get install -y --no-install-recommends exfatprogs

# Install energy profiles
sudo apt-get install -y --no-install-recommends power-profiles-daemon

# Install image editor GIMP
sudo apt-get install -y --no-install-recommends gimp

# Install audio editor Audacity
sudo apt-get install -y --no-install-recommends audacity

# Install video editor Shotcut
sudo apt-get install -y --no-install-recommends shotcut

# Install virtual machine manager
sudo apt-get install -y --no-install-recommends virt-manager libvirt-daemon-system qemu-system-x86 qemu-utils qemu-system-modules-spice gir1.2-spiceclientgtk-3.0 ovmf virtiofsd swtpm swtpm-tools
# Manage VMs without a password prompt
sudo usermod -aG libvirt "$USER"

# Start libvirt on demand instead of at every boot
sudo systemctl disable libvirtd.service virtlogd.service libvirt-guests.service
sudo systemctl enable libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket virtlogd.socket virtlogd-admin.socket

# Install screen recording tool OBS Studio
sudo apt-get install -y --no-install-recommends obs-studio obs-plugins libva-wayland2

# Install fonts for emoji and symbol support
sudo apt-get install -y --no-install-recommends fonts-symbola fonts-noto-core fonts-noto-mono fonts-noto-color-emoji

# Install Git for version control and repository management
sudo apt-get install -y --no-install-recommends git

# Configure Git with user name and email
git config --global user.name "Pablo Gómez Rivas"
git config --global user.email "114260059+pgr866@users.noreply.github.com"

# Download and install .deb packages
rm -f ./*.deb
wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
wget -O protonvpn.deb "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/$(wget -qO- https://repo.protonvpn.com/debian/dists/stable/main/binary-all/ | grep -oP 'protonvpn-stable-release_.*?_all.deb' | sort -uV | tail -1)"
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections # Auto-accept VS Code repository prompt
sudo apt-get install -y --no-install-recommends ./*.deb
rm -f ./*.deb

# Install Proton VPN desktop app (requires the Proton VPN .deb installed)
sudo apt-get update
sudo apt-get install -y --no-install-recommends proton-vpn-gnome-desktop

# Start the Proton VPN daemon on demand instead of at every boot
sudo systemctl disable me.proton.vpn.split_tunneling.service
sudo ln -sf /usr/lib/systemd/system/me.proton.vpn.split_tunneling.service /etc/systemd/system/proton.VPN.service
sudo systemctl daemon-reload
# Disable the generic OpenVPN service pulled in by Proton VPN (unused: no tunnels in /etc/openvpn)
sudo systemctl disable openvpn.service

# Install Brave Web Browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt-get update
sudo apt-get install -y --no-install-recommends brave-browser

# Install Spotify
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update
sudo mkdir -p /usr/share/desktop-directories # its installer needs this folder to add the menu entry
sudo apt-get install -y --no-install-recommends spotify-client
# Add Spotify Desktop Shortcut, the desktop does not show it automatically
mkdir -p ~/.local/share/applications
cat << 'EOF' > ~/.local/share/applications/spotify.desktop
[Desktop Entry]
Name=Spotify
Exec=spotify
Terminal=false
Type=Application
Icon=spotify-client
Categories=AudioVideo;Audio;Player;
MimeType=x-scheme-handler/spotify;
EOF

# Install Zsh and Oh My Zsh
sudo apt-get install -y --no-install-recommends zsh
if [ ! -d "$HOME/.oh-my-zsh/.git" ]; then
  rm -rf "$HOME/.oh-my-zsh"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/upgrade.sh)"
fi
PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
for p in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$PLUGINS/$p/.git" ]; then
    rm -rf "$PLUGINS/$p"
    git clone "https://github.com/zsh-users/$p" "$PLUGINS/$p"
  else
    git -C "$PLUGINS/$p" pull
  fi
done
sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
sudo chsh -s "$(which zsh)" "$USER"

# Sets VS Code as the default application for common text file types
sudo update-alternatives --set editor /usr/bin/code
mapfile -t text_mimes < <(grep '^text/' /usr/share/mime/types | grep -vx 'text/html')
text_mimes+=(
  application/json application/xml application/x-yaml application/toml
  application/javascript application/x-shellscript application/x-sh application/sql
  application/x-php application/x-perl application/x-ruby application/x-desktop
)
xdg-mime default com.microsoft.VSCode.desktop "${text_mimes[@]}" 2>/dev/null
for file in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$file" ] && ! grep -qF 'EDITOR="code --wait"' "$file"; then
    echo 'export EDITOR="code --wait" VISUAL="code --wait"' >> "$file"
  fi
done

# Install a predefined list of VS Code extensions
extensions=(
  ms-azuretools.vscode-containers
  ms-vscode-remote.remote-containers
  ms-kubernetes-tools.vscode-kubernetes-tools
  hashicorp.terraform
  icrawl.discord-vscode
  hediet.vscode-drawio
  echoapi.echoapi-for-vscode
  ms-vscode-remote.remote-ssh
  anthropic.claude-code
)
for extension in "${extensions[@]}"; do
  code --install-extension $extension --force
done

# Install rclone
command -v rclone >/dev/null && sudo rclone selfupdate || curl -fsSL https://rclone.org/install.sh | sudo bash || [ $? -eq 3 ] # 3: already the latest version

# Install Docker Engine
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

# Start Docker on demand instead of at every boot
sudo systemctl enable docker.socket
sudo systemctl disable docker.service containerd.service

# Install Terraform
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y --no-install-recommends terraform

# Install Claude Desktop
sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list
sudo apt-get update
sudo apt-get install -y claude-desktop # with recommends on purpose: Cowork (QEMU) and sign-in keyring
# Cowork needs /dev/kvm and /dev/vhost-vsock
sudo usermod -aG kvm "$USER"

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

echo "Done. Packages have been installed. Log out and back in so everything picks up the changes."
