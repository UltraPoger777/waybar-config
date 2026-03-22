# waybar-config

Waybar setup with:

- weather module on the left;
- calendar tooltip when hovering the time module;
- Spotify support via `mpris`;
- battery module on the right;
- animated feedback for volume and brightness updates;
- transparent bar background with bubble-style modules.

## Files

- `.config/waybar/config.jsonc` - main Waybar config;
- `.config/waybar/style.css` - styles and animations;
- `.config/waybar/scripts/weather.sh` - weather data from wttr.in;
- `.config/waybar/scripts/volume.sh` - PipeWire volume (`wpctl`);
- `.config/waybar/scripts/brightness.sh` - display brightness (`brightnessctl`).

## Dependencies

- `waybar`
- `curl`
- `pipewire` / `wireplumber` (`wpctl`)
- `brightnessctl`
- (optional) running Spotify client for MPRIS
