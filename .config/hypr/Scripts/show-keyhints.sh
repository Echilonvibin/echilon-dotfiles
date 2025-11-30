#!/bin/bash

# Define the path to your Python script
KEYHINTS_SCRIPT="/home/echilon/.config/hypr/Scripts/keyhints"

# --- Rofi Command Arguments ---
# -d '      ': CRITICAL! Sets the delimiter back to exactly SIX spaces.
# -columns 2: Tells Rofi to use the first two fields as columns.
# -dmenu: Enables piping input as the list source.
# -p "Keybinds": Sets the prompt text.
# -width 60: Sets a reasonable width.
# -i: Case-insensitive search.
# -markup-rows: Essential for Pango bolding in headers.

"$KEYHINTS_SCRIPT" --format rofi | rofi -d '      ' -p "Keybinds" -width 60 -columns 2 -i -markup-rows -dmenu
