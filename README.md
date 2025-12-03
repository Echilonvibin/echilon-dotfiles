<p align="center">

<!-- Placeholders for GitHub Shields. Update the source URLs after your first push! -->

<img src="https://img.shields.io/github/last-commit/Echilonvibin/echilon-dotfiles" alt="Last Commit">

<img src="https://img.shields.io/github/commit-activity/w/Echilonvibin/echilon-dotfiles" alt="Commit Activity">

</p>



# echilon-dotfiles



A collection of custom configuration files (dotfiles) for the **Hyprland** Wayland compositor, managed by **Echilon & Tonekneeo**.



---



## ⚠️ Important Warnings



### Fresh Install & Liability



**THIS IS FOR A FRESH INSTALL OF VANILLA ARCH HYPRLAND.** Do not attempt this on derivative distributions (like CachyOS or similar).



This configuration is currently "vibe coded" and is in active development. While everything is working so far, **more testing will be done — use at your own risk.**



### Credits



The application bar (`noctalia-shell-git`) is based on the amazing work by Noctalia. All credit for the bar goes to them:

<https://github.com/noctalia-dev/noctalia-shell>



---



## ⚙️ Customization Required



These dotfiles are provided as a *template*. You **must** review and customize several files to match your system paths, desired aesthetics, and hardware setup.



### Key Customization Points:



| File/Section | Customization Needed | Notes |

| :--- | :--- | :--- |

| **`hypr/hyprland.conf`** | Monitor setup (resolution, scaling, refresh rate). | Current config uses `monitor=,preferred,auto,1`. You can also use `nwg-displays` to configure and export settings. |

| **`hypr/keybindings.conf`** | Script execution paths. | Ensure the paths to executable scripts (like `keyhints` or other utility scripts) are correct. |

| **Wallpaper Engine** | Custom wallpaper assets and workshop path. | View the [linux-wallpaperengine GitHub](https://github.com/Almamu/linux-wallpaperengine) for details. **🚨 I WILL NOT PROVIDE SUPPORT FOR WALLPAPER ENGINE 🚨** |

| **Theming** | Color schemes and font settings. | Default theme settings are minimal. Add your preferred settings here. |

| **`fastfetch/config.jsonc`** | Theming/Images. | Update for specific image or ASCII art display. |



---



## 📦 What's Included?



This repository provides configurations for a complete, customized Hyprland experience:



| Component | Description |

| :--- | :--- |

| **`hypr`** | Main Hyprland configuration, keybinds, and workspace setup. **(Requires customization)** |

| **`kitty`** | Configuration for the primary terminal emulator. |

| **`fish`** | Configuration for the Fish shell and Starship prompt. |

| **`rofi`** | Custom themes and scripts for the application launcher. |

| **`fastfetch`** | Configuration for displaying system information. |

| **`install.sh`** | Automates package installation and configuration deployment. |

| **`uninstall.sh`** | Reverts changes and restores previous configurations (if a backup exists). |



---



## 🚀 Installation



### Prerequisites



You must be running an **Arch-based Linux distribution** and have basic development tools installed (`git` is required for cloning).



### Step 1: Clone the Repository



Open your terminal and use `git clone` to download the entire repository:



```bash

git clone https://github.com/Echilonvibin/echilon-dotfiles.git

```



```

cd ./echilon-dotfiles

```



```

./install.sh

```




---

## 🗑️ Uninstallation

If you need to revert the changes and restore your system to its previous state (using the backup files created during installation), follow these steps.

### Step 1: Run the Uninstallation Script

Navigate to the repository directory if you are not already there, grant execution permissions, and execute the uninstallation script:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

#Manually Remove Software (Optional)

If you wish to completely remove the installed software, you must run a separate command using your package manager.

# Example command to remove core packages (adjust the list as needed)
```
yay -R nautilus noctalia-shell-git upscayl-bin video-downloader gnome-calculator loupe gcolor3 protonplus mission-center
```
---


