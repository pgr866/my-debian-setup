#!/bin/bash
set -e
cd /tmp

# Update APT repositories and system packages
sudo apt-get update
sudo apt-get dist-upgrade -y

# Install miscellaneous tools and applications
sudo apt-get install -y --no-install-recommends fastfetch git curl unzip exfatprogs power-profiles-daemon gimp audacity openshot-qt

# Minimal OBS Studio installation
sudo apt-get install -y --no-install-recommends obs-studio obs-plugins qtwayland5 libva-wayland2

# Install fonts for emoji and symbol support
sudo apt-get install -y --no-install-recommends fonts-symbola fonts-noto-core fonts-noto-mono fonts-noto-color-emoji

# Configure Git with user name and email
git config --global user.name "Pablo Gómez Rivas"
git config --global user.email "pgr866@inlumine.ual.es"

# Download and install .deb packages
rm -f ./*.deb
wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
wget -O protonvpn.deb "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/$(wget -qO- https://repo.protonvpn.com/debian/dists/stable/main/binary-all/ | grep -oP 'protonvpn-stable-release_.*?_all.deb' | tail -1)"
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections # Auto-accept VS Code repository prompt
sudo apt-get install -y ./*.deb
rm -f ./*.deb

# Install Proton VPN desktop app (requires the Proton VPN .deb installed)
sudo apt-get update
sudo apt-get install -y --no-install-recommends proton-vpn-gnome-desktop

# Add Discord to run at startup
mkdir -p $HOME/.config/autostart
cp /usr/share/applications/discord.desktop $HOME/.config/autostart/

# Install Brave Web Browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt-get update
sudo apt-get install -y brave-browser

# Install Spotify
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update
sudo mkdir -p /usr/share/desktop-directories # its installer needs this folder to add the menu entry
sudo apt-get install -y spotify-client
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
sudo apt-get install -y zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/upgrade.sh)"
fi
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
if [ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/zsh-autosuggestions"
else
  git -C "$ZSH_CUSTOM/zsh-autosuggestions" pull
fi
if [ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/zsh-syntax-highlighting"
else
  git -C "$ZSH_CUSTOM/zsh-syntax-highlighting" pull
fi
sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
sudo chsh -s $(which zsh) $USER

# Sets VS Code as the default application for all system text file types
sudo update-alternatives --set editor /usr/bin/code
xdg-mime default code.desktop text/plain
for file in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$file" ] && grep -qF 'EDITOR="code --wait"' "$file" || echo 'export EDITOR="code --wait" VISUAL="code --wait"' >> "$file"
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
)
for extension in "${extensions[@]}"; do
  code --install-extension $extension --force
done

# Install rclone
command -v rclone >/dev/null && sudo rclone selfupdate || curl https://rclone.org/install.sh | sudo bash || [ $? -eq 3 ] # 3: already the latest version

# Install Docker Engine
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

# Install Terraform
TF_V=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -oP '(?<="current_version":")[^"]+')
wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TF_V}/terraform_${TF_V}_linux_amd64.zip"
unzip -o terraform.zip terraform && sudo mv terraform /usr/local/bin/ && rm terraform.zip

# Clean up system: APT, logs (7 days)
sudo apt-get update
sudo apt-get autoremove -y --purge
sudo apt-get clean
sudo journalctl --vacuum-time=7d 2>/dev/null || true
