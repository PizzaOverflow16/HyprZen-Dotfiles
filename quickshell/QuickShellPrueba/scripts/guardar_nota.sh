#!/bin/bash

DIR="/home/elton/Documentos/NotasRapidas"
mkdir -p "$DIR"

# Usamos la fecha y hora como nombre de archivo para que sean únicos
FECHA=$(date +"%Y-%m-%d_%H-%M-%S")
CONTENIDO="$1"

if [ -n "$CONTENIDO" ]; then
    echo -e "$CONTENIDO" > "$DIR/nota_$FECHA.txt"
    notify-send "Notas Rápidas" "Nota guardada en $DIR" -i edit-paste
fi
