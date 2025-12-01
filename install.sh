#!/bin/bash

# --- Configuration ---
# Define the list of packages to install using yay
PACKAGES=(
    # Hyprland and core window management
    hyprland
    hyprlock       # Screen Locker (Added per user request)
    
    # User-defined components from README.md
    kitty          # Terminal Emulator
    rofi           # Application Launcher
    fish           # Shell
    fastfetch      # System Info Display
    
    # Bar from credits (assuming this is an AUR package)
    noctalia-shell-git 
    
    # *** REQUIRED ADDITIONS FOR AUTHENTICATION/CREDENTIALS ***
    polkit-gnome   # PolicyKit authentication agent
    gnome-keyring  # Credential storage
    
    # Example dependencies (adjust as needed)
    dunst          # Notification daemon
    swaybg         # Simple wallpaper utility (used for setting wallpapers)
    xorg-xwayland  # X11 compatibility layer
    brightnessctl  # Screen control
    pavucontrol    # PulseAudio/PipeWire volume control
    kate           # KDE Advanced Text Editor
    gedit          # GNOME Text Editor
    nemo           # File Manager (Added per user request)
)

REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

# --- Functions ---

# Check if yay is installed, if not, install it
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "yay not found. Installing yay..."
        sudo pacman -S --needed git base-devel
        # FIX: Removed Markdown link syntax which caused a Bash syntax error
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    else
        echo "yay is already installed."
    fi
}

# Deploy configuration files
deploy_configs() {
    echo "Deploying configuration files..."
    
    # NEW FIX: Set the root of the configuration files within the repository
    CONFIG_SOURCE_ROOT="$REPO_DIR/.config"
    
    # Check if the .config directory actually exists in the repository
    if [ ! -d "$CONFIG_SOURCE_ROOT" ]; then
        echo "FATAL ERROR: Could not find the '.config' directory inside your repository at '$REPO_DIR'."
        echo "Please ensure all configuration folders (hypr, kitty, etc.) are placed inside a '.config' directory."
        return # Stop execution of this function
    fi

    # Iterate over the configuration directory names (all lowercase in the repo)
    for component in hypr kitty rofi fastfetch fish; do
        SOURCE_NAME="$component" 
        TARGET_NAME="$component" 
        
        # CORRECTED SOURCE PATH: now points to /repo/.config/component
        SOURCE_PATH="$CONFIG_SOURCE_ROOT/$SOURCE_NAME"
        TARGET_PATH="$CONFIG_DIR/$TARGET_NAME"
        
        # Check 1: Ensure the source directory (in the repo's .config folder) exists
        if [ ! -d "$SOURCE_PATH" ]; then
            echo "Error: Source configuration directory '$SOURCE_NAME' not found at '$SOURCE_PATH'."
            echo "Please ensure the folder '$SOURCE_NAME' exists inside your .config subdirectory."
            continue # Skip deployment for this component
        fi

        # Check 2: Backup existing target directory if it exists
        if [ -d "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
            TIMESTAMP=$(date +%Y%m%d%H%M%S)
            echo "Existing $TARGET_NAME config found. Creating backup: $TARGET_PATH.bak.$TIMESTAMP"
            mv "$TARGET_PATH" "$TARGET_PATH.bak.$TIMESTAMP"
        fi
        
        # Create symbolic link -> CHANGED TO COPY (cp -a)
        echo "Copying $TARGET_NAME configuration: $SOURCE_PATH -> $TARGET_PATH"
        cp -a "$SOURCE_PATH" "$TARGET_PATH"
        
        # Check 3: Check if the copy operation was successful
        if [ $? -ne 0 ]; then
            echo "NON-FATAL ERROR: Failed to copy configuration files for $TARGET_NAME."
            echo "Possible causes: Incorrect permissions on $CONFIG_DIR or target path not writeable. Skipping..."
        fi
    done
}

# Set executable permissions for scripts
set_permissions() {
    # The source is linked to $CONFIG_DIR/hypr. The scripts path inside that link is 'Scripts'
    # Since we are copying now, $CONFIG_DIR/hypr/ is a real directory.
    
    # NOTE: The path for the scripts is now relative to the *target* location ($CONFIG_DIR)
    SCRIPTS_PATH="$CONFIG_DIR/hypr/Scripts"
    
    # Check if the scripts directory exists before trying to run chmod
    # This check will only pass IF the 'hypr' directory was successfully copied in deploy_configs
    if [ -d "$SCRIPTS_PATH" ]; then
        echo "Setting execution permissions for scripts..."
        # Use find to be robust against hidden files and ensure we only target files
        find "$SCRIPTS_PATH" -type f -exec chmod +x {} \;
    else
        echo "Warning: Hyprland scripts directory '$SCRIPTS_PATH' not found."
        echo "Ensure the 'hypr' directory was successfully copied and the 'Scripts' folder exists inside your new 'hypr' directory."
    fi
}

# --- Main Installation Flow ---

echo "Starting Hyprland Dotfiles Installation..."

# 1. Install Yay
install_yay

# 2. Install Packages
echo "Installing required packages via yay..."
yay -Syu --noconfirm "${PACKAGES[@]}"

# 3. Deploy Configurations
deploy_configs

# 4. Set Script Permissions
set_permissions

echo "Installation complete!"
echo "--------------------------------------------------------"
echo "Next Steps (Step 3):"
echo "1. Review customization points in README.md."
echo "2. Reboot your system."
echo "3. Select the Hyprland session at your login manager."
echo "--------------------------------------------------------"
