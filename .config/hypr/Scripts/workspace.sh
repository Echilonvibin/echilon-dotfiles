#!/bin/bash

sleep 0.05

LOCK_FILE="/tmp/hypr-workspace-next.lock"
NOW_MS=$(date +%s%3N)

if [ -f "$LOCK_FILE" ]; then
    LAST_MS=$(cat "$LOCK_FILE" 2>/dev/null)
    if [[ "$LAST_MS" =~ ^[0-9]+$ ]] && [ $((NOW_MS - LAST_MS)) -lt 250 ]; then
        exit 0
    fi
fi

echo "$NOW_MS" > "$LOCK_FILE"

focus_workspace() {
    local ws="$1"
    if [[ "$ws" =~ ^[0-9]+$ ]]; then
        hyprctl dispatch "hl.dsp.focus({ workspace = $ws })"
    else
        hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })"
    fi
}

move_window_to_workspace() {
    local ws="$1"
    if [[ "$ws" =~ ^[0-9]+$ ]]; then
        hyprctl dispatch "hl.dsp.window.move({ workspace = $ws })"
    else
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\" })"
    fi
}

close_active_window() {
    hyprctl dispatch "hl.dsp.window.close()"
}

FOCUSED_MONITOR_NAME=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
CURRENT_ID=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
CURRENT_WINDOWS=$(hyprctl workspaces -j | jq -r '.[] | select(.monitor == "'"$FOCUSED_MONITOR_NAME"'") | select(.id == '$CURRENT_ID') | .windows' | head -n 1)

if [ -z "$CURRENT_WINDOWS" ] || [ "$CURRENT_WINDOWS" = "null" ]; then
    CURRENT_WINDOWS=0
fi

TARGET_ID=""

ACTIVE_IDS_LIST=$(hyprctl workspaces -j | \
    jq -r '.[] | select(.monitor == "'"$FOCUSED_MONITOR_NAME"'") | select(.windows > 0) | .id' | \
    sort -n)

ALL_IDS_LIST=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n)

mapfile -t ACTIVE_IDS < <(printf "%s\n" "$ACTIVE_IDS_LIST")

if [ ${#ACTIVE_IDS[@]} -eq 0 ]; then
    TARGET_ID=$CURRENT_ID
    focus_workspace "$TARGET_ID"
    exit 0
fi

HIGHEST_ACTIVE="${ACTIVE_IDS[$((${#ACTIVE_IDS[@]} - 1))]}"
LOWEST_ACTIVE="${ACTIVE_IDS[0]}"
NUM_ACTIVE=${#ACTIVE_IDS[@]}


NEXT_TARGET_FOUND="false"

for id in "${ACTIVE_IDS[@]}"; do
    if [ "$id" -gt "$CURRENT_ID" ]; then
        TARGET_ID=$id
        NEXT_TARGET_FOUND="true"
        break
    fi
done

if [ "$NEXT_TARGET_FOUND" == "false" ]; then
    if [ "$CURRENT_WINDOWS" -eq 0 ]; then
       
        TARGET_ID=$LOWEST_ACTIVE
    else
        
        TARGET_ID=$((CURRENT_ID + 1))
        while grep -qx "$TARGET_ID" <<< "$ALL_IDS_LIST"; do
            TARGET_ID=$((TARGET_ID + 1))
        done
    fi
fi



focus_workspace "$TARGET_ID"
