
#!/bin/bash

export LC_MESSAGES=C
export LANG=C

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

append_unique_package() {
    local -n package_list="$1"
    local package="$2"
    local existing_package

    for existing_package in "${package_list[@]}"; do
        if [ "$existing_package" = "$package" ]; then
            return 0
        fi
    done

    package_list+=("$package")
}

# Ensure running as root before collecting interactive input.
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

if [ ! -f /etc/pacman.conf ]; then
    echo "File [/etc/pacman.conf] not found!"
    exit 1
fi

# --- Configuration ---
# echilon, tonekneeo, xnyte
# Get the actual user running the script (not root)
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    ACTUAL_USER="$SUDO_USER"
else
    ACTUAL_USER=$(logname 2>/dev/null)
fi

if [ -z "$ACTUAL_USER" ] || [ "$ACTUAL_USER" = "root" ]; then
    echo "ERROR: Could not determine a non-root target user. Run this script with sudo from your normal user account."
    exit 1
fi

ACTUAL_USER_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)
if [ -z "$ACTUAL_USER_HOME" ] || [ ! -d "$ACTUAL_USER_HOME" ]; then
    echo "ERROR: Could not determine home directory for user '$ACTUAL_USER'."
    exit 1
fi

REPO_DIR="$SCRIPT_DIR"
CONFIG_DIR="$ACTUAL_USER_HOME/.config"
DDCUTIL_ENABLED=0

# Validate repo directory
if [ ! -d "$REPO_DIR/.config" ]; then
    echo "ERROR: Script must be run from the repository root directory."
    exit 1
fi

if [ ! -d "$REPO_DIR/.config/hypr" ]; then
    echo "ERROR: Could not find the Hyprland config directory inside your repository at '$REPO_DIR/.config/hypr'."
    exit 1
fi

# --- Pre-flight confirmation ---
echo "This script will install custom dot-files for Hyprland and the Chaotic AUR. Use only with fresh install of Hyprland (Vanilla Arch Linux only). Use at your own risk."
while true; do
    read -r -p "Would you like to proceed? (y/n): " proceed
    case "$proceed" in
        y|Y|yes|YES)
            echo "Great! Proceeding with installation..."
            break
            ;;
        n|N|no|NO)
            echo "Fair enough, Have a nice day."
            exit 0
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done

INSTALL_NVIDIA_OPTIONAL=0
while true; do
    echo ""
    read -r -p "Are you using an Nvidia GPU? (y/n): " nvidia_choice
    case "$nvidia_choice" in
        y|Y|yes|YES)
            INSTALL_NVIDIA_OPTIONAL=1
            echo "Nvidia-specific Hyprland options will be enabled."
            break
            ;;
        n|N|no|NO)
            INSTALL_NVIDIA_OPTIONAL=0
            echo "Skipping Nvidia-specific Hyprland options."
            break
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done

# --- Printer support selection ---
INSTALL_PRINTER_SUPPORT=0
while true; do
    echo ""
    read -r -p "Do you want printer support? (y/n): " printer_choice
    case "$printer_choice" in
        y|Y|yes|YES)
            INSTALL_PRINTER_SUPPORT=1
            echo "Printer support packages will be installed after gaming packages."
            break
            ;;
        n|N|no|NO)
            INSTALL_PRINTER_SUPPORT=0
            echo "Skipping printer support installation."
            break
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done

# --- Gaming package selection ---
GAMING_SELECTED_PACKAGES=()
while true; do
    echo ""
    echo "Gaming Packages (select one or more):"
    echo "  1. steam"
    echo "  2. mangohud (standalone no gui)"
    echo "  3. protonplus"
    echo "  4. wine"
    echo "  5. winetricks"
    echo "  6. protontricks"
    echo "  7. lutris"
    echo "  8. heroic-games-launcher-bin"
    echo "  9. prismlauncher"
    echo " 10. goverlay"
    echo " 11. mangojuice"
    echo "  a. Install all gaming packages"
    echo "  0. Skip gaming package installation"
    echo ""
    read -r -p "Enter your choices (comma or space separated, e.g., 1,2,5 or 1 2 5, or a for all): " gaming_choices

    if [ "$gaming_choices" = "0" ] || [ -z "$gaming_choices" ]; then
        echo "Skipping gaming package installation."
        GAMING_SELECTED_PACKAGES=()
        break
    fi

    if [[ "$gaming_choices" =~ ^[aA]$ ]]; then
        gaming_choices="1 2 3 4 5 6 7 8 9 10 11"
    fi

    gaming_choices=$(echo "$gaming_choices" | tr ',' ' ')
    GAMING_SELECTED_PACKAGES=()
    invalid_choice=false

    for choice in $gaming_choices; do
        case "$choice" in
            1) append_unique_package GAMING_SELECTED_PACKAGES steam ;;
            2) append_unique_package GAMING_SELECTED_PACKAGES mangohud ;;
            3) append_unique_package GAMING_SELECTED_PACKAGES protonplus ;;
            4) append_unique_package GAMING_SELECTED_PACKAGES wine ;;
            5) append_unique_package GAMING_SELECTED_PACKAGES winetricks ;;
            6) append_unique_package GAMING_SELECTED_PACKAGES protontricks ;;
            7) append_unique_package GAMING_SELECTED_PACKAGES lutris ;;
            8) append_unique_package GAMING_SELECTED_PACKAGES heroic-games-launcher-bin ;;
            9) append_unique_package GAMING_SELECTED_PACKAGES prismlauncher ;;
            10) append_unique_package GAMING_SELECTED_PACKAGES goverlay ;;
            11) append_unique_package GAMING_SELECTED_PACKAGES mangojuice ;;
            *)
                echo "Invalid choice: $choice"
                invalid_choice=true
                ;;
        esac
    done

    if [ "$invalid_choice" = false ]; then
        echo "Selected gaming packages: ${GAMING_SELECTED_PACKAGES[*]}"
        break
    fi

    echo "Please try again with valid choices."
