#!/bin/bash
set -e

# Minimal KDE Plasma: desktop, login manager, settings, file manager and terminal
sudo apt-get install -y --no-install-recommends plasma-desktop sddm systemsettings dolphin konsole

# Install KDE Wallet PAM module for automatic keyring unlock at login
sudo apt-get install -y --no-install-recommends libpam-kwallet5

# Install KDE default monospace font, Hack
sudo apt-get install -y --no-install-recommends fonts-hack

# Install image format support (WebP, TIFF)
sudo apt-get install -y --no-install-recommends qt6-image-formats-plugins

# Install image thumbnails
sudo apt-get install -y --no-install-recommends kio-extras

# Install video thumbnails
sudo apt-get install -y --no-install-recommends ffmpegthumbs

# Install PDF and RAW thumbnails
sudo apt-get install -y --no-install-recommends kdegraphics-thumbnailers ghostscript

# Install image viewer
sudo apt-get install -y --no-install-recommends gwenview

# Install video player
sudo apt-get install -y --no-install-recommends haruna

# Install partition manager
sudo apt-get install -y --no-install-recommends partitionmanager

# Install bootable USB creator
sudo apt-get install -y --no-install-recommends isoimagewriter

# Install screenshot tool
sudo apt-get install -y --no-install-recommends kde-spectacle

# Install system monitor
sudo apt-get install -y --no-install-recommends plasma-systemmonitor

# Setup Wi-Fi
# sudo apt-get install -y --install-recommends plasma-nm

# sudo systemctl disable --now wpa_supplicant
# sudo nmcli radio wifi on
# sudo systemctl restart NetworkManager

# sudo systemctl stop wpa_supplicant NetworkManager
# sudo killall wpa_supplicant
# sudo systemctl start wpa_supplicant NetworkManager

# sudo systemctl stop wpa_supplicant NetworkManager
# sudo ip link set wlp4s0 up
# sudo systemctl start wpa_supplicant NetworkManager

# sudo sed -i '/wlp4s0/s/^/#/' /etc/network/interfaces
# sudo systemctl enable --now wpa_supplicant
# sudo nmcli radio wifi on
# sudo systemctl restart NetworkManager

# sudo apt-get install -y --no-install-recommends plasma-nm wpasupplicant
# printf 'auto lo\niface lo inet loopback\n' | sudo install -m644 /dev/stdin /etc/network/interfaces

# Setup Bluetooth
sudo apt-get install -y --no-install-recommends bluedevil libspa-0.2-bluetooth
printf '[Service]\nExecStart=\nExecStart=/usr/libexec/bluetooth/obexd -P irmc,pbap\n' |
    sudo install -Dm644 /dev/stdin /etc/systemd/user/obex.service.d/no-phonebook.conf
bluetoothctl power off

# Setup screen sharing on Wayland
sudo apt-get install -y --no-install-recommends xdg-desktop-portal-kde

# Setup sound
sudo apt-get install -y --no-install-recommends plasma-pa wireplumber

# Setup screen brightness control and energy profiles
sudo apt-get install -y --no-install-recommends powerdevil

# Setup battery status
sudo apt-get install -y --no-install-recommends upower

# Disable automatic suspend on inactivity
kwriteconfig6 --file powerdevilrc --group AC --group SuspendAndShutdown --key AutoSuspendAction 0
kwriteconfig6 --file powerdevilrc --group Battery --group SuspendAndShutdown --key AutoSuspendAction 0
kwriteconfig6 --file powerdevilrc --group LowBattery --group SuspendAndShutdown --key AutoSuspendAction 0

# Add Spotify Desktop Shortcut, KDE Plasma does not show it automatically
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

# Sets up my custom desktop theme for the current user
DATA=~/.local/share

# Download the latest versions
rm -rf /tmp/mytheme
mkdir -p /tmp/mytheme
cd /tmp/mytheme
wget -O "Carl.colors" "https://gitlab.com/jomada/carl/-/raw/HEAD/color-schemes/Carl.colors"
wget -O "utterly.tar.gz" "https://github.com/HimDek/Utterly-Round-Plasma-Style/archive/HEAD.tar.gz"
wget -O "papirus.tar.gz" "https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/HEAD.tar.gz"
wget -O "bibata.tar.xz" "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz"
wget -O "wallpaper.png" "https://raw.githubusercontent.com/pgr866/my-debian-setup/main/wallpaper.png"

rm -rf "$DATA/aurorae/themes/Utterly-Round-Dark" "$DATA/icons/Papirus" ~/.icons/Bibata-Modern-Classic "$DATA/wallpapers/mytheme.png"
mkdir -p "$DATA/color-schemes" "$DATA/aurorae/themes" "$DATA/icons" "$DATA/wallpapers" ~/.icons
cp Carl.colors "$DATA/color-schemes/"
tar xzf utterly.tar.gz -C "$DATA/aurorae/themes" --wildcards \
    --transform 's|^.*/aurorae/dark/translucent|Utterly-Round-Dark|' '*/aurorae/dark/translucent'
tar xzf papirus.tar.gz -C "$DATA/icons" --wildcards --strip-components=1 '*/Papirus'
tar xJf bibata.tar.xz -C ~/.icons
cp wallpaper.png "$DATA/wallpapers/mytheme.png"

cd ~
rm -rf /tmp/mytheme

# Settings: look and feel, window behavior, Dolphin and file dialogs
fd="KFileDialog Settings"

kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0

QT_QPA_PLATFORM=offscreen plasma-apply-colorscheme Carl
kwriteconfig6 --file plasmarc --group Theme --key name breeze-dark
kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Classic
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__Utterly-Round-Dark
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "N"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
kwriteconfig6 --file auroraerc --group Utterly-Round-Dark --key ButtonSize 0
kwriteconfig6 --file ksplashrc --group KSplash --key Engine none
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 20

kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9

kwriteconfig6 --file kdeglobals --group "$fd" --key "Speedbar Width" 106

kwriteconfig6 --file dolphinrc --group IconsMode --key PreviewSize 48
kwriteconfig6 --file dolphinrc --group "$fd" --key "Places Icons Auto-resize" false
kwriteconfig6 --file dolphinrc --group "$fd" --key "Places Icons Static Size" 22

kwriteconfig6 --file systemsettingsrc --group systemsettings_sidebar_mode --key HighlightNonDefaultSettings true

# Shortcuts: launcher on Meta+A (freed from "next activity") and Overview on Meta
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate application launcher" $'Meta+A\tAlt+F1,Meta\tAlt+F1,Activate Application Launcher'
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "next activity" "none,none,Walk through activities"
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key Overview "Meta,Meta+W,Toggle Overview"

# GTK apps: global menu
sudo apt-get install -y --no-install-recommends appmenu-gtk3-module
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-modules appmenu-gtk-module
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-shell-shows-menubar 1

# Lock screen: no automatic lock on inactivity, and the desktop wallpaper
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General \
    --key Image "file://$DATA/wallpapers/mytheme.png"

# Login screen (SDDM): Breeze theme, same look as the lock screen, with the desktop wallpaper.
sudo apt-get install -y --no-install-recommends sddm-theme-breeze
sudo install -Dm644 "$DATA/wallpapers/mytheme.png" /usr/local/share/wallpapers/mytheme.png
printf '[General]\nbackground=/usr/local/share/wallpapers/mytheme.png\n' |
    sudo tee /usr/share/sddm/themes/breeze/theme.conf.user >/dev/null

# Breeze Dark panels for the current user: black when a window touches them, transparent otherwise
system_themes=/usr/share/plasma/desktoptheme
user_theme=~/.local/share/plasma/desktoptheme/breeze-dark
variants="widgets solid/widgets translucent/widgets"
rm -rf "$user_theme"
mkdir -p "$user_theme"
cp -r "$system_themes/breeze-dark/." "$user_theme"
for variant in $variants; do
    mkdir -p "$user_theme/$variant"
    zcat -f "$system_themes/default/$variant/panel-background.svg"* |
        sed 's/currentColor/#000000/g' > "$user_theme/$variant/panel-background.svg"
done
sed -i 's/#000000/transparent/g; s/stop-opacity:[.0-9]*/stop-opacity:0/g' "$user_theme"/{,translucent/}widgets/panel-background.svg
kwriteconfig6 --file "$user_theme/plasmarc" --group ContrastEffect --key enabled false
kwriteconfig6 --file "$user_theme/plasmarc" --group BlurBehindEffect --key enabled false

# Panels and wallpaper: applied now if Plasma is running, otherwise at the first login
session_setup=$DATA/mytheme/session-setup.sh
mkdir -p "$DATA/mytheme"
cat > "$session_setup" <<'EOF'
#!/bin/bash
set -e
rm -rf ~/.config/autostart/mytheme-setup.desktop ~/.local/share/mytheme

# Apply window button layout for GTK apps
python3 -c "from gi.repository import Gio;Gio.Settings.new('org.gnome.desktop.wm.preferences').set_string('button-layout','menu:minimize,maximize,close');Gio.Settings.sync()"

# Restart plasmashell so it reloads the Plasma style, icons and panel backgrounds
rm -rf ~/.cache/ksvg-elements* ~/.cache/plasma_theme_*
systemctl --user restart plasma-plasmashell
dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure

# Wallpaper, bottom dock and top bar
dbus-send --session --type=method_call --print-reply=literal --dest=org.kde.plasmashell \
    /PlasmaShell org.kde.PlasmaShell.evaluateScript string:'
desktops().forEach(function (desktop) {
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", "file://" + userDataPath() + "/.local/share/wallpapers/mytheme.png");
});

panels().forEach(function (panel) { panel.remove(); });

var dock = new Panel;
dock.location = "bottom";
dock.height = 40;
dock.hiding = "dodgewindows";
dock.lengthMode = "fit";
var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "preferred://filemanager,applications:org.kde.konsole.desktop");
dock.addWidget("org.kde.plasma.trash");

var bar = new Panel;
bar.location = "top";
bar.height = 20;
bar.floating = false;
bar.addWidget("org.kde.plasma.appmenu");
bar.addWidget("org.kde.plasma.panelspacer");
bar.addWidget("org.kde.plasma.notifications");
bar.addWidget("org.kde.plasma.digitalclock");
bar.addWidget("org.kde.plasma.panelspacer");
var systray = bar.addWidget("org.kde.plasma.systemtray");
var tray = desktopById(systray.readConfig("SystrayContainmentId"));
tray.currentConfigGroup = ["General"];
tray.writeConfig("knownItems", "org.kde.plasma.notifications");
var kicker = bar.addWidget("org.kde.plasma.kicker");
kicker.currentConfigGroup = ["General"];
kicker.writeConfig("alignResultsToBottom", "false");
kicker.writeConfig("showRecentApps", "false");
kicker.writeConfig("showRecentDocs", "false");
kicker.writeConfig("useExtraRunners", "false");
'
EOF

if pgrep -u "$USER" -x plasmashell >/dev/null; then
    bash "$session_setup"
    echo "Done. KDE Plasma has been customized. Log out and back in so every app picks up the changes."
else
    mkdir -p ~/.config/autostart
    printf '[Desktop Entry]\nType=Application\nName=MyTheme setup\nExec=bash %s\n' "$session_setup" \
        > ~/.config/autostart/mytheme-setup.desktop
    echo "Done. Log in to Plasma to finish: panels and wallpaper are applied on the first login."
fi
