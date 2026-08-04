<p align="center">
  <img src="https://img.shields.io/github/last-commit/Echilonvibin/minimaLinux" alt="Last Commit">
  <img src="https://img.shields.io/github/commit-activity/w/Echilonvibin/minimaLinux" alt="Commit Activity">
  <img src="https://img.shields.io/badge/license-GPL--3.0-blue" alt="License">
</p>

<details>
  <summary align="center"><b>📸 Click to view Theme Screenshots</b></summary>
  <p align="center">
    <img src="Red.png" height="350" style="vertical-align: middle;"><img src="TokyoNight.png" height="350" style="vertical-align: middle;">
  </p>
</details>

## ⚠️ Important Warnings & Disclaimer

### Fresh Install Requirement

**This configuration is tailored for a FRESH INSTALL of VANILLA ARCH LINUX using the archinstall script with the Hyprland profile.** We strongly advise against attempting this installation on derivative distributions (such as CachyOS, Manjaro, etc.) as package and configuration conflicts are highly likely. This includes packages you could install yourself, through Arch's repo, and a few AUR packages. This will install the chaotic AUR, the only AUR exclusive package that is installed, is the Noctalia bar itself. 

### Development Status

This script, is now released. It is no longer in beta state. This project originally started as a vibe coded project to see what we could get away with. It quickly turned into only being an outline, as A.I is too frustrating to deal with after more than 80 lines of code. The rest, is completely scripted by tonekneeo, and myself.

### Lua Update

The Hyprland configuration now uses Lua-based. The old .conf-based structure is no longer used.

We have also switched over to Noctalia v5 beta.

### What this does

This script turns a fresh Arch + Hyprland setup into the minimaLinux desktop by installing required packages, dropping useless ones and adding preconfigured streamlined dotfiles.

### Nvidia Users

NVIDIA Users: On line 32 of the startup.lua change local enable_nvidia_optional = false to local enable_nvidia_optional = true

### Credits

The primary application bar (`noctalia-shell`) is based on the exceptional work by **Noctalia**. All credit for the bar's design and functionality goes to them:

> [**noctalia-dev/noctalia-shell**](https://noctalia.dev/)

### Community

Join the Discord server: [HERE](https://discord.gg/rQTabZmYHh)


## 📦 What's Included?

This repository provides comprehensive configurations for a complete, customized Hyprland desktop environment.

| Component | Description |
| :--- | :--- |
| **`hypr`** | Main Hyprland configuration, including keybinds, window rules, and workspace setup. **(Requires customization)** |
| **`kitty`** | Configuration for the primary GPU-accelerated terminal emulator. |
| **`fish`** | Configuration for the Fish shell, including custom functions and the Starship prompt. |
| **`Noctalia`** | The main bar, includes various theming settings, general use case settings. It's very much an all in one. |
| **`fastfetch`** | Configuration for displaying system information with custom images/ASCII art. |
| **`install.sh`** | An automated script for package installation and configuration deployment. |
| **`uninstall.sh`** | A script to revert changes and restore previous configurations (if a backup exists). |

---

## ⚙️ Customization Required

These dotfiles are provided strictly as a **template**. You **must** review and customize several files to align with your specific hardware, desired aesthetics, and system paths.

| File/Section | Customization Needed | Notes |
| :--- | :--- | :--- |
| **`hypr/hyprland.lua`** | Monitor setup (resolution, scaling, refresh rate). | The current default is `monitor=,preferred,auto,1`. You may use `nwg-displays` to help configure and export precise settings. |
| **`hypr/keybind.lua`** | Set bindings here. | Super+E is to open your file explorer. Super+D is the app launcher. |
| **Theming** | Color schemes, fonts, and global aesthetic settings. | The default theme is minimal. Customize these within Noctalia's settings, go to color scheme, and then templates, you can set kitty, GTK, or whatever else you would like to match your color scheme. |
| *NOTE ON THEMING* | adw-gtk3-dark | This will be needed to make changes to GTK. This comes preinstalled, you will have to set it in GTK Settings. |
| **`fastfetch/config.jsonc`** | Theming/Images. | Update the configuration for your specific image or ASCII art display. |

---

## 🚀 Installation Guide

### Prerequisites

You must be running an **Arch-based Linux distribution** and have basic development tools installed (`git` is required for cloning).

### Step 1: Clone the Repository

Open your terminal and clone the repository using `git`:

```bash
git clone https://github.com/Echilonvibin/minimaLinux.git
```

### Step 2: Change directory to the repo
```bash
cd ./minimaLinux
```

### Step 3: Make the install script executable

```bash
chmod +x ./install.sh
```

### Step 4: Run the install script, YIPPE
```bash
sudo ./install.sh
```

### Additional Install Notes

For extra setup and troubleshooting details (including Arch ISO Wi-Fi setup before archinstall), see [InstallNotes.md](InstallNotes.md).


Note: The install.sh script handles package installation via your package manager and deploys the dotfiles. Any existing config files that would be overwritten are first backed up with a `.bak.<timestamp>` suffix in `~/.config`, allowing `uninstall.sh` to restore them later.

## 🗑️ Uninstallation
If you need to revert the changes, navigate to the repository directory and run:

```bash
./uninstall.sh
```

This will restore any backed-up config files found in `~/.config` to their previous state.

> **Note:** Installed packages are **not** automatically removed. If you wish to uninstall them, you will need to do so manually via `pacman` or `yay`.
