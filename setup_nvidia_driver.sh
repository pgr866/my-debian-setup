#!/bin/bash
set -e

# Install NVIDIA driver
sudo sed -i '/^deb .* main/ { /\(\s\|$\)contrib\(\s\|$\)/! s/$/ contrib/; /\(\s\|$\)non-free\(\s\|$\)/! s/$/ non-free/ }' /etc/apt/sources.list
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y linux-headers-$(uname -r) nvidia-driver
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/ nvidia-drm.modeset=1//g; /^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules
sudo update-initramfs -u
sudo update-grub

# Check NVIDIA driver is working after reboot
# nvidia-smi
# lspci -knn
