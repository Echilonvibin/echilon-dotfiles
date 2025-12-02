#! /usr/bin/env python3
import subprocess
import json
import argparse
import time
from collections import defaultdict

def get_hyprctl_binds():
    """Fetch binds from hyprctl in JSON format."""
    for _ in range(5):  # retry up to 5 times
        try:
            result = subprocess.run(
                ["hyprctl", "binds", "-j"],
                capture_output=True,
                text=True,
                check=True
            )
            return json.loads(result.stdout)
        except (subprocess.CalledProcessError, json.JSONDecodeError):
            time.sleep(1)
    print("Failed to fetch binds after retries")
    return []

def parse_description(description):
    if description.startswith("[") and "] " in description:
        headers, main_description = description.split("] ", 1)
        headers = headers.strip("[").split("|")
    else:
        headers = ["Misc", "", "", ""]
        main_description = description

    return {
        "header1": headers[0] if headers else "",
        "header2": headers[1] if len(headers) > 1 else "",
        "header3": headers[2] if len(headers) > 2 else "",
        "header4": headers[3] if len(headers) > 3 else "",
        "description": main_description,
    }

def map_dispatcher(dispatcher):
    return {"exec": "execute"}.get(dispatcher, dispatcher)

def map_codeDisplay(keycode, key):
    if keycode == 0:
        return key
    code_map = {
        61: "slash", 87: "KP_1", 88: "KP_2", 89: "KP_3", 83: "KP_4", 84: "KP_5",
        85: "KP_6", 79: "KP_7", 80: "KP_8", 81: "KP_9", 90: "KP_0",
    }
    return code_map.get(keycode, key)

def map_modDisplay(modmask):
    modkey_map = {
        64: "SUPER", 32: "HYPER", 16: "META", 8: "ALT", 4: "CTRL", 2: "CAPSLOCK", 1: "SHIFT",
    }
    mod_display = []
    for key, name in sorted(modkey_map.items(), reverse=True):
        if modmask >= key:
            modmask -= key
            mod_display.append(name)
    return " ".join(mod_display) if mod_display else ""

def map_keyDisplay(key):
    key_map = {
        "edge:r:d": "Touch right edge downwards",
        "edge:r:l": "Touch right edge left",
        "edge:r:r": "Touch right edge right",
    }
    return key_map.get(key, key)

def expand_meta_data(binds_data):
    submap_keys = {}
    for bind in binds_data:
        if bind.get("has_description", False):
            parsed_description = parse_description(bind["description"])
            bind.update(parsed_description)
        else:
            bind["description"] = f"{map_dispatcher(bind['dispatcher'])} {bind['arg']}"
            bind.update({"header1": "Misc", "header2": "", "header3": "", "header4": ""})
        bind["key"] = map_codeDisplay(bind["keycode"], bind["key"])
        bind["key_display"] = map_keyDisplay(bind["key"])
        bind["mod_display"] = map_modDisplay(bind["modmask"])
        if bind["dispatcher"] == "submap":
            submap_keys[bind["arg"]] = {
                "mod_display": bind["mod_display"],
                "key_display": bind["key_display"],
            }

    for bind in binds_data:
        submap = bind.get("submap", "")
        mod_display = bind["mod_display"] or ""
        key_display = bind["key_display"] or ""
        keys = " + ".join(filter(None, [mod_display, key_display]))
        if submap in submap_keys:
            sm = submap_keys[submap]
            bind["displayed_keys"] = f"{sm['mod_display']} + {sm['key_display']} + {keys}"
            bind["description"] = f"[{submap}] {bind['description']}"
        else:
            bind["displayed_keys"] = keys

def generate_rofi(binds):
    """Generate tab-separated rofi output: KEY ⟶ Description."""
    rofi_lines = []
    for bind in binds:
        if bind.get("catch_all", False):
            continue
        keys = bind.get("displayed_keys", "")
        description = bind.get("description", "")
        rofi_lines.append(f"{keys}\t{description}")
    return "\n".join(rofi_lines) if rofi_lines else "No keybinds found"

def generate_md(binds):
    return "\n".join(f"- **{b['displayed_keys']}**: {b['description']}" for b in binds)

def generate_dmenu(binds):
    return "\n".join(f"{b['displayed_keys']}\t{b['description']}" for b in binds)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Hyprland keybinds hint script")
    parser.add_argument("--show-unbind", action="store_true", help="Show duplicated keybinds")
    parser.add_argument("--format", choices=["json", "md", "dmenu", "rofi"], default="json", help="Output format")
    args = parser.parse_args()

    binds_data = get_hyprctl_binds()
    if binds_data:
        expand_meta_data(binds_data)
        if args.show_unbind:
            bind_map = defaultdict(list)
            for bind in binds_data:
                key = (bind["mod_display"], bind["key_display"])
                bind_map[key].append(bind)
            for (mod_display, key_display), binds in bind_map.items():
                if len(binds) > 1:
                    print(f"unbind = {mod_display} , {key_display}")
        elif args.format == "json":
            print(json.dumps(binds_data, indent=4))
        elif args.format == "md":
            print(generate_md(binds_data))
        elif args.format == "dmenu":
            print(generate_dmenu(binds_data))
        elif args.format == "rofi":
            print(generate_rofi(binds_data))

