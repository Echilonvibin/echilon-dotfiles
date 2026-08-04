hl.config({
    input = {
        kb_layout = "us",
        kb_options = "",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.5,
        },
        special_fallthrough = true,
        follow_mouse = 1,
    },
})

local gestures = {
    "3, horizontal, workspace",
    "3, pinchin,float,tile",
    "3, pinchout,float, float",
}

for _, gesture in ipairs(gestures) do
    hl.exec_cmd(("hyprctl keyword gesture %q"):format(gesture))
end
