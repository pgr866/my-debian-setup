#!/bin/bash
set -e

# Define source, destination, and configuration paths
SOURCE="/media/$USER/HARDDRIVE"
DESTINATION="google_drive:HARDDRIVE"
CONFIG_DIR="$HOME/.config/rclone"
CONFIG_FILE="$CONFIG_DIR/rclone.conf"
CONFIG_BACKUP="$SOURCE/rclone.conf"

# Verify if the hard drive is mounted before proceeding
if mountpoint -q "$SOURCE"; then
  # Check if rclone configuration exists; if not, restore it from the backup on the hard drive
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Rclone config not found in system. Restoring from drive..."
    mkdir -p "$CONFIG_DIR"
    cp "$CONFIG_BACKUP" "$CONFIG_FILE"
  fi

  # Sync the local hard drive directory with the remote Google Drive destination
  rclone sync "$SOURCE" "$DESTINATION" --progress
else
  # Exit with an error message if the mount point is not detected
  echo "Error: Drive not mounted at $SOURCE"
  exit 1
fi
