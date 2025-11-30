# echilon-dotfiles
this is my dot files...vibe coded this, may be broken. We'll see. 


# This downloads the script which will install this from this github
```wget https://raw.githubusercontent.com/Gamma195/echilon-dotfiles/main/install.sh```

make it executable, so type the below
chmod +
then drag n drop the script from the folder of which you downloaded it from. 

What the Script Will Do:
The script will automatically perform these critical tasks:

Install Packages: Use pacman to install core components like hyprland, kitty, fish, and rofi.

Install yay: Install the AUR helper yay if it is not already present.

Install AUR Packages: Use yay to install packages like missioncenter, linux-wallpaperengine-git, upscaler, and video-downloader.

Clone Dotfiles: Clone your echilon-dotfiles repository to ~/Source/echilon-dotfiles.

Deploy Configurations: Create symbolic links (symlinks) from the cloned dotfiles directory to the standard configuration directories (~/.config/hypr, ~/.config/rofi, ~/.config/kitty, etc.), replacing any existing configuration files.

After the script finishes, a few steps are required for a perfect setup:

This is for the keybinds for rofi, if you don't need/want it, then you can ignore this
Grant Script Permissions: Ensure the Hyprland scripts (used for your Rofi keybinds menu) can execute:
```chmod +x ~/.config/hypr/Scripts/keyhints```

```chmod +x ~/.config/hypr/Scripts/show-keyhints.sh```

Reboot/Log In: Log out of the current session. At the Display Manager (Login Screen, e.g., GDM, LightDM, SDDM), select the Hyprland session and log back in.
