# waybar-config

Легкокастомизируемый конфиг Waybar под ноутбук (включая Lenovo LOQ с Intel i7 + NVIDIA RTX 4060).

## Что внутри

- `waybar/config.jsonc` — модули и логика бара.
- `waybar/style.css` — тема, цвета, отступы и внешний вид.
- `waybar/scripts/nvidia-status.sh` — модуль телеметрии NVIDIA (util/temp/VRAM/power).

## Установка

```bash
mkdir -p ~/.config/waybar/scripts
cp waybar/config.jsonc ~/.config/waybar/config.jsonc
cp waybar/style.css ~/.config/waybar/style.css
cp waybar/scripts/nvidia-status.sh ~/.config/waybar/scripts/nvidia-status.sh
chmod +x ~/.config/waybar/scripts/nvidia-status.sh
```

Перезапусти Waybar:

```bash
pkill waybar; waybar
```

## Быстрый кастом

1. **Порядок модулей**
   - Правь массивы `modules-left`, `modules-center`, `modules-right` в `config.jsonc`.
2. **Цвета и скругления**
   - Правь переменные в начале `style.css` (`@define-color ...`).
3. **Пороговые значения**
   - CPU/GPU температура и батарея настраиваются в `config.jsonc`.
4. **Иконки/форматы**
   - Меняй `format` и `format-icons` у нужного модуля.

## Примечания для Lenovo LOQ (i7 + RTX 4060)

- NVIDIA-модуль использует `nvidia-smi`. Если dGPU выключен (runtime PM/prime), будет показано `NVIDIA off`.
- Яркость берется из стандартного backlight-интерфейса ядра Linux.
- Если ты используешь другой лаунчер или терминал, замени:
  - `wofi --show drun` (кнопка Apps),
  - `alacritty -e nvidia-smi` (клик по GPU-модулю).