done

# --- Bluetooth package selection ---
INSTALL_BLUETOOTH_PACKAGES=0
while true; do
    echo ""
    read -r -p "Do you want to install Bluetooth packages and enable the Bluetooth service? (y/n): " bluetooth_choice
    case "$bluetooth_choice" in
        y|Y|yes|YES)
            INSTALL_BLUETOOTH_PACKAGES=1
            echo "Bluetooth packages will be installed and service will be enabled."
            break
            ;;
        n|N|no|NO)
            INSTALL_BLUETOOTH_PACKAGES=0
            echo "Skipping Bluetooth package installation and service."
            break
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done

# --- Audio mode selection ---
AUDIO_MODE="easyeffects"
while true; do
    echo ""
    echo "Audio setup option:"
    echo "  0. Skip EasyEffects and Dolby setup"
    echo "  1. EasyEffects (default)"
    echo "  2. Dolby Atmos support"
    read -r -p "Choose audio option (0-2): " audio_choice
    case "$audio_choice" in
        0)
            AUDIO_MODE="none"
            echo "Skipping EasyEffects and Dolby setup."
            break
            ;;
        1|"")
            AUDIO_MODE="easyeffects"
            echo "Using EasyEffects setup."
            break
            ;;
        2)
            AUDIO_MODE="dolby"
            echo "Dolby Atmos profile will be applied after installation."
            break
            ;;
        *)
            echo "Please enter 0, 1 or 2."
            ;;
    esac
done

# --- Audio/Video player selection ---
AUDIO_VIDEO_PACKAGES=()
INSTALL_VLC_PLUGINS_ALL=0
while true; do
    echo ""
    echo "Audio/Video Players (select one or more):"
    echo "  1. mpv (lightweight video player)"
    echo "  2. vlc (versatile media player)"
    echo "  3. dragon (simple KDE video player)"
    echo "  4. haruna (modern KDE video player)"
    echo "  5. deadbeef (modular audio player)"
    echo "  6. rhythmbox (GNOME music player)"
    echo "  7. elisa (lightweight KDE music player)"
    echo "  a. Install all audio/video players"
    echo "  0. Skip audio/video player installation"
    echo ""
    read -r -p "Enter your choices (comma or space separated, e.g., 1,2,5 or 1 2 5, or a for all): " av_choices
    
    if [ "$av_choices" = "0" ] || [ -z "$av_choices" ]; then
        echo "Skipping audio/video player installation."
        break
    fi

    if [[ "$av_choices" =~ ^[aA]$ ]]; then
        av_choices="1 2 3 4 5 6 7"
    fi
    
    # Convert input to array, handling both comma and space separation
    av_choices=$(echo "$av_choices" | tr ',' ' ')
    
    invalid_choice=false
    for choice in $av_choices; do
        case "$choice" in
            1) append_unique_package AUDIO_VIDEO_PACKAGES mpv ;;
            2) append_unique_package AUDIO_VIDEO_PACKAGES vlc ;;
            3) append_unique_package AUDIO_VIDEO_PACKAGES dragon ;;
            4) append_unique_package AUDIO_VIDEO_PACKAGES haruna ;;
            5) append_unique_package AUDIO_VIDEO_PACKAGES deadbeef ;;
            6) append_unique_package AUDIO_VIDEO_PACKAGES rhythmbox ;;
            7) append_unique_package AUDIO_VIDEO_PACKAGES elisa ;;
            *)
                echo "Invalid choice: $choice"
                invalid_choice=true
                ;;
        esac
    done
    
    if [ "$invalid_choice" = false ]; then
        if [ ${#AUDIO_VIDEO_PACKAGES[@]} -gt 0 ]; then
            echo "Selected packages: ${AUDIO_VIDEO_PACKAGES[*]}"

            for pkg in "${AUDIO_VIDEO_PACKAGES[@]}"; do
                if [ "$pkg" = "vlc" ]; then
                    while true; do
                        echo ""
                        read -r -p "Do you want to install vlc-plugins-all? If you choose no, you will need to install VLC plugins manually later. (y/n): " vlc_plugins_choice
                        case "$vlc_plugins_choice" in
                            y|Y|yes|YES)
                                INSTALL_VLC_PLUGINS_ALL=1
                                echo "vlc-plugins-all will be installed alongside VLC."
                                break
                                ;;
                            n|N|no|NO)
                                INSTALL_VLC_PLUGINS_ALL=0
                                echo "Skipping vlc-plugins-all. You can install VLC plugins manually later."
                                break
                                ;;
                            *)
                                echo "Please answer 'y' or 'n'."
                                ;;
                        esac
                    done
                    break
                fi
            done
        fi
        break
    fi
    
    echo "Please try again with valid choices."
    AUDIO_VIDEO_PACKAGES=()
done

