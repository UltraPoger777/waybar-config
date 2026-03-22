# waybar-config

Waybar setup with:

- weather module on the left;
- Hyprland workspace indicator between weather and centered time;
- centered time module with calendar tooltip;
- hover drawer near time with inline to-do list;
- quick settings hover drawer (Wi-Fi / Bluetooth / Hotspot);
- media/player bubble with fallback text when nothing is playing;
- battery module on the right;
- animated feedback + progress indicators for volume and brightness;
- transparent bar background with bubble-style modules.

## Files

- `.config/waybar/config.jsonc` - main Waybar config;
- `.config/waybar/style.css` - styles and animations;
- `.config/waybar/scripts/weather.sh` - weather data from wttr.in;
- `.config/waybar/scripts/todo_inline.sh` - inline todo preview for hover next to clock;
- `.config/waybar/scripts/todo.sh` - parses todo list and shows pending count;
- `.config/waybar/scripts/media.sh` - media status via `playerctl`;
- `.config/waybar/scripts/volume.sh` - PipeWire volume (`wpctl`);
- `.config/waybar/scripts/brightness.sh` - display brightness (`brightnessctl`).
- `.config/waybar/scripts/wifi_status.sh` / `wifi_toggle.sh` - Wi-Fi status and toggle;
- `.config/waybar/scripts/bluetooth_status.sh` / `bluetooth_toggle.sh` - Bluetooth status and toggle;
- `.config/waybar/scripts/hotspot_status.sh` / `hotspot_toggle.sh` - Hotspot status and toggle;
- `.config/waybar/todo.txt` - editable todo list source.

## Dependencies

- `waybar`
- `curl`
- `hyprland`
- `playerctl`
- `networkmanager` (`nmcli`)
- `bluez` (`bluetoothctl`)
- `pipewire` / `wireplumber` (`wpctl`)
- `brightnessctl`
