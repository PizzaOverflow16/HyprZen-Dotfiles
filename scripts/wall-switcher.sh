#!/bin/bash

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
    exit 0
fi

EXTENSION="${WALLPAPER##*.}"
FILENAME=$(basename "$WALLPAPER")
NAME_ONLY="${FILENAME%.*}"
THUMB_DIR="/home/elton/dev/config/dotfiles/Wallpapers/.thumbnails"

# --- LÓGICA DE APLICACIÓN ---

if [[ "$EXTENSION" == "mp4" || "$EXTENSION" == "webm" || "$EXTENSION" == "mkv" ]]; then
    # ES UN VIDEO
    killall swww-daemon 2>/dev/null
    killall mpvpaper 2>/dev/null
    mpvpaper -o "no-audio --loop-playlist" "*" "$WALLPAPER" &
    
    # ¡El truco maestro! Matugen extrae los colores de la miniatura estática
    matugen image "$THUMB_DIR/${NAME_ONLY}.jpg" -m dark -t scheme-tonal-spot --source-color-index 0
else
    # ES UNA IMAGEN
    killall mpvpaper 2>/dev/null
    swww query || swww-daemon &
    swww img "$WALLPAPER" --transition-type wipe
    
    # Matugen extrae directo de la imagen
    matugen image "$WALLPAPER" -m dark -t scheme-tonal-spot --source-color-index 0
fi

# Reiniciar interfaces
#killall waybar
#waybar > /dev/null 2>&1 &
#swaync-client -rs
killall -USR1 kitty