# Define the list of packages to install using pacman
PACKAGES=(
    # Core Components
    polkit-gnome              # PolicyKit authentication agent
    gnome-keyring             # Credential storage  
    hyprlock                  # Locks screen, obviously. 
    hypridle                  # Turns off screen after set time
    pavucontrol               # PulseAudio/PipeWire volume control
    playerctl                 # Media player controller
    wlsunset                  # Nightlight for quickshell
    fish                      # Shell
    fastfetch                 # System Info Display
    satty                     # Screenshot annotation tool
    grim                      # Screenshot utility for wayland
    slurp                     # Screenshot selector for region
    hyprshot                  # Screenshot selector region - this is a standalone app
    gedit                     # Gnome Advanced Text Editor
    nwg-look                  # Look and feel configuration
    nwg-displays              # Configure Monitors 
    kitty-shell-integration   # Kitty terminal shell integration
    kitty-terminfo            # Terminfo for Kitty
    xdg-desktop-portal-gtk    # GTK implementation of xdg-desktop-portal
    xdg-user-dirs             # Manage user directories
    thunar                    # File Manager  
    thunar-media-tags-plugin  # Media tags plugin for Thunar
    thunar-shares-plugin      # Shares plugin for Thunar
    thunar-vcs-plugin         # VCS integration plugin for Thunar
    thunar-volman             # Volume management plugin for Thunar
    thunar-archive-plugin     # Archive plugin for Thunar
    update-grub               # Update GRUB bootloader
    bibata-cursor-theme       # Cursor theme
    gcolor3                   # Color picker
    gnome-calculator          # Math n stuff...
    tumbler                   # Thumbnailer
    hyprland-protocols        # Protocols for Hyprland
    power-profiles-daemon     # Power profile management
    file-roller               # Archive manager
    starship                  # Shell prompt
    unrar                     # RAR archive support
    unzip                     # ZIP archive support
    7zip                      # 7z archive support
    cava                      # Audio visualizer
    flatpak                   # Application sandbox and package manager
    gnome-disk-utility        # Disk Management
    libopenraw                # Lib for Tumbler
    libgsf                    # Lib for Tumbler
    poppler-glib              # Lib for Tumbler
    ffmpegthumbnailer         # Lib for Tumbler 
    freetype2                 # Lib for Tumbler
    libgepub                  # Lib for Tumbler
    gvfs                      # Needed for Thunar to see drives
    gvfs-afc                  # Apple Device Support
    gvfs-mtp                  # Android/MTP Device Support
    gvfs-smb                  # SMB Support 
    ntfs-3g                   # NTFS filesystem support
    dosfstools                # DOS filesystem utilities
    exfatprogs                # exFAT filesystem support
    yay                       # AUR Helper
    base-devel                # Build package
    clang                     # Build package
    cmake                     # Cross-platform build system
    go                        # Go programming language compiler
    rust                      # Rust programming language compiler
    pkgconf                   # Package config system
    meson                     # Modern build system
    ninja                     # Small build system focused on speed
    matugen                   # Color Generation
    adw-gtk-theme             # Libadwaita theme
    loupe                     # Image viewer
    cpupower                  # CPU frequency scaling utilities
    upower                    # Power management service
    gpu-screen-recorder       # Screen Recorder
    qt6-base                  # Qt6 base libraries and tools
    qt6ct                     # Qt Settings
    yaru-icon-theme           # Yaru Icons
    humanity-icon-theme       # Humanity Icons
    noto-fonts-emoji          # Fonts
    ttf-dejavu                # Fonts
    ttf-symbola               # Fonts
    gst-plugins-good          # Gstreamer Plugins 
    gst-plugins-ugly          # Gstreamer Plugins
    gst-libav                 # Gstreamer Plugins
    qt6-websockets            # Websocket
    os-prober                 # Os prober for Grub
    stb                       # Build Package for Noctalia V5
    imagemagick               # Image display
    noctalia                  # Noctalia
)

# Audio stack is selected at runtime.
if [ "$AUDIO_MODE" = "easyeffects" ]; then
    PACKAGES+=(
        easyeffects               # Audio Effects
        lsp-plugins-lv2           # Easyeffects Plugins
        calf                      # Easyeffects Plugins
    )
fi

OPTIONALPKG=(
    upscayl-desktop-git       # Upscaler for images on the fly
    video-downloader          # Download videos on your system, avoid sketchy websites! Yipee!
    mission-center            # Task Manager, Sleek
    obsidian                  # Markdown Text Editor
    obs-studio-stable         # OBS Streaming Software
    visual-studio-code-bin    # Visual Studio Code editor
)

# Descriptions for optional packages
declare -A OPTIONALPKG_DESC=(
    [upscayl-desktop-git]="Image upscaler (desktop GUI)"
    [video-downloader]="Download videos locally from various sources"
    [mission-center]="Sleek task manager / system monitor"
    [obsidian]="Markdown text editor"
    [obs-studio-stable]="OBS streaming and recording software"
    [visual-studio-code-bin]="Visual Studio Code editor"
)

SELECTED_OPTIONAL_PACKAGES=()
BROWSER_CHOICE=6

# --- Color Functions ---
disable_colors() {
    unset ALL_OFF BOLD BLUE GREEN RED YELLOW CYAN MAGENTA
}

enable_colors() {
    if tput setaf 0 &>/dev/null; then
        ALL_OFF="$(tput sgr0)"
        BOLD="$(tput bold)"
        RED="${BOLD}$(tput setaf 1)"
        GREEN="${BOLD}$(tput setaf 2)"
        YELLOW="${BOLD}$(tput setaf 3)"
        BLUE="${BOLD}$(tput setaf 4)"
        MAGENTA="${BOLD}$(tput setaf 5)"
        CYAN="${BOLD}$(tput setaf 6)"
    else
        ALL_OFF="\e[0m"
        BOLD="\e[1m"
        RED="${BOLD}\e[31m"
        GREEN="${BOLD}\e[32m"
        YELLOW="${BOLD}\e[33m"
        BLUE="${BOLD}\e[34m"
        MAGENTA="${BOLD}\e[35m"
        CYAN="${BOLD}\e[36m"
    fi
    readonly ALL_OFF BOLD BLUE GREEN RED YELLOW CYAN MAGENTA
}

