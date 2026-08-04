local scrPath = (os.getenv("HOME") or "") .. "/.config/hypr/Scripts"
local mainMod = "SUPER"
local TERMINAL = "kitty"
local EDITOR = "code"
local EXPLORER = "thunar"
local BROWSER = scrPath .. "/browser-launcher.sh"

local KEY = {
	TERMINAL = ("%s + RETURN"):format(mainMod),
	EXPLORER = ("%s + E"):format(mainMod),
	EDITOR = ("%s + C"):format(mainMod),
	BROWSER = ("%s + B"):format(mainMod),
	LAUNCHER = ("%s + D"):format(mainMod),
	LOCK = ("%s + L"):format(mainMod),
	SETTINGS = ("%s + T"):format(mainMod),
	CHEATSHEET_TOGGLE = ("%s + H"):format(mainMod),
	CHEATSHEET_REFRESH = ("%s + SHIFT + H"):format(mainMod),
	HYPR_KEYS_PANEL = ("%s + K"):format(mainMod),
	STEAM = ("%s + S"):format(mainMod),
	MUSIC = ("%s + M"):format(mainMod),
	VIDEO = ("%s + V"):format(mainMod),

	CLOSE = ("%s + Q"):format(mainMod),
	FLOAT = ("%s + W"):format(mainMod),
	FULLSCREEN = ("%s + F"):format(mainMod),

	WORKSPACE_NEXT_MONITOR = ("%s + tab"):format(mainMod),
	WORKSPACE_PREV_MONITOR = ("%s + SHIFT + tab"):format(mainMod),

	FOCUS_LEFT = ("%s + left"):format(mainMod),
	FOCUS_RIGHT = ("%s + right"):format(mainMod),
	FOCUS_UP = ("%s + up"):format(mainMod),
	FOCUS_DOWN = ("%s + down"):format(mainMod),

	RESIZE_RIGHT = ("%s + SHIFT + right"):format(mainMod),
	RESIZE_LEFT = ("%s + SHIFT + left"):format(mainMod),
	RESIZE_UP = ("%s + SHIFT + up"):format(mainMod),
	RESIZE_DOWN = ("%s + SHIFT + down"):format(mainMod),

	MOVE_SWAP_LEFT = ("%s + SHIFT + CTRL + left"):format(mainMod),
	MOVE_SWAP_RIGHT = ("%s + SHIFT + CTRL + right"):format(mainMod),
	MOVE_SWAP_UP = ("%s + SHIFT + CTRL + up"):format(mainMod),
	MOVE_SWAP_DOWN = ("%s + SHIFT + CTRL + down"):format(mainMod),

	SHOT_WINDOW = ("%s + PRINT"):format(mainMod),
	SHOT_ANNOTATE = ("%s + A"):format(mainMod),

	WORKSPACE_NEXT = ("%s + CTRL + right"):format(mainMod),
	WORKSPACE_PREV = ("%s + CTRL + left"):format(mainMod),
	WORKSPACE_EMPTY = ("%s + CTRL + down"):format(mainMod),

	MOVE_TO_NEXT_WORKSPACE = ("%s + CTRL + ALT + right"):format(mainMod),
	MOVE_TO_PREV_WORKSPACE = ("%s + CTRL + ALT + left"):format(mainMod),

	SCROLL_WORKSPACE_NEXT = ("%s + mouse_down"):format(mainMod),
	SCROLL_WORKSPACE_PREV = ("%s + mouse_up"):format(mainMod),

	MOUSE_DRAG = ("%s + mouse:272"):format(mainMod),
	MOUSE_RESIZE = ("%s + mouse:273"):format(mainMod),
	RESIZE_MODE = ("%s + X"):format(mainMod),
}

