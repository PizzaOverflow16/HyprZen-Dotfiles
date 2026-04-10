#!/bin/bash
while true; do
    # 1. Obtener el ID del espacio actual
    active=$(hyprctl activeworkspace | head -n 1 | awk '{print $3}')
    
    # 2. Obtener todos los IDs de espacios que tienen ventanas
    # Usamos sort -n para que siempre salgan en orden (1, 2, 6...)
    # Añadimos el "active" a la lista y usamos 'uniq' para no duplicar
    all_ws=$( (hyprctl workspaces | awk '/workspace ID/ {print $3}'; echo $active) | sort -nu | paste -sd "," -)
    
    # Mandamos: ACTIVO | LISTA_TOTAL (ej: 1 | 1,2,6)
    echo "$active|$all_ws" > /tmp/qs_workspaces.txt
    sleep 0.1
done
