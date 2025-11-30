#!/bin/bash

# --- Configuration ---
# DEFINITIVE REPOSITORY URL
DOTFILES_REPO="https://github.com/Gamma195/echilon-dotfiles"
INSTALL_DIR="$HOME/Source/echilon-dotfiles" # Where the repo will be cloned
CONFIG_DIR="$HOME/.config"         # Standard config directory

# --- Functions ---

# Function to check for yay and install it if missing
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "yay (AUR helper) not found. Installing it now..."
        sudo pacman -S --needed git base-devel --noconfirm
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    else
        echo "yay is already installed."
    fi
}

# Function to install all necessary packages
install_packages() {
    echo "Installing core Hyprland and utility packages..."

    # Core Hyprland components, essential Wayland utilities, and shell tools (installed via pacman)
    REQUIRED_PACKAGES=(
        hyprland hyprctl rofi nemo vivaldi code
        grim slurp wayland-protocols wget imagemagick
        fish starship kitty
    )

    # User-requested packages (AUR installation via yay)
    AUR_PACKAGES=(
        missioncenter
        yt-dlp
        warehouse
        linux-wallpaperengine-git
        upscaler
        video-downloader
    )

    # Use pacman for official repos
    sudo pacman -Syu --noconfirm "${REQUIRED_PACKAGES[@]}"

    # Use yay for AUR packages
    install_yay
    yay -S --noconfirm "${AUR_PACKAGES[@]}"

    echo "Package installation complete."
}

# Function to clone and deploy dotfiles
deploy_dots() {
    echo "Cloning dotfiles from $DOTFILES_REPO to $INSTALL_DIR..."

    # Clone the repository
    git clone "$DOTFILES_REPO" "$INSTALL_DIR" || { echo "Failed to clone repository. Exiting."; exit 1; }

    echo "Creating backups and symbolic links..."

    # Ensure .config exists
    mkdir -p "$CONFIG_DIR"

    # --- Setup config directory symlinks ---

    # Hyprland config
    if [ -d "$CONFIG_DIR/hypr" ]; then
        mv "$CONFIG_DIR/hypr" "$CONFIG_DIR/hypr.bak.$(date +%Y%m%d%H%M%S)"
    fi
    ln -s "$INSTALL_DIR/.config/hypr" "$CONFIG_DIR/hypr"
    echo "Created symlink for $CONFIG_DIR/hypr"

    # Rofi config
    if [ -d "$CONFIG_DIR/rofi" ]; then
        mv "$CONFIG_DIR/rofi" "$CONFIG_DIR/rofi.bak.$(date +%Y%m%d%H%M%S)"
    fi
    ln -s "$INSTALL_DIR/.config/rofi" "$CONFIG_DIR/rofi"
    echo "Created symlink for $CONFIG_DIR/rofi"

    # Kitty config
    if [ -d "$CONFIG_DIR/kitty" ]; then
        mv "$CONFIG_DIR/kitty" "$CONFIG_DIR/kitty.bak.$(date +%Y%m%d%H%
