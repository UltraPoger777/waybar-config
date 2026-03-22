# waybar-config

Waybar setup with:

- weather module on the left;
- Hyprland workspace indicator between weather and centered time;
- centered time module with tooltip that shows calendar + TODO side-by-side;
- TODO manager menu (add/toggle/remove) on click;
- quick settings menu for Wi-Fi / Bluetooth / Hotspot with network selection;
- media/player bubble with fallback text when nothing is playing;
- battery module on the right;
- animated feedback + progress indicators for volume and brightness;
- transparent bar background with bubble-style modules.

## Files

- `.config/waybar/config.jsonc` - main Waybar config;
- `.config/waybar/style.css` - styles and animations;
- `.config/waybar/scripts/weather.sh` - weather data from wttr.in;
- `.config/waybar/scripts/time_todo.sh` - time module with combined calendar + TODO tooltip;
- `.config/waybar/scripts/todo_menu.sh` - interactive TODO manager (add/toggle/remove);
- `.config/waybar/scripts/menu_select.sh` - dmenu backend wrapper (wofi/rofi/fuzzel);
- `.config/waybar/scripts/media.sh` - media status via `playerctl`;
- `.config/waybar/scripts/volume.sh` - PipeWire volume (`wpctl`);
- `.config/waybar/scripts/brightness.sh` - display brightness (`brightnessctl`).
- `.config/waybar/scripts/quick_settings_status.sh` - quick settings icon status;
- `.config/waybar/scripts/quick_settings_menu.sh` - interactive quick settings menu;
- `.config/waybar/scripts/hotspot_toggle.sh` - hotspot toggle helper;
- `.config/waybar/todo.txt` - editable todo list source.

## Dependencies

- `waybar`
- `curl`
- `hyprland`
- `playerctl`
- `networkmanager` (`nmcli`)
- `bluez` (`bluetoothctl`)
- one launcher for menus: `wofi` or `rofi` or `fuzzel`
- `pipewire` / `wireplumber` (`wpctl`)
- `brightnessctl`
