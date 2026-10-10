#!/bin/bash
set -e

sudo apt-get install -y --no-install-recommends \
    xserver-xorg-input-libinput xinit \
    xfce4-session xfwm4 xfce4-panel xfce4-terminal # spice-vdagent
