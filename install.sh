#!/bin/bash

# --- Configuration ---
# Define the list of packages to install using yay to install from AUR
PACKAGES=(
    # Core Components
    polkit-gnome   # PolicyKit authentication agent
    gnome-keyring  # Credential storage  
    hyprlock       # Locks screen, obviously. 
    hypridle       # Turns off screen after set time
    dunst          # Notification daemon
    swaybg         # Simple wallpaper utility (used for setting wallpapers)
    xorg-xwayland  # X11 compatibility layer
    brightnessctl  # Screen control
    pavucontrol    # PulseAudio/PipeWire volume control
    wlsunset       # Nightlight for quickshell
    noctalia-shell-git # Bar from noctalia
    rofi           # Application Launcher
    fish           # Shell
    fastfetch      # System Info Display
    gedit          # Gnome Advanced Text Editor
    nautilus           # File Manager  
    bluez          # Bluetooth utlities
    blueman        # Bluetooth utlities 
    satty          # Screenshot annotation tool
    grim           # Screenshot utility for wayland
    slurp          # Screenshot selector for region
    hyprshot       # Screenshot selector region - this is a standalone app
    firefox        # Browser
    starship-git       # custom configuration for fish
)



OPTIONALPKG=(
        # User-defined components
    upscayl-bin    # Upscaler for images on the fly
    video-downloader # Download videos on your system, avoid sketchy websites! Yipee!
    gnome-calculator # Math n stuff...
    loupe          # image viewer
    gcolor3        # color picker
    protonplus     # proton manager
    mission-center #Task Manager, Sleak
    
)


REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

# --- Functions ---

# Check if yay is installed, if not, install it
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "yay not found. Installing yay..."
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    else
        echo "yay is already installed."
    fi
}

# Function to handle optional package installation (MOVED TO FUNCTIONS BLOCK)
install_optional_packages() {
    echo -e "\n--- Optional Packages Installation ---"
    read -r -p "Do you want to install the optional packages? (y/N): " response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Installing optional packages via yay..."
        yay -Syu --noconfirm "${OPTIONALPKG[@]}"
    else
        echo "Skipping optional package installation."
    fi
}


# Deploy configuration files from repo/.config to ~/.config
deploy_configs() {
    echo "Deploying configuration files..."
    
    CONFIG_SOURCE_ROOT="$REPO_DIR/.config"
    
    if [ ! -d "$CONFIG_SOURCE_ROOT" ]; then
        echo "FATAL ERROR: Could not find the '.config' directory inside your repository at '$REPO_DIR'."
        return
    fi

    for component in hypr kitty rofi fastfetch fish; do
        SOURCE_PATH="$CONFIG_SOURCE_ROOT/$component"
        TARGET_PATH="$CONFIG_DIR/$component"
        
        if [ ! -d "$SOURCE_PATH" ]; then
            echo "Error: Source configuration directory '$SOURCE_PATH' not found."
            continue
        fi

        if [ -d "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
            TIMESTAMP=$(date +%Y%m%d%H%M%S)
            echo "Existing $component config found. Creating backup: $TARGET_PATH.bak.$TIMESTAMP"
            mv "$TARGET_PATH" "$TARGET_PATH.bak.$TIMESTAMP"
        fi
        
        echo "Copying $component configuration: $SOURCE_PATH -> $TARGET_PATH"
        cp -a "$SOURCE_PATH" "$TARGET_PATH"
        
        if [ $? -ne 0 ]; then
            echo "NON-FATAL ERROR: Failed to copy configuration files for $component."
        fi
    done
}

# Deploy files from repo/.local/share to ~/.local/share
deploy_local_share() {
    echo "Deploying local share files..."
    
    LOCAL_SOURCE_ROOT="$REPO_DIR/.local/share"
    LOCAL_TARGET_ROOT="$HOME/.local/share"

    if [ ! -d "$LOCAL_SOURCE_ROOT" ]; then
        echo "No .local/share directory found in repo, skipping..."
        return
    fi

    mkdir -p "$LOCAL_TARGET_ROOT"

    echo "Copying $LOCAL_SOURCE_ROOT -> $LOCAL_TARGET_ROOT"
    cp -a "$LOCAL_SOURCE_ROOT"/* "$LOCAL_TARGET_ROOT"/

    if [ $? -ne 0 ]; then
        echo "NON-FATAL ERROR: Failed to copy files from .local/share."
    fi
}

# Set executable permissions for scripts
set_permissions() {
    SCRIPTS_PATH="$CONFIG_DIR/hypr/Scripts"
    
    if [ -d "$SCRIPTS_PATH" ]; then
        echo "Setting execution permissions for scripts..."
        find "$SCRIPTS_PATH" -type f -exec chmod +x {} \;
    else
        echo "Warning: Hyprland scripts directory '$SCRIPTS_PATH' not found."
    fi
}

# --- Main Installation Flow ---

echo "Starting Hyprland Dotfiles Installation..."

# 1. Install Yay
install_yay

# 2. Install Core Packages
echo "Installing required core packages via yay..."
echo "installing core packages in 3..."
echo "2..."
echo "1!"
yay -Syu --noconfirm "${PACKAGES[@]}"

# 3. Optional install packages (CALL ADDED HERE)
install_optional_packages

# 4. Deploy Configurations
deploy_configs
deploy_local_share

# 5. Set Script Permissions
set_permissions

echo "Installation complete!"
echo "--------------------------------------------------------"
echo "Next Steps:"
echo "1. Review customization points in README.md."
echo "2. Reboot your system."
echo "3. Select the Hyprland session at your login manager."
echo "--------------------------------------------------------"
