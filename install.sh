#!/bin/bash

# --- Configuration ---
REPO_NAME="echilon-dotfiles"
REPO_URL="https://github.com/Gamma195/$REPO_NAME.git"
INSTALL_DIR="$HOME/Source/$REPO_NAME"
CONFIG_DIR="$HOME/.config"
LOCAL_SHARE_DIR="$HOME/.local/share"

# --- Unified Package List (Installed via yay) ---
ALL_PACKAGES=(
    hyprland hyprctl rofi nemo vivaldi code kvantum qt5-base qt6-base gtk3
    grim slurp wayland-protocols wget imagemagick
    fish starship kitty fastfetch
    noctalia-shell-git missioncenter yt-dlp warehouse
    linux-wallpaperengine-git upscaler video-downloader
)

# List of configuration directories/files to back up and copy into ~/.config
CONFIG_TARGETS=(
    "hypr"
    "rofi"
    "kitty"
    "fish"
    "starship.toml"
    "fastfetch"
)

# List of theming files/folders to copy into ~/.local/share/themes
THEME_TARGETS=(
    "themes"
)

# List of icon files/folders to copy into ~/.local/share/icons
ICON_TARGETS=(
    "icons"
)

# --- Functions ---

# Function to prompt the user with choices
user_choice() {
    local prompt_message="$1"
    local default_action="${2:-P}" # P=Proceed, S=Skip, E=Exit

    echo -e "\n========================================================================="
    echo -e "$prompt_message"
    echo -e "-------------------------------------------------------------------------"
    echo -e "Choices: (P) Proceed | (S) Skip this step | (E) Exit the script"
    read -r -p "Enter your choice [${default_action}]: " response
    response=${response:-$default_action} # Use default if empty
    RESPONSE_UCASE=$(echo "$response" | tr '[:lower:]' '[:upper:]')
    echo "========================================================================="

    case "$RESPONSE_UCASE" in
        P) return 0 ;; # Proceed
        S) return 1 ;; # Skip
        E) echo "Script terminated by user. Exiting." ; exit 0 ;;
        *) echo "Invalid choice. Please try again." ; user_choice "$1" "$2" ;;
    esac
}

# MANDATORY CHECK: Ensure yay (AUR helper) is installed.
ensure_yay_is_installed() {
    echo "--- INITIAL CHECK: ENSURING YAY IS INSTALLED ---"
    if ! command -v yay &> /dev/null; then
        echo "Yay (AUR helper) not found. This is required for installation."
        echo "Installing prerequisite packages: base-devel and git."
        sudo pacman -S --noconfirm base-devel git

        echo "Cloning and building yay. You may be prompted for your password."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay

        if command -v yay &> /dev/null; then
            echo "SUCCESS: Yay installed successfully."
        else
            echo "ERROR: Failed to install yay. Cannot proceed with package installation. Exiting."
            exit 1
        fi
    else
        echo "Yay is already installed. Skipping installation."
    fi
}

# Install necessary packages using yay
install_packages() {
    local message="--- STEP 1: INSTALLING ALL REQUIRED PACKAGES ---\n"
    message+="This step will install all system packages needed for Hyprland and all accompanying tools (Kitty, Rofi, Fish, etc.) using 'yay'.\n"
    message+="This includes both official Arch packages and AUR packages. You may be prompted for your password multiple times."

    if user_choice "$message"; then
        echo "Executing: yay -Syu --noconfirm ${ALL_PACKAGES[@]}"
        yay -Syu --noconfirm "${ALL_PACKAGES[@]}"
        echo "SUCCESS: All packages installed."
    else
        echo "Skipping package installation (Step 1)."
    fi
}

