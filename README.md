# waybar-config

Конфиг Waybar с:

- блоком **погода + календарь**, который раскрывается при наведении (`group/weather_calendar` + `drawer`);
- поддержкой **Spotify** через модуль `mpris`;
- анимациями отклика при изменении **громкости** и **яркости**.

## Файлы

- `.config/waybar/config.jsonc` — основной конфиг Waybar;
- `.config/waybar/style.css` — стили и анимации;
- `.config/waybar/scripts/weather.sh` — данные погоды с wttr.in;
- `.config/waybar/scripts/volume.sh` — громкость PipeWire (`wpctl`);
- `.config/waybar/scripts/brightness.sh` — яркость (`brightnessctl`).

## Зависимости

- `waybar`
- `curl`
- `pipewire` / `wireplumber` (`wpctl`)
- `brightnessctl`
- (опционально) `playerctl` и запущенный Spotify-клиент для MPRIS
