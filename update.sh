#!/bin/bash
set -e

# Update the local package index
sudo apt-get update

# Perform a system-wide upgrade, handling dependencies intelligently
sudo apt-get dist-upgrade -y

# Remove unnecessary packages and purge their configuration files
sudo apt-get autoremove -y --purge

# Clean the local repository of retrieved package files
sudo apt-get clean

# Keep only the last 7 days of system logs to save disk space
sudo journalctl --vacuum-time=7d 2>/dev/null || true