# Helper function to handle copying and backup logic
copy_with_backup() {
    local target="$1"
    local source_dir="$2"
    local dest_dir="$3"

    # Create the destination directory if it doesn't exist (e.g., ~/.local/share/themes)
    mkdir -p "$dest_dir"

    REPO_PATH="$source_dir/$target"
    FULL_PATH="$dest_dir/$target"

    # CRITICAL: If the target exists (is a file or directory), back it up.
    if [ -d "$FULL_PATH" ] || [ -f "$FULL_PATH" ] || [ -L "$FULL_PATH" ]; then
        # Create a timestamped backup
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        BACKUP_NAME="$target.bak.$TIMESTAMP"

        echo "-> Backing up existing $target in $(basename "$dest_dir") to $BACKUP_NAME"
        mv "$FULL_PATH" "$dest_dir/$BACKUP_NAME"
    fi

    # COPY the entire folder/file from the cloned repo into the destination
    echo "-> Copying configuration files for $target: $REPO_PATH -> $FULL_PATH"
    cp -r "$REPO_PATH" "$FULL_PATH"
}


# Deploy dotfiles by COPYING files into ~/.config/ and themes/icons into ~/.local/share/
deploy_dots() {
    local message="--- STEP 2: DEPLOYING DOTFILES (CREATING BACKUPS AND COPYING FILES) ---\n"
    message+="This step will clone the repository and then **copy** all configuration folders directly into your ~/.config and ~/.local/share directories. This gives you immediate, full control over the files, but they will not be automatically updated with Git.\n"
    message+="Existing configuration folders will be backed up."

    if user_choice "$message"; then

        echo "--- Executing Deployment ---"

        # Clone the repository to get the files
        if [ -d "$INSTALL_DIR" ]; then
            echo "Repository already cloned at $INSTALL_DIR. Skipping clone."
        else
            echo "Cloning $REPO_URL to $INSTALL_DIR..."
            git clone "$REPO_URL" "$INSTALL_DIR"
        fi

        # --- 2A: Copy Configurations (e.g., ~/.config/hypr) ---
        for target in "${CONFIG_TARGETS[@]}"; do
            copy_with_backup "$target" "$INSTALL_DIR/.config" "$CONFIG_DIR"
        done

        # --- 2B: Copy Themes (e.g., ~/.local/share/themes) ---
        for target in "${THEME_TARGETS[@]}"; do
            copy_with_backup "$target" "$INSTALL_DIR/.local/share" "$LOCAL_SHARE_DIR"
        done

        # --- 2C: Copy Icons (e.g., ~/.local/share/icons) ---
        for target in "${ICON_TARGETS[@]}"; do
            copy_with_backup "$target" "$INSTALL_DIR/.local/share" "$LOCAL_SHARE_DIR"
        done

        echo "SUCCESS: Dotfiles, Themes, and Icons copied directly. Original files backed up."
    else
        echo "Skipping dotfiles deployment (Step 2)."
    fi
}

# Final permission adjustments
set_permissions() {
    local message="--- STEP 3: SETTING SCRIPT PERMISSIONS ---\n"
    message+="This step ensures necessary scripts, like the Hyprland keyhints and startup scripts, have executable permissions (chmod +x) to function correctly."

    if user_choice "$message"; then

        echo "--- Executing Permission Setup ---"
        # Since files are copied directly, we need to use the target path
        chmod +x "$CONFIG_DIR/hypr/Scripts/keyhints"
        chmod +x "$CONFIG_DIR/hypr/Scripts/show-keyhints.sh"

        echo "SUCCESS: Script permissions set."
    else
        echo "Skipping permission setup (Step 3)."
    fi
}


# --- Main Execution ---

echo "=========================================="
echo " Starting Interactive Hyprland Dotfiles Installation (FILE COPY MODE) "
echo "=========================================="

# 0. MANDATORY STEP: Ensure yay is installed first.
ensure_yay_is_installed

# 1. Install all packages via yay
install_packages

# 2. Deploy dotfiles and set up symlinks
deploy_dots

# 3. Set script permissions
set_permissions

echo "=========================================="
echo "Installation Complete!"
echo "All selected steps are finished. The configuration files are now fully editable in your ~/.config directory."
echo "1. Reboot or log out and select the Hyprland session."
echo "2. Remember to check your monitor settings and theming notes in the configurations!"
