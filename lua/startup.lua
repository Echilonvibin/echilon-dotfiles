local env = {
    "XDG_CURRENT_DESKTOP,Hyprland",
    "XDG_SESSION_TYPE,wayland",
    "QT_QPA_PLATFORMTHEME,qt6ct",
    "QT_AUTO_SCREEN_SCALE_FACTOR,1",
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1",
    "ELECTRON_OZONE_PLATFORM_HINT,wayland",
}

local nvidia_optional = {
    "WLR_NO_HARDWARE_CURSORS,1",
    "LIBVA_DRIVER_NAME,nvidia",
    "GBM_BACKEND,nvidia-drm",
    "__GLX_VENDOR_LIBRARY_NAME,nvidia",
    "NVD_BACKEND,direct",
}

local exec_once = {
    "qs -c noctalia-shell",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1",
    "gnome-keyring-daemon --start --components=secrets",
    "sh -c 'sleep 3 && easyeffects --gapplication-service'",
    "sh -c 'sleep 3 && /usr/lib/xdg-desktop-portal'",
    "sh -c 'sleep 3 && /usr/lib/xdg-desktop-portal-hyprland'",
}

local nvidia_exec_once_optional = {
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
}

-- Optional NVIDIA-specific tweaks. Keep false unless you explicitly want them.
local enable_nvidia_optional = false

for _, item in ipairs(env) do
    local key, value = item:match("^([^,]+),(.+)$")
    if key and value then
        hl.env(key, value)
    end
end

if enable_nvidia_optional then
    for _, item in ipairs(nvidia_optional) do
        local key, value = item:match("^([^,]+),(.+)$")
        if key and value then
            hl.env(key, value)
        end
    end
end

hl.on("hyprland.start", function()
    for _, cmd in ipairs(exec_once) do
        hl.exec_cmd(cmd)
    end

    if enable_nvidia_optional then
        for _, cmd in ipairs(nvidia_exec_once_optional) do
            hl.exec_cmd(cmd)
        end
    end

    -- Run one final reload after startup commands have had time to initialize.
    hl.exec_cmd([[bash -lc 'sleep 2; hyprctl reload']])
end)

return true
