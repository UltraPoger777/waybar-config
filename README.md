# waybar-config

Waybar setup with:

- weather module on the left;
- Hyprland workspace indicator in the center;
- calendar tooltip when hovering the time module;
- to-do counter next to the clock/calendar;
- Spotify support via `mpris`;
- battery module on the right;
- animated feedback for volume and brightness updates;
- transparent bar background with bubble-style modules.

## Files

- `.config/waybar/config.jsonc` - main Waybar config;
- `.config/waybar/style.css` - styles and animations;
- `.config/waybar/scripts/weather.sh` - weather data from wttr.in;
- `.config/waybar/scripts/todo.sh` - parses todo list and shows pending count;
- `.config/waybar/scripts/volume.sh` - PipeWire volume (`wpctl`);
- `.config/waybar/scripts/brightness.sh` - display brightness (`brightnessctl`).
- `.config/waybar/todo.txt` - editable todo list source.

## Dependencies

- `waybar`
- `curl`
- `hyprland`
- `pipewire` / `wireplumber` (`wpctl`)
- `brightnessctl`
- (optional) running Spotify client for MPRIS
