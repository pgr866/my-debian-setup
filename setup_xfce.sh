#!/bin/bash
set -e

sudo apt-get install -y --no-install-recommends \
    xinit xserver-xorg-input-libinput \
    xfce4-session xfwm4 xfce4-panel xfce4-terminal # spice-vdagent
