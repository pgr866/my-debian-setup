#!/bin/bash

# Stop all running Docker containers, ignoring errors if none are running
docker stop $(docker ps -q) 2>/dev/null || true

# Remove all unused containers, networks, and images (forcefully, without prompt)
docker system prune -af

# Remove all unused local volumes (forcefully, without prompt)
docker volume prune -af
