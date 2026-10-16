#!/bin/bash
set -e

# Install NVIDIA driver
sudo find /etc/apt -maxdepth 2 \( -name sources.list -o -name debian.sources \) -exec sed -i -E '/^(deb .* main|Components:)/ { /(\s|$)contrib(\s|$)/! s/$/ contrib/; /(\s|$)non-free(\s|$)/! s/$/ non-free/ }' {} +
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y linux-headers-amd64 nvidia-driver
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/ nvidia-drm.modeset=1//g; /^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
sudo update-initramfs -u
sudo update-grub

# Check NVIDIA driver is working after reboot
# nvidia-smi
# lspci -knn
