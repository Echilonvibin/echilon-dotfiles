#!/bin/bash

# --- Configuration (Must match install.sh) ---
REPO_NAME="echilon-dotfiles"
INSTALL_DIR="$HOME/Source/$REPO_NAME"
CONFIG_DIR="$HOME/.config"
LOCAL_SHARE_DIR="$HOME/.local/share"

# List of configuration files/directories that were installed into ~/.config
CONFIG_TARGETS=(
    "hypr"
    "rofi"
    "kitty"
    "fish"
    "starship.toml"
    "fastfetch"
)

# List of theming files/folders that were installed into ~/.local/share/themes
THEME_TARGETS=(
    "themes"
)

# List of icon files/folders that were installed into ~/.local/share/icons
ICON_TARGETS=(
    "icons"
)

# --- Functions ---

# Function to prompt the user for confirmation
confirm_action() {
    read -r -p "Are you sure you want to proceed with uninstallation? (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            echo "Uninstallation cancelled by user. Exiting."
            exit 1
            ;;
    esac
}

# Function to restore backups for a given directory set
restore_backups() {
    local targets=("${!1}") # Get array reference
    local dest_dir="$2"
    local config_type="$3"

    echo -e "\n--- Restoring $config_type Backups in $dest_dir ---"
    
    for target in "${targets[@]}"; do
        FULL_PATH="$dest_dir/$target"
        
        # 1. Check for and remove the currently deployed file/directory
        if [ -d "$FULL_PATH" ] || [ -f "$FULL_PATH" ] || [ -L "$FULL_PATH" ]; then
            echo "-> Deleting currently deployed: $FULL_PATH"
            rm -rf "$FULL_PATH"
        fi

        # 2. Check for the backup file
        BACKUP_FILE=$(find "$dest_dir" -maxdepth 1 -type f -name "$target.bak.*" -o -name "$target.bak.*" -type d | sort -r | head -n 1)

        if [ -n "$BACKUP_FILE" ]; then
            # Found a backup, restore it
            echo "-> Restoring backup: $(basename "$BACKUP_FILE") to $target"
            mv "$BACKUP_FILE" "$FULL_PATH"
        else
            echo "-> No backup found for $target. Clean removal completed."
        fi
    done
}

# --- Main Execution ---

echo "======================================================"
echo " Starting Hyprland Dotfiles Uninstallation (Reverse Operation)"
echo "======================================================"

confirm_action

# 1. Restore .config backups
restore_backups CONFIG_TARGETS[@] "$CONFIG_DIR" "Configuration"

# 2. Restore .local/share/themes backups (using the array name as reference)
restore_backups THEME_TARGETS[@] "$LOCAL_SHARE_DIR/themes" "Theme"

# 3. Restore .local/share/icons backups (using the array name as reference)
restore_backups ICON_TARGETS[@] "$LOCAL_SHARE_DIR/icons" "Icon"

# 4. Remove the cloned repository
echo -e "\n--- Removing Cloned Repository ---"
if [ -d "$INSTALL_DIR" ]; then
    echo "-> Deleting repository folder: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
else
    echo "-> Repository folder not found at $INSTALL_DIR. Skipping removal."
fi

echo "======================================================"
echo "Uninstallation Complete!"
echo "Your original configuration files have been restored from backups."
echo "======================================================"
echo "⚠️ NEXT STEPS: MANUAL PACKAGE REMOVAL ⚠️"
echo "The installed software packages (Hyprland, Kitty, Rofi, etc.) were NOT automatically removed."
echo "If you wish to remove them, please use the following commands:"
echo ""
echo "--- Official/Common Packages (Requires sudo) ---"
echo ""
echo "--- AUR Packages (Requires yay) ---"
echo "yay -Rns noctalia-shell-git missioncenter yt-dlp warehouse linux-wallpaperengine-git upscaler video-downloader"
echo "======================================================"
