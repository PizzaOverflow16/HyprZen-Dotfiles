 #!/bin/bash


# Sacar información de la canción

TITLE=$(playerctl metadata title)

ARTIST=$(playerctl metadata artist)

STATUS=$(playerctl status)


# Si no hay música, salir

if [ -z "$TITLE" ]; then

    exit 0

fi


# Cambiar el texto dependiendo de si está sonando o en pausa

if [ "$STATUS" = "Playing" ]; then

    PLAY_PAUSE="⏸  Pausar"

else

    PLAY_PAUSE="▶  Reproducir"

fi


# Opciones en lista vertical

options="⏮  Anterior\n$PLAY_PAUSE\n⏭  Siguiente"


# Ejecutar Wofi centrado arriba, justo debajo de la barra

chosen=$(echo -e "$options" | wofi -d -p "🎵 $TITLE" --style /home/elton/dev/config/dotfiles/wofi/media-style.css -W 350 -H 190 --location top --yoffset 60)


# Ejecutar la acción según la opción elegida

case "$chosen" in

    "⏮  Anterior") playerctl previous ;;

    "⏸  Pausar" | "▶  Reproducir") playerctl play-pause ;;

    "⏭  Siguiente") playerctl next ;;

esac 
