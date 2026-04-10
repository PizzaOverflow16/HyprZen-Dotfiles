#!/bin/bash

WALL_DIR="/home/elton/dev/config/dotfiles/Wallpapers"
THUMB_DIR="$WALL_DIR/.thumbnails"

# Crea la carpeta oculta para las miniaturas si no existe
mkdir -p "$THUMB_DIR"

# Escanea los formatos de video
for video in "$WALL_DIR"/*.{mp4,webm,mkv}; do
    # Evita errores si la carpeta no tiene algún formato específico
    [ -e "$video" ] || continue
    
    filename=$(basename "$video")
    # Cambia la extensión del archivo a .jpg para la miniatura
    thumb="$THUMB_DIR/${filename%.*}.jpg"

    # Solo extrae el fotograma si la miniatura no existe (ahorra CPU en ejecuciones futuras)
    if [ ! -f "$thumb" ]; then
        echo "Generando miniatura para $filename..."
        # -ss 00:00:01 salta al primer segundo (evita pantallas en negro al inicio)
        # -vframes 1 saca exactamente una foto
        ffmpeg -i "$video" -ss 00:00:01 -vframes 1 -q:v 2 "$thumb" -y > /dev/null 2>&1
    fi
done

echo "¡Extracción de miniaturas finalizada!"