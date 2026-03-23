#!/bin/bash

DIR="/home/hyperZen/dev/config/dotfiles/Wallpapers"
TEMP_FILE="/tmp/selected_wall"

rm -f "$TEMP_FILE"
python /home/hyperZen/dev/config/dotfiles/scripts/galeria.py "$DIR"

if [ ! -f "$TEMP_FILE" ]; then
    exit 0
fi

WALLPAPER=$(cat "$TEMP_FILE")
EXTENSION="${WALLPAPER##*.}"

# --- LÓGICA DE APLICACIÓN ---

if [[ "$EXTENSION" == "mp4" || "$EXTENSION" == "webm" || "$EXTENSION" == "mkv" ]]; then
    # ES UN VIDEO: Usamos mpvpaper
    killall swww-daemon 2>/dev/null
    killall mpvpaper 2>/dev/null
    # -o son las opciones de mpv (sin audio y en bucle)
    mpvpaper -o "no-audio --loop-playlist" "*" "$WALLPAPER" &
else
    # ES UNA IMAGEN: Usamos swww
    killall mpvpaper 2>/dev/null
    # Si swww no está corriendo, lo iniciamos
    swww query || swww-daemon &
    swww img "$WALLPAPER" --transition-type wipe
fi

# Matugen sigue extrayendo colores (funciona igual con el primer frame del video)
matugen image "$WALLPAPER" -m dark -t scheme-tonal-spot --source-color-index 0

# Reiniciar interfaces
killall waybar
waybar > /dev/null 2>&1 &
swaync-client -rs
killall -USR1 kitty