if [[ -t 2 ]]; then
    enable_colors
else
    disable_colors
fi

# --- Chaotic-AUR Functions ---
print_header() {
    echo ""
    printf "${CYAN}${BOLD}   Chaotic-AUR Repository Setup${ALL_OFF}\n"
    printf "${YELLOW}${BOLD}   'The Fast Lane!'${ALL_OFF}\n"
    echo ""
}

msg() {
    printf "${GREEN}▶${ALL_OFF}${BOLD} ${1}${ALL_OFF}\n" >&2
}

info() {
    printf "${YELLOW}  •${ALL_OFF} ${1}${ALL_OFF}\n" >&2
}

error() {
    printf "${RED}  ✗${ALL_OFF} ${1}${ALL_OFF}\n" >&2
}

check_if_chaotic_repo_was_added() {
    grep -q "chaotic-aur" /etc/pacman.conf
}

ensure_multilib_repo_enabled() {
    msg "Ensuring multilib repository is enabled.."

    local pacman_conf="/etc/pacman.conf"

    if grep -Eq '^[[:space:]]*\[multilib\][[:space:]]*$' "$pacman_conf"; then
        info "multilib is already enabled"
        return
    fi

    if grep -Eq '^[[:space:]]*#[[:space:]]*\[multilib\][[:space:]]*$' "$pacman_conf"; then
        info "Found commented multilib block, enabling it"
        sed -i '/^[[:space:]]*#[[:space:]]*\[multilib\][[:space:]]*$/,/^[[:space:]]*#[[:space:]]*Include[[:space:]]*=[[:space:]]*\/etc\/pacman\.d\/mirrorlist[[:space:]]*$/ s/^[[:space:]]*#[[:space:]]*//' "$pacman_conf"
    else
        info "multilib block not found, appending it"
        {
            echo ""
            echo "[multilib]"
            echo "Include = /etc/pacman.d/mirrorlist"
        } >> "$pacman_conf"
    fi

    msg "Done configuring multilib repository"
}

reorder_pacman_conf() {
    msg "Ensuring correct repository order in pacman.conf.."
    
    local pacman_conf="/etc/pacman.conf"
    local pacman_conf_backup="/etc/pacman.conf.bak.$(date +%s)"
    
    info "Backup current config"
    cp "$pacman_conf" "$pacman_conf_backup"
    
    # Remove any existing Chaotic-AUR entries
    sed -i '/^\[chaotic-aur\]/,/^$/d' "$pacman_conf"
    
    # Add Chaotic-AUR at the end
    echo "" >> "$pacman_conf"
    echo "[chaotic-aur]" >> "$pacman_conf"
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> "$pacman_conf"
    
    info "Chaotic-AUR positioned at the end of pacman.conf"
    msg "Done configuring repository order"
}

install_chaotic_aur() {
    msg "Installing Chaotic-AUR repository.."
    printf "${CYAN}${BOLD}  🔑 Adding Chaotic-AUR GPG key...${ALL_OFF}\n"

    info "Adding Chaotic-AUR GPG key"
    if ! pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com; then
        error "Failed to fetch Chaotic-AUR GPG key"
        return 1
    fi

    if ! pacman-key --lsign-key 3056513887B78AEB; then
        error "Failed to locally sign the Chaotic-AUR GPG key"
        return 1
    fi

    printf "${CYAN}${BOLD}  📦 Installing Chaotic-AUR packages...${ALL_OFF}\n"
    info "Installing Chaotic-AUR keyring and mirrorlist"
    if ! pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'; then
        error "Failed to install chaotic-keyring"
        return 1
    fi

    if ! pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then
        error "Failed to install chaotic-mirrorlist"
        return 1
    fi

    msg "Done installing Chaotic-AUR repository."
}

create_chaotic_mirrorlist() {
    msg "Creating Chaotic-AUR mirrorlist file.."
    
    if [[ ! -f /etc/pacman.d/chaotic-mirrorlist ]] || [[ ! -s /etc/pacman.d/chaotic-mirrorlist ]]; then
        info "Creating chaotic-mirrorlist"
        cat > /etc/pacman.d/chaotic-mirrorlist << 'EOF'
# Chaotic-AUR Mirrorlist
Server = https://cdn-mirror.chaotic.cx/chaotic-aur/$arch
Server = https://geo-mirror.chaotic.cx/chaotic-aur/$arch
EOF
    fi
    
    msg "Done creating mirrorlist file"
}

setup_chaotic_aur() {
    print_header
    msg "Setting up Chaotic-AUR repository.."

    ensure_multilib_repo_enabled
    
    if check_if_chaotic_repo_was_added; then
        info "Chaotic-AUR repo is already installed!"
        info "Skipping installation steps"
    else
        if ! install_chaotic_aur; then
            return 1
        fi
        create_chaotic_mirrorlist
    fi
    
    reorder_pacman_conf
    
    echo ""
    printf "${GREEN}${BOLD}  ✓ SUCCESS${ALL_OFF}\n"
    printf "${GREEN}  Chaotic-AUR repository setup completed successfully!${ALL_OFF}\n"
    printf "${GREEN}  Repository is now positioned at the end of pacman.conf${ALL_OFF}\n"
    echo ""
    
    msg "Refreshing pacman mirrors..."
    pacman -Syy
    
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to refresh pacman mirrors."
    fi
}

# --- Main Installation Functions ---

