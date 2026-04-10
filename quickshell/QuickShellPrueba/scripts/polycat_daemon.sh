#!/bin/bash

# ¡EL FIX!: Le damos 2 segundos a Hyprland para que termine de cargar todo
sleep 2

# Matamos instancias zombis
killall polycat 2>/dev/null

# Usamos la ruta absoluta por pura seguridad
/usr/bin/polycat | while read -r line; do
    echo "$line" > /tmp/qs_polycat.txt
done