echilon-dotfiles

This is vibe coded, so i'm not entirely sure if she works or not yet. It's mainly for a friend of mine, so once he tests, i'll update as needed. 



⚠️ IMPORTANT: Customization Required

These dotfiles are provided as a template. You must review and customize several files to match your system paths, desired aesthetics, and hardware setup.

Key Customization Points:

File/Section

Customization Needed

hypr/hyprland.conf

Monitors: The current config uses monitor=,preferred,auto,1 for automatic detection. If you need specific resolutions, refresh rates, or scaling (e.g., HiDPI), you must uncomment and modify the manual monitor= examples.

hypr/keybindings.conf

Script Paths: Ensure the paths to executable scripts (like keyhints or other utility scripts) are correct for your system setup.

kitty/kitty.conf

Theming: The default theme settings are minimal. Add your preferred color schemes and font settings here.

fastfetch/config.jsonc

Theming/Images: If you want a specific image or ASCII art, update the relevant settings in this file.

📦 What's Included?

This repository provides configurations for a complete, customized Hyprland experience:

Component

Description

hypr

Main Hyprland configuration, keybinds, and workspace setup. (Requires customization)

kitty

Configuration for the primary terminal emulator.

fish

Configuration for the Fish shell and Starship prompt.

rofi

Custom themes and scripts for the application launcher.

fastfetch

Configuration for displaying system information.

install.sh

Automates package installation and configuration deployment.

uninstall-dots.sh

Reverts changes and restores previous configurations (if a backup exists).

🚀 Installation

Prerequisites

You must be running an Arch-based Linux distribution and have basic development tools installed.

Step 1: Download the Installer Script

Open your terminal and use wget to download the installation script directly to your home directory:

```
git clone https://github.com/Gamma195/echilon-dotfiles.git

```

```
cd ./echilon-dotfiles
```

Step 2: Run the Installation

Grant the script executable permission and run it. The script will handle everything: installing all required packages (including yay if necessary) 
and deploying the configuration files.

```
chmod +x install.sh
./install.sh
```

⚠️ Important Notes

Backup: The installer automatically backs up any existing configuration directories (e.g., ~/.config/hypr) by renaming them (e.g., ~/.config/hypr.bak.YYYYMMDDHHMMSS).

Dependencies: The script uses sudo pacman and yay to install all necessary packages.

Permissions: The script automatically sets execution permissions for the Hyprland scripts (e.g., keyhints).

Step 3: Finalize Setup

After the script completes:

Review the Customization Points detailed above.

Reboot your system.

At your login manager (SDDM, GDM, etc.), ensure you select the Hyprland session before logging in.

🗑️ Uninstallation

If you need to revert to your previous setup, use the uninstall-dots.sh script.

Step 1: Download the Uninstaller

Download the uninstaller script:

```
wget [https://raw.githubusercontent.com/Gamma195/echilon-dotfiles/main/uninstall-dots.sh](https://raw.githubusercontent.com/Gamma195/echilon-dotfiles/main/uninstall-dots.sh)
``` 


Step 2: Run the Uninstaller
```
Grant permissions and execute the script.

chmod +x uninstall.sh
```

```
./uninstall.sh
```

What the Uninstaller Does:

Restores Backups: It removes the symlinks pointing to this repository and restores your original configuration files from the timestamped .bak. directories created during installation.

Deletes Repository: It deletes the cloned repository located at ~/Source/echilon-dotfiles.

Manual Package Removal: It does not remove the packages (Hyprland, Kitty, Rofi, etc.). The script provides manual commands you must run if you wish to uninstall the software.

Once uninstallation is complete, log out and select your preferred desktop environment.
