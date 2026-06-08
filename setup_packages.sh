#!/bin/bash
set -e
cd /tmp

# Update APT repositories and system packages
sudo apt-get update
sudo apt-get dist-upgrade -y

# Install packages from APT repositories
sudo apt-get install -y git curl unzip 7zip exfatprogs power-profiles-daemon

# Minimal OBS Studio installation (no-recommends)
sudo apt-get install -y --no-install-recommends obs-studio obs-plugins qtwayland5 libva-wayland2

# Video codecs
sudo apt-get install -y --no-install-recommends gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav

# Image codecs
sudo apt-get install -y --no-install-recommends heif-gdk-pixbuf webp-pixbuf-loader libavif-gdk-pixbuf

# Install thumbnailer engines for GNOME images and videos
sudo apt-get install -y --no-install-recommends libgdk-pixbuf2.0-bin ffmpegthumbnailer

# Install fonts for emoji and symbol support
sudo apt-get install -y --no-install-recommends fonts-symbola fonts-noto-core fonts-noto-mono fonts-noto-color-emoji

# Install essential desktop utilities and media tools
sudo apt-get install -y loupe showtime gnome-disk-utility drawing

# Configure Git with user name and email
git config --global user.name "Pablo Gómez Rivas"
git config --global user.email "pgr866@inlumine.ual.es"

# Download and install .deb packages
rm -f ./*.deb
wget -c -O chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
wget -c -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
wget -c -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
wget -c -O protonvpn.deb "https://repo.protonvpn.com/debian/dists/stable/main/binary-all/$(wget -qO- https://repo.protonvpn.com/debian/dists/stable/main/binary-all/ | grep -oP 'protonvpn-stable-release_.*?_all.deb' | tail -1)"
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections # Auto-accept VS Code repository prompt
sudo apt-get install -y ./*.deb
rm -f ./*.deb

# Install GNOME Proton VPN desktop app
sudo apt-get update
sudo apt-get install -y proton-vpn-gnome-desktop

# Add Discord to run at startup
mkdir -p $HOME/.config/autostart
cp /usr/share/applications/discord.desktop $HOME/.config/autostart/

# Install Spotify
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update
sudo apt-get install -y spotify-client

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
command -v rclone >/dev/null && sudo rclone selfupdate || curl https://rclone.org/install.sh | sudo bash

# Install Docker Engine
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

# Install Terraform
TF_V=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -oP '(?<="current_version":")[^"]+')
wget -c -O terraform.zip "https://releases.hashicorp.com/terraform/${TF_V}/terraform_${TF_V}_linux_amd64.zip"
unzip -o terraform.zip terraform && sudo mv terraform /usr/local/bin/ && rm terraform.zip

# Clean up system: APT, logs (7 days)
sudo apt-get update
sudo apt-get autoremove -y --purge
sudo apt-get clean
sudo journalctl --vacuum-time=7d 2>/dev/null || true

# Download AppImages
APP_DIR="$HOME/Applications"
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR" "$DESKTOP_DIR"
cd "$APP_DIR" || exit
rm -f ./*.AppImage
wget -c -O GIMP.AppImage https://download.gimp.org/gimp/$(curl -sL https://download.gimp.org/gimp/GIMP-Stable-x86_64.AppImage.zsync | grep -a "URL:" | sed 's/URL: //')
wget -c -O OpenShot.AppImage $(curl -s https://api.github.com/repos/OpenShot/openshot-qt/releases/latest | grep -oP 'https://[^"]*x86_64\.AppImage' | sort | tail -1)
wget -c -O Audacity.AppImage $(curl -s https://api.github.com/repos/audacity/audacity/releases/latest | grep -oP 'https://[^"]*x64[^"]*\.AppImage' | sort | tail -1)
chmod +x *.AppImage

# Integrate AppImages into the application menu
rm -f "$DESKTOP_DIR"/*.AppImage.desktop
for app in *.AppImage; do
  [ -f "$app" ] || continue
  name="${app%.AppImage}"
  launcher="$DESKTOP_DIR/$name.desktop"
  echo -e "[Desktop Entry]\nName=$name\nExec=$APP_DIR/$app\nIcon=applications-other\nType=Application\nTerminal=false" > "$launcher"
  chmod +x "$launcher"
done

# Extract libfuse2 locally and update launcher for OpenShot
rm -rf fuse2
mkdir -p fuse2
wget -c -O libfuse2.deb "http://deb.debian.org/debian/pool/main/f/fuse/libfuse2_2.9.9-6+b1_amd64.deb"
dpkg -x libfuse2.deb fuse2
rm -f libfuse2.deb
sed -i "s|^Exec=.*|Exec=env LD_LIBRARY_PATH=\"$APP_DIR/fuse2/lib/x86_64-linux-gnu\" \"$APP_DIR/OpenShot.AppImage\"|" "$DESKTOP_DIR/OpenShot.desktop"
