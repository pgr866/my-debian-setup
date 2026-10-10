#!/bin/bash
set -e

# Minimal KDE Plasma: desktop, login manager, settings, file manager and terminal
sudo apt-get install -y --no-install-recommends plasma-desktop sddm systemsettings dolphin konsole

# Install KDE Wallet PAM module and plugins for automatic keyring unlock at login
sudo apt-get install -y --no-install-recommends libpam-kwallet5 libqca-qt6-plugins

# Use KWallet instead of GNOME Keyring for app passwords
systemctl --user mask gnome-keyring-daemon.socket gnome-keyring-daemon.service
printf '[D-BUS Service]\nName=org.freedesktop.secrets\nExec=/usr/bin/kwalletd6\n' |
    install -Dm644 /dev/stdin ~/.local/share/dbus-1/services/org.freedesktop.secrets.service

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

# Install archive manager
sudo apt-get install -y --no-install-recommends ark

# Install partition manager
sudo apt-get install -y --no-install-recommends partitionmanager

# Install bootable USB creator
sudo apt-get install -y --no-install-recommends isoimagewriter

# Install screenshot tool
sudo apt-get install -y --no-install-recommends kde-spectacle

# Install system monitor
sudo apt-get install -y --no-install-recommends plasma-systemmonitor

# Setup Wi-Fi
sudo apt-get install -y --install-recommends plasma-nm
printf 'auto lo\niface lo inet loopback\n' | sudo install -m644 /dev/stdin /etc/network/interfaces

# Setup Bluetooth
sudo apt-get install -y --no-install-recommends bluedevil libspa-0.2-bluetooth
printf '[Service]\nExecStart=\nExecStart=/usr/libexec/bluetooth/obexd -P irmc,pbap\n' |
    sudo install -Dm644 /dev/stdin /etc/systemd/user/obex.service.d/no-phonebook.conf

# Setup screen sharing on Wayland
sudo apt-get install -y --no-install-recommends xdg-desktop-portal-kde

# Setup sound
sudo apt-get install -y --no-install-recommends plasma-pa wireplumber

# Setup screen brightness control and energy profiles
sudo apt-get install -y --no-install-recommends powerdevil

# Setup battery status
sudo apt-get install -y --no-install-recommends upower

# Disable automatic suspend and screen off on inactivity
for profile in AC Battery LowBattery; do
    kwriteconfig6 --file powerdevilrc --group $profile --group SuspendAndShutdown --key AutoSuspendAction 0
    kwriteconfig6 --file powerdevilrc --group $profile --group Display --key DimDisplayWhenIdle false
    kwriteconfig6 --file powerdevilrc --group $profile --group Display --key TurnOffDisplayWhenIdle false
done

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

rm -rf "$DATA/aurorae/themes/Utterly-Round-Dark" "$DATA/icons/Papirus" ~/.icons/Bibata-Modern-Classic
mkdir -p "$DATA/color-schemes" "$DATA/aurorae/themes" "$DATA/icons" ~/.icons
cp Carl.colors "$DATA/color-schemes/"
tar xzf utterly.tar.gz -C "$DATA/aurorae/themes" --wildcards \
    --transform 's|^.*/aurorae/dark/translucent|Utterly-Round-Dark|' '*/aurorae/dark/translucent'
tar xzf papirus.tar.gz -C "$DATA/icons" --wildcards --strip-components=1 '*/Papirus'
tar xJf bibata.tar.xz -C ~/.icons

cd ~
rm -rf /tmp/mytheme

# Settings: look and feel, window behavior, Dolphin and file dialogs
fd="KFileDialog Settings"

QT_QPA_PLATFORM=offscreen plasma-apply-colorscheme Carl
kwriteconfig6 --file kdeglobals --group Colors:Window --key ForegroundNegative "218,68,83"
kwriteconfig6 --file kdeglobals --group Colors:Window --key ForegroundNeutral "246,116,0"
kwriteconfig6 --file kdeglobals --group Colors:Window --key ForegroundPositive "39,174,96"
dbus-send --session --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:0 int32:0 || true
kwriteconfig6 --file plasmarc --group Theme --key name default
kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Classic
kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 20
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__Utterly-Round-Dark
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "N"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"
kwriteconfig6 --file auroraerc --group Utterly-Round-Dark --key ButtonSize 0
kwriteconfig6 --file ksplashrc --group KSplash --key Engine none

kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9

kwriteconfig6 --file kdeglobals --group "$fd" --key "Speedbar Width" 106

kwriteconfig6 --file dolphinrc --group IconsMode --key PreviewSize 48
kwriteconfig6 --file dolphinrc --group "$fd" --key "Places Icons Auto-resize" false
kwriteconfig6 --file dolphinrc --group "$fd" --key "Places Icons Static Size" 22

kwriteconfig6 --file systemsettingsrc --group systemsettings_sidebar_mode --key HighlightNonDefaultSettings true

# Start with an empty session at login
kwriteconfig6 --file ksmserverrc --group General --key loginMode emptySession

# Shortcuts: launcher on Meta+A (freed from "next activity") and Overview on Meta
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate application launcher" $'Meta+A\tAlt+F1,Meta\tAlt+F1,Activate Application Launcher'
kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "next activity" "none,none,Walk through activities"
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key Overview "Meta,Meta+W,Toggle Overview"

# GTK apps: global menu
sudo apt-get install -y --no-install-recommends appmenu-gtk3-module
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-modules appmenu-gtk-module
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-shell-shows-menubar 1

