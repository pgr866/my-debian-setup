#!/bin/bash
set -e

# Install NVIDIA driver
sudo find /etc/apt -maxdepth 2 \( -name sources.list -o -name debian.sources \) -exec sed -i -E '/^(deb .* main|Components:)/ { /(\s|$)contrib(\s|$)/! s/$/ contrib/; /(\s|$)non-free(\s|$)/! s/$/ non-free/ }' {} +
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y linux-headers-amd64 nvidia-driver

# Hybrid graphics: apps marked "Run using dedicated graphics card" (PrefersNonDefaultGPU) start on the NVIDIA GPU
sudo apt-get install -y --no-install-recommends switcheroo-control

# Disable the NVIDIA persistence daemon
sudo systemctl disable nvidia-persistenced.service

# Keep NVIDIA video memory across suspend (needed on Wayland), saved to disk instead of the /tmp tmpfs
printf 'options nvidia-current NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp\n' |
    sudo install -m644 /dev/stdin /etc/modprobe.d/nvidia-power.conf

# Enable kernel modesetting
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/ nvidia-drm.modeset=1//g; /^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
sudo update-initramfs -u
sudo update-grub

# Check NVIDIA driver is working after reboot
# nvidia-smi
# lspci -knn
