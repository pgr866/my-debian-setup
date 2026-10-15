#!/bin/bash
set -e

sudo apt-get install -y --no-install-recommends xserver-xorg-input-libinput lightdm xfce4-session xfce4-panel xfwm4 xfdesktop4 xfce4-terminal thunar # spice-vdagent

sudo apt-get install -y --no-install-recommends xfce4-docklike-plugin

sudo apt-get install -y --no-install-recommends xfce4-appmenu-plugin appmenu-gtk3-module
sudo apt-get install -y --no-install-recommends xfce4-notifyd
sudo apt-get install -y --no-install-recommends adwaita-icon-theme
