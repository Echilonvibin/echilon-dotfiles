#!/bin/bash

for b in brave-browser brave-origin brave firefox zen-browser vivaldi librewolf; do
    if command -v "$b" >/dev/null 2>&1; then
        exec "$b" "$@"
        exit 0
    fi
done

if flatpak info com.brave.Browser >/dev/null 2>&1; then
    exec flatpak run com.brave.Browser "$@"
    exit 0
fi

if flatpak info com.vivaldi.Vivaldi >/dev/null 2>&1; then
    exec flatpak run com.vivaldi.Vivaldi "$@"
    exit 0
fi

# If nothing found
notify-send "No browser found" "Install Brave, Firefox, Zen Browser, Vivaldi, or LibreWolf."