# Lock screen: no automatic lock on inactivity
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false

# Login screen (SDDM): Breeze theme, same look as the lock screen
sudo apt-get install -y --no-install-recommends sddm-theme-breeze

# Lock and login screens: the desktop wallpaper, if one was chosen
wallpaper=$DATA/wallpapers/wallpaper.png
if [ -f "$wallpaper" ]; then
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General \
        --key Image "file://$wallpaper"
    sudo install -Dm644 "$wallpaper" /usr/local/share/wallpapers/wallpaper.png
    printf '[General]\nbackground=/usr/local/share/wallpapers/wallpaper.png\n' |
        sudo tee /usr/share/sddm/themes/breeze/theme.conf.user >/dev/null
fi

# Makes the panels of the default Plasma style (Breeze) transparent, black only when a window is maximized.
system_theme=/usr/share/plasma/desktoptheme/default
user_theme=~/.local/share/plasma/desktoptheme/default
rm -rf "$user_theme"
mkdir -p "$user_theme"
cp "$system_theme/metadata.json" "$system_theme/plasmarc" "$user_theme"
kwriteconfig6 --file "$user_theme/plasmarc" --group ContrastEffect --key enabled false
kwriteconfig6 --file "$user_theme/plasmarc" --group BlurBehindEffect --key enabled false
for variant in widgets translucent/widgets solid/widgets; do
    color=transparent
    [ "$variant" = solid/widgets ] && color="#000000"
    system_file=$(ls "$system_theme/$variant"/panel-background.svg*)
    user_file=$user_theme/$variant/$(basename "$system_file")
    mkdir -p "$user_theme/$variant"
    zcat -f "$system_file" |
        sed "s/currentColor/$color/g; s/#000000/$color/g" |
        { [ "$color" = transparent ] && sed 's/stop-opacity:[.0-9]*/stop-opacity:0/g' || cat; } |
        { [ "${user_file##*.}" = svgz ] && gzip -9 || cat; } > "$user_file"
done

# Panels and wallpaper: applied now if Plasma is running, otherwise at the first login
session_setup=$DATA/mytheme/session-setup.sh
mkdir -p "$DATA/mytheme"
cat > "$session_setup" <<'EOF'
#!/bin/bash
set -e
rm -rf ~/.config/autostart/mytheme-setup.desktop ~/.local/share/mytheme

# Apply window button layout for GTK apps
python3 -c "from gi.repository import Gio;Gio.Settings.new('org.gnome.desktop.wm.preferences').set_string('button-layout','menu:minimize,maximize,close');Gio.Settings.sync()"

dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure

# Desktop wallpaper, if one was chosen
if [ -f ~/.local/share/wallpapers/wallpaper.png ]; then
    plasma-apply-wallpaperimage ~/.local/share/wallpapers/wallpaper.png
fi

# Bottom dock and top bar
dock_id=$(dbus-send --session --type=method_call --print-reply=literal --dest=org.kde.plasmashell \
    /PlasmaShell org.kde.PlasmaShell.evaluateScript string:'
panels().forEach(function (panel) { panel.remove(); });

var dock = new Panel;
dock.location = "bottom";
dock.height = 40;
dock.hiding = "dodgewindows";
dock.lengthMode = "fit";
var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "applications:brave-browser.desktop,preferred://filemanager,applications:org.kde.konsole.desktop,applications:com.microsoft.VSCode.desktop,applications:spotify.desktop");
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
tray.writeConfig("extraItems", "org.kde.plasma.manage-inputmethod,org.kde.plasma.bluetooth,org.kde.plasma.battery,org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.volume,org.kde.plasma.cameraindicator,org.kde.plasma.brightness,org.kde.plasma.mediacontroller,org.kde.plasma.keyboardlayout,org.kde.plasma.networkmanagement");
var kicker = bar.addWidget("org.kde.plasma.kicker");
kicker.currentConfigGroup = ["General"];
kicker.writeConfig("alignResultsToBottom", "false");
kicker.writeConfig("showRecentApps", "false");
kicker.writeConfig("showRecentDocs", "false");
kicker.writeConfig("useExtraRunners", "false");
print(dock.id);
')

# Dock: always transparent. Top bar: adaptive (transparent, black when a window is maximized)
dock_id=$(echo "$dock_id" | tr -dc '0-9')
kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $dock_id" --key panelOpacity 2

# Launcher favorites: only System Settings
favorites() {
    dbus-send --session --type=method_call --dest=org.kde.ActivityManager /ActivityManager/Resources/Linking \
        org.kde.ActivityManager.ResourcesLinking."$1" string:org.kde.plasma.favorites.applications string:"$2" string::global
}
favorites LinkResourceToActivity applications:systemsettings.desktop
for resource in $(python3 -c "import os, sqlite3; [print(r) for r, in sqlite3.connect('file:' + os.path.expanduser('~/.local/share/kactivitymanagerd/resources/database') + '?mode=ro', uri=True).execute(\"SELECT targettedResource FROM ResourceLink WHERE initiatingAgent = 'org.kde.plasma.favorites.applications' AND usedActivity = ':global' AND targettedResource != 'applications:systemsettings.desktop'\")]"); do
    favorites UnlinkResourceFromActivity "$resource"
done

# Restart plasmashell once, so it reloads the Plasma style, icons, panels and their opacity
rm -rf ~/.cache/ksvg-elements* ~/.cache/plasma_theme_*
systemctl --user restart plasma-plasmashell
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
