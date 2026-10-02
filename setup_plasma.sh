#!/bin/bash
set -e

# Minimal KDE Plasma: desktop, login manager, settings, file manager and terminal
sudo apt-get install -y --no-install-recommends plasma-desktop sddm systemsettings dolphin konsole

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

# Install video editor
sudo apt-get install -y --no-install-recommends kdenlive

# Install Proton VPN app with login-unlocked keyring (requires the Proton VPN .deb installed)
sudo apt-get install -y --no-install-recommends proton-vpn-gnome-desktop libpam-gnome-keyring

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

rm -rf "$DATA/aurorae/themes/Utterly-Round-Dark" "$DATA/icons/Papirus" ~/.icons/Bibata-Modern-Classic
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
kw() { kwriteconfig6 --file "$1" --group "$2" --key "$3" "$4"; }
fd="KFileDialog Settings"

QT_QPA_PLATFORM=offscreen plasma-apply-colorscheme Carl
kw plasmarc Theme name breeze-dark
kw kdeglobals Icons Theme Papirus
kw kcminputrc Mouse cursorTheme Bibata-Modern-Classic
kw kwinrc org.kde.kdecoration2 library org.kde.kwin.aurorae
kw kwinrc org.kde.kdecoration2 theme __aurorae__svg__Utterly-Round-Dark
kw auroraerc Utterly-Round-Dark ButtonSize 0
kw breezerc Common OutlineCloseButton true
kw breezerc Windeco ButtonSize ButtonSmall
kw breezerc Windeco DrawBorderOnMaximizedWindows true
kw ksplashrc KSplash Theme None
kw ksplashrc KSplash Engine none
kw kcminputrc Mouse cursorSize 20

kw kwinrc Effect-overview BorderActivate 9
kw kwinrc Plugins desktopchangeosdEnabled false
kw kwinrc Plugins synchronizeskipswitcherEnabled false

kw kdeglobals "$fd" "Speedbar Width" 106

kw dolphinrc MainWindow MenuBar Disabled
kw dolphinrc IconsMode PreviewSize 48
kw dolphinrc "$fd" "Places Icons Auto-resize" false
kw dolphinrc "$fd" "Places Icons Static Size" 22

kw kded5rc Module-device_automounter autoload false
kw systemsettingsrc systemsettings_sidebar_mode HighlightNonDefaultSettings true

# Shortcuts: launcher on Meta+A (freed from "next activity") and Overview on Meta
kw kglobalshortcutsrc plasmashell "activate application launcher" $'Meta+A\tAlt+F1,Meta\tAlt+F1,Activate Application Launcher'
kw kglobalshortcutsrc plasmashell "next activity" "none,none,Walk through activities"
kw kglobalshortcutsrc kwin Overview "Meta,Meta+W,Toggle Overview"

# GTK apps: global menu, and title bar buttons on the right like the window decoration
mkdir -p ~/.config/gtk-3.0
kw ~/.config/gtk-3.0/settings.ini Settings gtk-modules appmenu-gtk-module
kw ~/.config/gtk-3.0/settings.ini Settings gtk-shell-shows-menubar 1
kw ~/.config/gtk-3.0/settings.ini Settings gtk-decoration-layout ":minimize,maximize,close"

# Lock screen with the desktop wallpaper
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General \
    --key Image "file://$DATA/wallpapers/mytheme.png"

# Login screen (SDDM): Breeze theme, same look as the lock screen, with the desktop wallpaper.
sudo apt-get install -y --no-install-recommends sddm-theme-breeze
sudo install -Dm644 "$DATA/wallpapers/mytheme.png" /usr/local/share/wallpapers/mytheme.png
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=breeze\n' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
printf '[General]\nbackground=/usr/local/share/wallpapers/mytheme.png\n' |
    sudo tee /usr/share/sddm/themes/breeze/theme.conf.user >/dev/null

# Makes the Breeze Dark panels black by overriding the panel background for the current user
system_themes=/usr/share/plasma/desktoptheme
user_theme=~/.local/share/plasma/desktoptheme/breeze-dark
variants="widgets opaque/widgets solid/widgets translucent/widgets"
rm -rf "$user_theme"
mkdir -p "$user_theme"
cp -r "$system_themes/breeze-dark/." "$user_theme"
for variant in $variants; do
    mkdir -p "$user_theme/$variant"
    zcat -f "$system_themes/default/$variant/panel-background.svg"* |
        sed 's/currentColor/#000000/g' > "$user_theme/$variant/panel-background.svg"
done

# Panels and wallpaper: applied now if Plasma is running, otherwise at the first login
session_setup=$DATA/mytheme/session-setup.sh
mkdir -p "$DATA/mytheme"
cat > "$session_setup" <<'EOF'
#!/bin/bash
set -e
rm -rf ~/.config/autostart/mytheme-setup.desktop ~/.local/share/mytheme

# Restart plasmashell so it reloads the Plasma style, icons and black panels
rm -rf ~/.cache/ksvg-elements* ~/.cache/plasma_theme_*
systemctl --user restart plasma-plasmashell
dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure

# Wallpaper, bottom dock and top bar
dbus-send --session --type=method_call --print-reply=literal --dest=org.kde.plasmashell \
    /PlasmaShell org.kde.PlasmaShell.evaluateScript string:'
desktops().forEach(function (desktop) {
    desktop.wallpaperPlugin = "org.kde.image";
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", "file://" + userDataPath() + "/.local/share/wallpapers/mytheme.png");
});

panels().forEach(function (panel) { panel.remove(); });

var dock = new Panel;
dock.location = "bottom";
dock.height = Math.round(gridUnit * 2.5);
dock.hiding = "dodgewindows";
dock.lengthMode = "fit";
var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "preferred://filemanager,applications:org.kde.konsole.desktop");
dock.addWidget("org.kde.plasma.trash");

var bar = new Panel;
bar.location = "top";
bar.height = Math.round(gridUnit * 1.25);
bar.floating = false;
bar.addWidget("org.kde.plasma.appmenu");
bar.addWidget("org.kde.plasma.panelspacer");
bar.addWidget("org.kde.plasma.notifications");
bar.addWidget("org.kde.plasma.digitalclock");
bar.addWidget("org.kde.plasma.panelspacer");
var systray = bar.addWidget("org.kde.plasma.systemtray");
var tray = desktopById(systray.readConfig("SystrayContainmentId"));
tray.currentConfigGroup = ["General"];
tray.writeConfig("extraItems", "org.kde.plasma.keyboardlayout,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod");
tray.writeConfig("knownItems", "org.kde.plasma.keyboardlayout,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod");
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
    # Show the login screen right away when no display manager is running yet
    systemctl is-active --quiet display-manager || sudo systemctl start sddm
fi