-- 1. Applications
hl.bind(KEY.TERMINAL, hl.dsp.exec_cmd(TERMINAL), { description = "Terminal" })
hl.bind(KEY.EXPLORER, hl.dsp.exec_cmd(EXPLORER), { description = "File manager" })
hl.bind(KEY.EDITOR, hl.dsp.exec_cmd(EDITOR), { description = "Code editor" })
hl.bind(KEY.BROWSER, hl.dsp.exec_cmd(BROWSER), { description = "Browser" })
hl.bind(KEY.LAUNCHER, hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { description = "Toggle launcher" })
hl.bind(KEY.LOCK, hl.dsp.exec_cmd("qs -c noctalia-shell ipc call lockScreen lock"), { description = "Lock screen" })
hl.bind(KEY.SETTINGS, hl.dsp.exec_cmd("qs -c noctalia-shell ipc call settings toggle"), { description = "Toggle settings" })
hl.bind(KEY.CHEATSHEET_TOGGLE, hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:keybind-cheatsheet toggle"), { description = "Toggle keybind cheatsheet" })
hl.bind(KEY.CHEATSHEET_REFRESH, hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:keybind-cheatsheet refresh"), { description = "Refresh keybind cheatsheet" })
hl.bind(KEY.HYPR_KEYS_PANEL, hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:hyprland-keybinds toggle"), { description = "Toggle hyprland keybinds panel" })
hl.bind(KEY.STEAM, hl.dsp.exec_cmd("steam"), { description = "Steam" })
hl.bind(KEY.MUSIC, hl.dsp.exec_cmd("quodlibet"), { description = "Music player" })
hl.bind(KEY.VIDEO, hl.dsp.exec_cmd("mpv --player-operation-mode=pseudo-gui --force-window=immediate"), { description = "Video player" })

-- 2. Window Management
hl.bind(KEY.CLOSE, hl.dsp.window.close(), { description = "Close window" })
hl.bind(KEY.FLOAT, hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(KEY.FULLSCREEN, hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })

-- 3. Window Navigation & Layout
hl.bind(KEY.WORKSPACE_NEXT_MONITOR, hl.dsp.exec_cmd(scrPath .. "/workspace.sh"), { description = "Next workspace on monitor" })
hl.bind(KEY.WORKSPACE_PREV_MONITOR, hl.dsp.focus({ workspace = "m-1" }), { description = "Previous workspace on monitor" })

hl.bind(KEY.FOCUS_LEFT, hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(KEY.FOCUS_RIGHT, hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(KEY.FOCUS_UP, hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(KEY.FOCUS_DOWN, hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

hl.bind("ALT + tab", hl.dsp.window.cycle_next(), { description = "Cycle windows" })

hl.bind(KEY.RESIZE_RIGHT, function() hl.exec_cmd("hyprctl dispatch resizeactive 30 0") end, { description = "Resize window right" })
hl.bind(KEY.RESIZE_LEFT, function() hl.exec_cmd("hyprctl dispatch resizeactive -30 0") end, { description = "Resize window left" })
hl.bind(KEY.RESIZE_UP, function() hl.exec_cmd("hyprctl dispatch resizeactive 0 -30") end, { description = "Resize window up" })
hl.bind(KEY.RESIZE_DOWN, function() hl.exec_cmd("hyprctl dispatch resizeactive 0 30") end, { description = "Resize window down" })

hl.bind(KEY.MOVE_SWAP_LEFT, function() hl.exec_cmd("bash -c 'grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive -30 0 || hyprctl dispatch movewindow l'") end, { description = "Move or swap window left" })
hl.bind(KEY.MOVE_SWAP_RIGHT, function() hl.exec_cmd("bash -c 'grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive 30 0 || hyprctl dispatch movewindow r'") end, { description = "Move or swap window right" })
hl.bind(KEY.MOVE_SWAP_UP, function() hl.exec_cmd("bash -c 'grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive 0 -30 || hyprctl dispatch movewindow u'") end, { description = "Move or swap window up" })
hl.bind(KEY.MOVE_SWAP_DOWN, function() hl.exec_cmd("bash -c 'grep -q true <<< $(hyprctl activewindow -j | jq -r .floating) && hyprctl dispatch moveactive 0 30 || hyprctl dispatch movewindow d'") end, { description = "Move or swap window down" })

-- 4. Screenshots
hl.bind(KEY.SHOT_WINDOW, hl.dsp.exec_cmd("HYPRSHOT_DIR=~/Pictures/Screenshots hyprshot -m window"), { description = "Screenshot window" })
hl.bind("ALT + PRINT",         hl.dsp.exec_cmd("HYPRSHOT_DIR=~/Pictures/Screenshots hyprshot -m output"), { description = "Screenshot monitor" })
hl.bind("SHIFT + PRINT",       hl.dsp.exec_cmd("HYPRSHOT_DIR=~/Pictures/Screenshots hyprshot -m region"), { description = "Screenshot region" })
hl.bind(KEY.SHOT_ANNOTATE, hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename - --output-filename ~/Pictures/Screenshots/Screenshot-$(date '+%Y%m%d-%H:%M:%S').png"), { description = "Annotate screenshot" })

-- 5. Workspace Switching
for i = 1, 9 do
	local focusKey = ("%s + %d"):format(mainMod, i)
	local moveKey = ("%s + SHIFT + %d"):format(mainMod, i)
	hl.bind(focusKey, hl.dsp.focus({ workspace = i }), { description = "Workspace " .. i })
	hl.bind(moveKey, hl.dsp.window.move({ workspace = i }), { description = "Move to workspace " .. i })
end
hl.bind(("%s + 0"):format(mainMod), hl.dsp.focus({ workspace = 10 }), { description = "Workspace 10" })
hl.bind(("%s + SHIFT + 0"):format(mainMod), hl.dsp.window.move({ workspace = 10 }), { description = "Move to workspace 10" })

-- 6. Workspace Navigation
hl.bind(KEY.WORKSPACE_NEXT, hl.dsp.focus({ workspace = "r+1" }), { description = "Next workspace" })
hl.bind(KEY.WORKSPACE_PREV, hl.dsp.focus({ workspace = "r-1" }), { description = "Previous workspace" })
hl.bind(KEY.WORKSPACE_EMPTY, hl.dsp.focus({ workspace = "empty" }), { description = "Open empty workspace" })

-- 7. Move Window Across Workspaces
hl.bind(KEY.MOVE_TO_NEXT_WORKSPACE, hl.dsp.window.move({ workspace = "r+1" }), { description = "Move to next workspace" })
hl.bind(KEY.MOVE_TO_PREV_WORKSPACE, hl.dsp.window.move({ workspace = "r-1" }), { description = "Move to previous workspace" })

-- 8. Mouse Workspace Navigation
hl.bind(KEY.SCROLL_WORKSPACE_NEXT, hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll to next workspace" })
hl.bind(KEY.SCROLL_WORKSPACE_PREV, hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll to previous workspace" })

-- 9. Mouse Window Management
hl.bind(KEY.MOUSE_DRAG, hl.dsp.window.drag(),   { mouse = true, description = "Drag window" })
hl.bind(KEY.MOUSE_RESIZE, hl.dsp.window.resize(), { mouse = true, description = "Resize window" })
hl.bind(KEY.RESIZE_MODE, hl.dsp.window.resize(), { description = "Resize mode" })

-- 10. Media
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play or pause" })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Next track" })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Previous track" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"),         { locked = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"),         { locked = true, description = "Volume down" })

return true