# Remove conflicting packages
remove_conflicting_packages() {
    echo "Removing conflicting packages..."
    pacman -Rns --noconfirm dolphin polkit-kde-agent vim
    
    if [ $? -eq 0 ]; then
        echo "Conflicting packages removed successfully."
    else
        echo "Warning: Some packages could not be removed (they may not be installed)."
    fi
}

install_gaming_packages() {
    if [ ${#GAMING_SELECTED_PACKAGES[@]} -eq 0 ]; then
        return 0
    fi

    for pkg in "${GAMING_SELECTED_PACKAGES[@]}"; do
        case "$pkg" in
            mangohud)
                append_unique_package GAMING_SELECTED_PACKAGES lib32-mangohud
                ;;
            prismlauncher)
                append_unique_package GAMING_SELECTED_PACKAGES jdk21-openjdk
                ;;
        esac
    done

    echo -e "\n--- Gaming Packages Installation ---"
    echo "Installing gaming packages (interactive prompts enabled)..."

    # Repo packages via pacman (no --noconfirm so user can review prompts)
    pacman -S --needed "${GAMING_SELECTED_PACKAGES[@]}"
    if [ $? -ne 0 ]; then
        echo "Warning: Some pacman gaming packages failed to install."
    fi
}

install_printer_support_packages() {
    if [ "$INSTALL_PRINTER_SUPPORT" -ne 1 ]; then
        return 0
    fi

    echo -e "\n--- Printer Support Installation ---"
    pacman -S --noconfirm --needed \
        hspell libvoikko hunspell aspell nuspell reflector pinta lib32-libpulse ttf-ms-fonts \
        cups cups-filters cups-pdf hplip gutenprint system-config-printer \
        foomatic-db-gutenprint-ppds foomatic-db-nonfree-ppds foomatic-db-ppds \
        foomatic-db-nonfree foomatic-db foomatic-db-engine \
        python-pyqt5 python-reportlab python-pyqt6

    if [ $? -ne 0 ]; then
        echo "Warning: Some printer support packages failed to install."
    fi

    echo "Enabling and starting CUPS service..."
    systemctl enable --now cups
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to enable CUPS service."
    fi
}

install_bluetooth_packages() {
    if [ "$INSTALL_BLUETOOTH_PACKAGES" -ne 1 ]; then
        return 0
    fi

    echo -e "\n--- Bluetooth Installation ---"
    echo "Installing Bluetooth packages..."
    pacman -S --noconfirm --needed bluez bluez-utils blueman

    if [ $? -ne 0 ]; then
        echo "Warning: Some Bluetooth packages failed to install."
    fi

    echo "Enabling Bluetooth service..."
    systemctl enable bluetooth

    if [ $? -ne 0 ]; then
        echo "Warning: Failed to enable Bluetooth service."
    fi
}

