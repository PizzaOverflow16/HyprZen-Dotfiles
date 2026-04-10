#!/bin/bash

# Sacar información de la canción
TITLE=$(playerctl metadata title)
ARTIST=$(playerctl metadata artist)
STATUS=$(playerctl status)

# Si no hay música, salir
if [ -z "$TITLE" ]; then
    exit 0
fi

# Cambiar el icono dependiendo de si está sonando o en pausa
if [ "$STATUS" = "Playing" ]; then
    PLAY_PAUSE="⏸"
else
    PLAY_PAUSE="▶"
fi

# Crear el menú con 3 opciones
options="⏮\n$PLAY_PAUSE\n⏭"

# Lanzar Rofi con el diseño que creamos
chosen=$(echo -e "$options" | rofi -dmenu -i -p "🎵 $TITLE - $ARTIST" -theme /home/elton/dev/config/dotfiles/rofi/mediaplayer.rasi)

# Ejecutar la acción según el botón que presiones
case "$chosen" in
    "⏮") playerctl previous ;;
    "⏸" | "▶") playerctl play-pause ;;
    "⏭") playerctl next ;;
esac
