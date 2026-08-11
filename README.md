# My Debian Setup

A personal collection of shell scripts designed to automate the installation and configuration of **Debian 13 (Trixie)**.

This repository includes the following utilities:

- `debian_usb_maker.sh`: Creates a bootable Debian USB installer from an ISO, supporting automated installations via optional preseed configuration.
- `preseed.cfg`: My personal Debian 13 (Trixie) installer configuration. It provides a minimal installation with automated full-disk partitioning (atomic layout), keeping most installer settings at their default values while customizing the system for an English environment with Spanish keyboard, time, and regional settings. For further customization and advanced configuration options, please refer to the official [Debian Installer Preseed documentation](https://www.debian.org/releases/stable/amd64/apb.en.html).
- `wallpaper.png`: Place this file in the project root directory to have it automatically applied as your desktop background during installation.
- `setup_gnome.sh`: Installs a minimal GNOME desktop environment, applies custom UI preferences, configures Network Manager, and deploys essential GNOME extensions.
- `setup_nvidia_driver.sh`: Installs NVIDIA proprietary drivers, configures GRUB and kernel modesetting, and optimizes the system for graphics hardware compatibility.
- `setup_packages.sh`: Performs a full system upgrade, installs essential software, configures development environments (Git, VS Code, Docker, Terraform), and sets up user-specific desktop tools and media utilities.
- `install.sh`: The main orchestration script that downloads, configures, and executes all necessary utilities to fully provision your Debian environment.
- `update.sh`: Performs system-wide updates, removes obsolete dependencies, and cleans up temporary files and logs to maintain system health.
- `clear_docker.sh`: Cleans up unused Docker containers, networks, images, and volumes to reclaim disk space.
- `sync_hard_drive.sh`: Synchronizes local hard drive data to remote cloud storage using Rclone, including automated configuration management.

## Setup Instructions

Follow these steps to deploy your Debian 13 (Trixie) environment using this repository:

1.  **Download the ISO**: Obtain the official Debian 13 "Trixie" netinst ISO from the [official Debian website](https://www.debian.org).
2.  **Prepare the USB Installer**: 
    *   **From an existing Debian-based system**: Use the `debian_usb_maker.sh` script to create your bootable USB (minimum 2 GB). You will need to select your ISO file and the target USB drive. You can optionally provide your `preseed.cfg` file for a fully automated setup.
        ```bash
        ./debian_usb_maker.sh
        ```
    *   **Alternative**: Manually flash the ISO to a USB drive and manually configure your `preseed.cfg` during the installation process if desired.
3.  **Boot the System**: Restart your computer and boot from the USB drive (typically using **ESC**, **F11**, or **F12** during startup).
4.  **Launch Installation**: Select either **"Graphical Install"** or **"Install"** from the boot menu and press **Enter**.
5.  **Automated Provisioning**: If you included a `preseed.cfg` file, the installation will run automatically. Note that you will still need to select your network interface (Ethernet or Wi-Fi) and provide credentials if connecting via Wi-Fi.
6.  **Run the Installer**: Once Debian is installed, log in to your terminal and execute the following command to download and run the main orchestration script:
    ```bash
    wget -qO- https://raw.githubusercontent.com/pgr866/my-debian-setup/main/install.sh | bash
    ```
7.  **Complete**: The system will automatically reboot once the process is complete. Your Debian environment will be fully configured and ready for use!

## Customization & Safety

* **Review Before Running**: These scripts are tailored for my personal machine. Before running `install.sh`, I strongly recommend reviewing the contents of each script to ensure they align with your specific hardware and preferences (e.g., NVIDIA drivers, Docker settings, or package selections).
* **Safety**: Ensure you have a current backup of your data before running any installation or system configuration scripts.
* **Environment**: The repository is designed for **Debian 13 (Trixie)**. Behavior on other Debian versions or derivatives may vary.
* **License**: Feel free to fork this repository and adapt it to your workflow. If you find improvements or have suggestions, pull requests are always welcome.