install_audio_video_packages() {
    if [ ${#AUDIO_VIDEO_PACKAGES[@]} -eq 0 ]; then
        return 0
    fi

    echo -e "\n--- Audio/Video Players Installation ---"
    local vlc_plugins_package=""
    if [ "$INSTALL_VLC_PLUGINS_ALL" -eq 1 ]; then
        vlc_plugins_package="vlc-plugins-all"
    fi
    
    echo "Installing selected audio/video packages: ${AUDIO_VIDEO_PACKAGES[*]}..."
    if [ -n "$vlc_plugins_package" ]; then
        echo "Also installing: $vlc_plugins_package"
        pacman -S --noconfirm --needed "${AUDIO_VIDEO_PACKAGES[@]}" "$vlc_plugins_package"
    else
        pacman -S --noconfirm --needed "${AUDIO_VIDEO_PACKAGES[@]}"
    fi

    if [ $? -ne 0 ]; then
        echo "Warning: Some audio/video packages failed to install."
    else
        echo "Audio/Video players installed successfully."
    fi
}

# Function to prompt optional package selection
prompt_optional_packages() {
    local optional_choices
    local pkg
    local desc
    local choice
    local pkg_index
    local invalid_choice
    local menu_index

    echo -e "\n--- Optional Packages Installation ---"

    while true; do
        echo "Choose one or more optional packages:"
        menu_index=1
        for pkg in "${OPTIONALPKG[@]}"; do
            desc="${OPTIONALPKG_DESC[$pkg]}"
            if [ -n "$desc" ]; then
                echo "  $menu_index. $pkg ($desc)"
            else
                echo "  $menu_index. $pkg"
            fi
            menu_index=$((menu_index + 1))
        done
        echo "  0. Skip optional package installation"
        echo "  a. Install all optional packages"
        echo ""

        read -r -p "Enter your choices (comma or space separated, e.g., 1,2 or 1 2, or a for all): " optional_choices

        if [ "$optional_choices" = "0" ] || [ -z "$optional_choices" ]; then
            echo "Skipping optional package installation."
            SELECTED_OPTIONAL_PACKAGES=()
            return 0
        fi

        if [[ "$optional_choices" =~ ^[aA]$ ]]; then
            optional_choices=$(seq -s ' ' 1 "${#OPTIONALPKG[@]}")
        fi

        optional_choices=$(echo "$optional_choices" | tr ',' ' ')
        SELECTED_OPTIONAL_PACKAGES=()
        invalid_choice=false

        for choice in $optional_choices; do
            if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
                echo "Invalid choice: $choice"
                invalid_choice=true
                continue
            fi

            if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#OPTIONALPKG[@]}" ]; then
                echo "Invalid choice: $choice"
                invalid_choice=true
                continue
            fi

            pkg_index=$((choice - 1))
            append_unique_package SELECTED_OPTIONAL_PACKAGES "${OPTIONALPKG[$pkg_index]}"
        done

        if [ "$invalid_choice" = false ]; then
            for pkg in "${SELECTED_OPTIONAL_PACKAGES[@]}"; do
                if [ "$pkg" = "obs-studio-stable" ]; then
                    append_unique_package SELECTED_OPTIONAL_PACKAGES luajit
                    break
                fi
            done

            return 0
        fi

        echo "Please try again with valid choices."
    done
}

# Function to handle optional package installation
install_optional_packages() {
    if [ ${#SELECTED_OPTIONAL_PACKAGES[@]} -eq 0 ]; then
        echo "Skipping optional package installation."
        return 0
    fi

    echo -e "\n--- Optional Packages Installation ---"
    echo "Installing selected optional packages: ${SELECTED_OPTIONAL_PACKAGES[*]}..."
    pacman -S --noconfirm --needed "${SELECTED_OPTIONAL_PACKAGES[@]}"

    if [ $? -ne 0 ]; then
        echo "Warning: Some optional packages failed to install."
    else
        echo "Optional packages installed successfully."
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

    # Ensure target .config directory exists
    sudo -u "$ACTUAL_USER" mkdir -p "$CONFIG_DIR"

    # Back up any existing configs that would be overwritten
    BACKUP_TIMESTAMP=$(date +%s)
    echo "Backing up existing configuration files..."

    for item in "$CONFIG_SOURCE_ROOT"/*; do
        name=$(basename "$item")
        target="$CONFIG_DIR/$name"
        if [ "$name" = "hypr" ]; then
            continue
        fi

        if [ -e "$target" ] || [ -L "$target" ]; then
            echo "  -> Backing up: $name to $name.bak.$BACKUP_TIMESTAMP"
            mv "$target" "$CONFIG_DIR/$name.bak.$BACKUP_TIMESTAMP"
        fi
    done

    if [ -e "$CONFIG_DIR/hypr" ] || [ -L "$CONFIG_DIR/hypr" ]; then
        echo "  -> Backing up: hypr to hypr.bak.$BACKUP_TIMESTAMP"
        mv "$CONFIG_DIR/hypr" "$CONFIG_DIR/hypr.bak.$BACKUP_TIMESTAMP"
    fi

    # Copy all configuration files from repo/.config to ~/.config
    echo "Copying configuration files from $CONFIG_SOURCE_ROOT to $CONFIG_DIR..."
    cp -rf "$CONFIG_SOURCE_ROOT"/* "$CONFIG_DIR"/
    
    if [ $? -eq 0 ]; then
        echo "Configuration files copied successfully!"
        
        # Fix ownership since we're running as root
        chown -R "$ACTUAL_USER:$ACTUAL_USER" "$CONFIG_DIR"

        # If ddcutil was enabled, make sure Noctalia uses DDC monitor control.
        if [ "$DDCUTIL_ENABLED" -eq 1 ] && [ -f "$CONFIG_DIR/noctalia/settings.json" ]; then
            python3 - "$CONFIG_DIR/noctalia/settings.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

brightness = data.get("brightness")
if not isinstance(brightness, dict):
    brightness = {}
    data["brightness"] = brightness

brightness["enableDdcSupport"] = True

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)
    f.write("\n")
PY
            if [ $? -eq 0 ]; then
                chown "$ACTUAL_USER:$ACTUAL_USER" "$CONFIG_DIR/noctalia/settings.json"
                echo "Enabled Noctalia DDC support in settings.json."
            else
                echo "Warning: Could not update Noctalia DDC setting automatically."
            fi
        fi
    else
        echo "ERROR: Failed to copy configuration files."
    fi
}



update_hypr_startup_config() {
    local startup_file="$ACTUAL_USER_HOME/.config/hypr/startup.lua"

    if [ ! -f "$startup_file" ]; then
        echo "Warning: Hyprland startup file '$startup_file' not found."
        return 0
    fi

    if [ "$INSTALL_NVIDIA_OPTIONAL" -eq 1 ]; then
        if grep -qF 'local enable_nvidia_optional = false' "$startup_file"; then
            echo "Enabling Nvidia-specific Hyprland options in $startup_file..."
            sed -i 's|^local enable_nvidia_optional = false$|local enable_nvidia_optional = true|' "$startup_file"
        else
            echo "Warning: Expected Nvidia toggle line not found in '$startup_file'."
        fi
    fi
}

# Set executable permissions for scripts
set_permissions() {
    SCRIPTS_PATH="$ACTUAL_USER_HOME/.config/hypr/Scripts"
    
    if [ -d "$SCRIPTS_PATH" ]; then
        echo "Setting execution permissions for scripts..."
        find "$SCRIPTS_PATH" -type f -exec chmod +x {} \;
    else
        echo "Warning: Hyprland scripts directory '$SCRIPTS_PATH' not found."
    fi
}

# Browser selection prompt
prompt_browser_installation() {
    echo -e "\n--- Browser Installation ---"
    echo "Which browser would you like to install?"
    echo "  1. Vivaldi"
    echo "  2. Brave"
    echo "  3. Zen Browser"
    echo "  4. Firefox"
    echo "  5. LibreWolf"
    echo "  6. Skip browser installation"
    echo ""
    
    while true; do
        read -r -p "Enter your choice (1-6): " browser_choice
        case "$browser_choice" in
            1)
                BROWSER_CHOICE=1
                break
                ;;
            2)
                BROWSER_CHOICE=2
                break
                ;;
            3)
                BROWSER_CHOICE=3
                break
                ;;
            4)
                BROWSER_CHOICE=4
                break
                ;;
            5)
                BROWSER_CHOICE=5
                break
                ;;
            6)
                BROWSER_CHOICE=6
                break
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 6."
                ;;
        esac
    done
}

# Browser installation
install_browser() {
    case "$BROWSER_CHOICE" in
        1)
            echo "Installing Vivaldi..."
            pacman -S --noconfirm vivaldi
            if [ $? -eq 0 ]; then
                echo "Vivaldi installed successfully!"
            else
                echo "ERROR: Failed to install Vivaldi."
            fi
            ;;
        2)
            echo "Installing Brave..."
            pacman -S --noconfirm brave-bin
            if [ $? -eq 0 ]; then
                echo "Brave installed successfully!"
            else
                echo "ERROR: Failed to install Brave."
            fi
            ;;
        3)
            echo "Installing Zen Browser..."
            pacman -S --noconfirm zen-browser-bin
            if [ $? -eq 0 ]; then
                echo "Zen Browser installed successfully!"
            else
                echo "ERROR: Failed to install Zen Browser."
            fi
            ;;
        4)
            echo "Installing Firefox..."
            pacman -S --noconfirm firefox
            if [ $? -eq 0 ]; then
                echo "Firefox installed successfully!"
            else
                echo "ERROR: Failed to install Firefox."
            fi
            ;;
        5)
            echo "Installing LibreWolf..."
            pacman -S --noconfirm librewolf
            if [ $? -eq 0 ]; then
                echo "LibreWolf installed successfully!"
            else
                echo "ERROR: Failed to install LibreWolf."
            fi
            ;;
        *)
            echo "Skipping browser installation."
            ;;
    esac
}

# Setup ddcutil for monitor brightness control
setup_ddcutil() {
    echo -e "\n--- Optional: ddcutil Setup ---"
    echo "ddcutil allows you to control monitor brightness via DDC/CI protocol."
    read -r -p "Do you want to install and configure ddcutil? (y/N): " ddcutil_response
    
    if [[ "$ddcutil_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Setting up ddcutil..."
        
        # Install ddcutil
        pacman -S --noconfirm --needed ddcutil
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to install ddcutil."
            return 1
        fi

        # Install ddcutil-service (AUR, D-Bus activated)
        if command -v yay >/dev/null 2>&1; then
            sudo -u "$ACTUAL_USER" yay -S --noconfirm --needed --answerclean None --answerdiff None ddcutil-service
            if [ $? -ne 0 ]; then
                echo "Warning: Failed to install ddcutil-service from AUR."
            fi
        else
            echo "Warning: yay was not found; skipping ddcutil-service installation."
        fi
        
        # Load i2c-dev module
        modprobe i2c-dev
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to load i2c-dev module."
        fi
        
        # Make i2c-dev load on boot
        echo "i2c-dev" > /etc/modules-load.d/i2c-dev.conf
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to configure i2c-dev autoload."
        fi

        # Reload udev rules so ddcutil permissions are applied immediately
        udevadm control --reload-rules
        udevadm trigger
        
        # List i2c devices
        echo "Available i2c devices:"
        ls /dev/i2c-* 2>/dev/null || echo "No i2c devices found (this is normal if not yet configured)"
        
        # Add user to i2c group
        usermod -aG i2c "$ACTUAL_USER"
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to add user to i2c group."
        fi

        # Quick runtime validation; service is D-Bus activated and should respond.
        if ! sudo -u "$ACTUAL_USER" ddcutil-client detect >/dev/null 2>&1; then
            echo "Warning: ddcutil D-Bus detect failed right now. This can still work after relogin/reboot."
        fi

        DDCUTIL_ENABLED=1
        
        echo "ddcutil setup complete. You may need to log out and back in for group changes to take effect."
    else
        echo "Skipping ddcutil setup."
    fi
}

# Set default file manager to Thunar
set_default_file_manager() {
    echo ""
    echo "Setting Thunar as default file manager..."
    # Ensure the user config directory exists so xdg-mime writes to the correct path.
    sudo -u "$ACTUAL_USER" mkdir -p "$ACTUAL_USER_HOME/.config"
    sudo -u "$ACTUAL_USER" xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search
    echo "Default file manager set to Thunar."
}

# Create GTK bookmarks for Thunar
create_thunar_bookmarks() {
    echo ""
    echo "Creating Thunar bookmarks..."

    local gtk_dir="$ACTUAL_USER_HOME/.config/gtk-3.0"
    local bookmarks_file="$gtk_dir/bookmarks"

    sudo -u "$ACTUAL_USER" mkdir -p "$gtk_dir"

    sudo -u "$ACTUAL_USER" tee "$bookmarks_file" >/dev/null <<EOF
file://$ACTUAL_USER_HOME/Documents
file://$ACTUAL_USER_HOME/Downloads
file://$ACTUAL_USER_HOME/Pictures
file://$ACTUAL_USER_HOME/Music
file://$ACTUAL_USER_HOME/Videos
file://$ACTUAL_USER_HOME/.config/hypr
EOF

    echo "Thunar bookmarks created at $bookmarks_file."
}

# Copy backup config files if available
copy_backup_configs() {
    echo -e "\n--- Optional: Copy Backup Configs ---"
    
    local config_source="$REPO_DIR/backup/.config"
    
    if [[ ! -d "$config_source" ]]; then
        echo "No backup folder found at $REPO_DIR/backup/.config"
        echo "Skipping backup config restoration."
        return 0
    fi
    
    echo "Found backup configs at: $config_source"
    read -r -p "Do you want to restore config files from backup? (y/N): " backup_response
    
    if [[ "$backup_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Copying config files from backup to $CONFIG_DIR..."
        cp -rf "$config_source"/* "$CONFIG_DIR"/
        
        if [ $? -eq 0 ]; then
            echo "Config files copied successfully!"
            
            # Fix ownership since we're running as root
            chown -R "$ACTUAL_USER:$ACTUAL_USER" "$CONFIG_DIR"

            # Keep DDC support enabled if ddcutil setup was selected.
            if [ "$DDCUTIL_ENABLED" -eq 1 ] && [ -f "$CONFIG_DIR/noctalia/settings.json" ]; then
                python3 - "$CONFIG_DIR/noctalia/settings.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

brightness = data.get("brightness")
if not isinstance(brightness, dict):
    brightness = {}
    data["brightness"] = brightness

brightness["enableDdcSupport"] = True

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)
    f.write("\n")
PY
                if [ $? -eq 0 ]; then
                    chown "$ACTUAL_USER:$ACTUAL_USER" "$CONFIG_DIR/noctalia/settings.json"
                    echo "Re-enabled Noctalia DDC support after backup restore."
                else
                    echo "Warning: Could not re-enable Noctalia DDC support after backup restore."
                fi
            fi
            
            # If running under Hyprland, reload it to apply config changes
            if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
                echo "Detected Hyprland environment. Reloading Hyprland to apply new configs..."
                hyprctl reload 2>/dev/null || echo "Note: Could not reload Hyprland. You may need to restart it manually."
                sleep 2
            fi
        else
            echo "ERROR: Failed to copy backup config files."
        fi
    else
        echo "Skipping backup config restoration."
    fi
}

# Apply optional Dolby PipeWire profile
apply_dolby_pipewire_profile() {
    if [ "$AUDIO_MODE" != "dolby" ]; then
        return 0
    fi

    local pipewire_source="$REPO_DIR/pipewire"
    local pipewire_target="$CONFIG_DIR/pipewire"

    echo -e "\n--- Applying Dolby PipeWire Profile ---"

    if [ ! -d "$pipewire_source" ]; then
        echo "Warning: Dolby profile selected, but no '$pipewire_source' folder was found."
        return 0
    fi

    echo "Copying Dolby PipeWire config to $pipewire_target..."
    sudo -u "$ACTUAL_USER" mkdir -p "$pipewire_target"
    cp -rf "$pipewire_source"/* "$pipewire_target"/

    if [ $? -eq 0 ]; then
        chown -R "$ACTUAL_USER:$ACTUAL_USER" "$pipewire_target"
        echo "Dolby PipeWire profile applied successfully."
    else
        echo "Warning: Failed to apply Dolby PipeWire profile."
    fi
}

# --- Main Installation Flow ---

echo "Starting Hyprland Dotfiles Installation..."

# Collect install choices before repository setup and package installation.
prompt_optional_packages
prompt_browser_installation

# 0. Setup Chaotic-AUR Repository
if ! setup_chaotic_aur; then
    echo "ERROR: Failed to set up the Chaotic-AUR repository. Aborting installation."
    exit 1
fi

# 1. Remove conflicting packages
remove_conflicting_packages

# 2. Install Core Packages
echo "Installing required core packages via pacman..."
echo "installing core packages in 3..."
echo "2..."
echo "1!"
pacman -S --noconfirm "${PACKAGES[@]}"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install core packages. Aborting installation."
    exit 1
fi

# 2.5 Optional gaming packages (interactive)
install_gaming_packages

# 2.6 Optional printer support
install_printer_support_packages

# 2.7 Optional Bluetooth support
install_bluetooth_packages

# 2.8 Optional audio/video player installation
install_audio_video_packages

# 3. Optional install packages
install_optional_packages

# 4. Update user directories
echo "Updating user directories..."
sudo -u "$ACTUAL_USER" xdg-user-dirs-update

if [ $? -ne 0 ]; then
    echo "Warning: Failed to update user directories."
fi

echo "Base package installation complete!"
echo "--------------------------------------------------------"
echo "Proceeding with post-install configuration..."
echo "--------------------------------------------------------"

# Refresh and upgrade system packages before AUR installs
echo "Updating system packages before installing noctalia-git..."
sudo pacman -Syu --noconfirm

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to update system packages. Aborting installation."
    exit 1
fi

# Install noctalia-git via yay
#echo "Installing noctalia-git via yay..."
#sudo -u "$ACTUAL_USER" yay -S --noconfirm noctalia-git

#if [ $? -ne 0 ]; then
#    echo "Warning: Failed to install noctalia-git."
#fi

# Browser installation
install_browser

# Setup ddcutil for monitor brightness control
setup_ddcutil

# Set default file manager to Thunar
set_default_file_manager

# Deploy Configurations
deploy_configs

# Copy backup config files if available
copy_backup_configs

# Update Hyprland startup command for Nvidia
update_hypr_startup_config

# Create Thunar bookmarks
create_thunar_bookmarks

# Set Script Permissions
set_permissions

# Apply optional Dolby PipeWire profile
apply_dolby_pipewire_profile

# Reboot confirmation
echo ""
echo "Installation complete! Time to reboot."
while true; do
    read -r -p "Would you like to reboot now? (y/n): " reboot_choice
    case "$reboot_choice" in
        y|Y|yes|YES)
            echo "Rebooting now..."
            sudo reboot now
            break
            ;;
        n|N|no|NO)
            echo ""
            echo "Installation complete! Time to reboot."
            ;;
        *)
            echo "Please answer 'y' or 'n'."
            ;;
    esac
done

