# Sway Window Manager

*Essential Shortcuts & Reference Guide*

`Mod` is the Super (Windows) key.

### 1. System and applications

| Shortcut | Description | 
| ----- | ----- | 
| `Mod` + `Enter` | Open terminal | 
| `Mod` + `d` | Open application launcher | 
| `Mod` + `Shift` + `q` | Close focused window | 
| `Mod` + `Shift` + `c` | Reload Sway config | 
| `Mod` + `Shift` + `e` | Exit Sway (log out, asks for confirmation) | 
| `Mod` + `Escape` | Lock screen | 
| `Mod` + `Shift` + `v` | Clipboard history | 
| `Print` | Screenshot of a selected area (saved in `~/Pictures` and copied to the clipboard) | 
| `Brightness` keys | Screen brightness down / up | 
| `Volume` keys | Volume down / up / mute | 
| `Mic mute` key | Mute / unmute the microphone | 

### 2. Navigation & movement

| Shortcut | Description | 
| ----- | ----- | 
| `Mod` + `Arrows` | Move focus | 
| `Mod` + `Shift` + `Arrows` | Move window | 
| `Mod` + `h` `j` `k` `l` | Move focus (vim keys: left, down, up, right) | 
| `Mod` + `Shift` + `h` `j` `k` `l` | Move window (vim keys) | 
| `Mod` + `a` | Focus parent container | 

### 3. Layout and window modes

| Shortcut | Description | 
| ----- | ----- | 
| `Mod` + `b` | Split next horizontally | 
| `Mod` + `v` | Split next vertically | 
| `Mod` + `e` | Toggle split orientation | 
| `Mod` + `s` | Switch to stacking mode | 
| `Mod` + `w` | Switch to tabbed mode | 
| `Mod` + `f` | Toggle fullscreen mode | 
| `Mod` + `Shift` + `Space` | Toggle floating/tiling | 
| `Mod` + `Space` | Switch floating/tiled focus | 

### 4. Resize mode

| Shortcut | Description | 
| ----- | ----- | 
| `Mod` + `r` | Enter resize mode | 
| `Arrows` or `h` `j` `k` `l` | Resize the window (while in resize mode) | 
| `Enter` or `Esc` | Leave resize mode | 

### 5. Hidden windows (scratchpad)

| Shortcut | Description | 
| ----- | ----- | 
| `Mod` + `Shift` + `-` | Send to scratchpad | 
| `Mod` + `-` | Show / hide scratchpad | 

### 6. Virtual desktops (workspaces) and displays

| Shortcut | Description | 
| ----- | ----- | 
| `Mod` + `[1-9]`, `Mod` + `0` | Switch to corresponding workspace (`0` is workspace 10) | 
| `Mod` + `Shift` + `[1-9]` | Move focused window to selected workspace | 

### 7. Mouse and status bar

| Action | Description | 
| ----- | ----- | 
| `Mod` + drag with left button | Move a floating window | 
| `Mod` + drag with right button | Resize a floating window | 
| Click on the bell | Toggle Do Not Disturb | 
| Right click on the bell | Clear the notification history | 
| Hover over the bell | Show the latest notifications (a dot means there are some) | 
| Click / scroll on volume or microphone | Mute / change the level | 
| Hover over volume or microphone | Show the level and the audio device in use | 
| Scroll on brightness | Change the screen brightness | 
| Click on Wi-Fi / Bluetooth | Menu to connect to a network / device | 
| Click / scroll on the energy profile | Cycle / switch the profile | 
| Hover over the clock | Show the calendar (scroll to change month) | 
| Click on the power icon | Open the power menu | 

### 8. Wi-Fi and Bluetooth

Clicking the Wi-Fi or Bluetooth icon opens a menu to connect: pick a network (it asks for the password if it is a new protected one) or a device (`+ scan` searches for new ones; choosing the one that is connected disconnects it; `*` marks the connected ones). For anything beyond that (hidden networks, passkey confirmation, forgetting a device...) use the commands below in a terminal.

| Wi-Fi command | Description | 
| ----- | ----- | 
| `nmtui` | Menu to connect: choose "Activate a connection", pick the network and enter the password | 
| `nmcli device wifi list` | Lists the Wi-Fi networks in range | 
| `nmcli device wifi connect <name> password <password>` | Connects to a network | 
| `nmcli connection show` | Lists the saved connections | 
| `nmcli radio wifi on` / `off` | Turns the Wi-Fi on / off | 

| Bluetooth command (inside `bluetoothctl`) | Description | 
| ----- | ----- | 
| `power on` | Turns the adapter on | 
| `discoverable on` / `off` | Makes your PC visible to other devices, needed to pair starting from the phone | 
| `scan on` / `scan off` | Starts / stops searching for devices | 
| `devices` | Lists the devices found, with their address | 
| `pair <address>` | Pairs with a device | 
| `trust <address>` | Allows the device to reconnect by itself | 
| `connect <address>` | Connects to a device | 
| `disconnect <address>` | Disconnects from a device | 
| `remove <address>` | Forgets a device | 
| `exit` | Closes `bluetoothctl` | 

If a device asks to pair with you, the question (for example "Confirm passkey 123456 (yes/no)") appears only while `bluetoothctl` is open; answer `yes`. With it closed there is no notification and the request is rejected.

### 9. Terminal (foot)

| Shortcut | Description | 
| ----- | ----- | 
| `Ctrl` + `Shift` + `c` | Copy | 
| `Ctrl` + `Shift` + `v` | Paste | 
| `Ctrl` + `+` / `Ctrl` + `-` | Zoom in / out | 
| `Shift` + `Page Up` / `Page Down` | Scroll the history | 
| `Ctrl` + `Shift` + `r` | Search in the history | 

### 10. Utility commands (terminal)

| Command | Description | 
| ----- | ----- | 
| `swaymsg -t get_tree` | Displays JSON tree structure of active windows and workspaces | 
| `swaymsg -t get_outputs` | Displays information about connected monitors and resolutions | 
| `udiskie-umount --all` | Unmounts all the removable drives (they are mounted automatically when plugged in, under `/media/<user>/<label>`) | 
| `wpctl status` | Lists the audio devices: outputs (Sinks) and inputs (Sources), each with a number; `*` marks the one in use | 
| `wpctl set-default <number>` | Chooses the audio device (output or input) with that number | 
