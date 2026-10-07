#!/bin/bash
set -e

# Define source, destination, and configuration paths
SOURCE="/media/$USER/HARDDRIVE"
DESTINATION="google_drive:HARDDRIVE"
CONFIG_FILE="$SOURCE/rclone.conf"

# Verify if the hard drive is mounted before proceeding
if mountpoint -q "$SOURCE"; then
  # Verify the rclone configuration exists on the hard drive
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Rclone config not found at $CONFIG_FILE"
    exit 1
  fi

  # Sync the local hard drive directory with the remote Google Drive destination
  rclone sync "$SOURCE" "$DESTINATION" --config "$CONFIG_FILE" --progress
else
  # Exit with an error message if the mount point is not detected
  echo "Error: Drive not mounted at $SOURCE"
  exit 1
fi
