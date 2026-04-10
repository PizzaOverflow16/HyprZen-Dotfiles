#!/bin/bash

# Ruta a tu archivo
AGENDA="/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/agenda.json"
HOY=$(date +"%Y-%-m-%-d")

# Extraer todas las tareas de hoy y darles formato de lista
TAREAS=$(cat "$AGENDA" | jq -r ".\"$HOY\"[]?" 2>/dev/null)

if [ ! -z "$TAREAS" ]; then
    # Convertimos la lista en un formato bonito con puntos
    RESUMEN=$(echo "$TAREAS" | sed 's/^/• /')

    # Enviamos una sola notificación con todo lo del día
    notify-send "📅 Tareas para hoy" "$RESUMEN" -i appointment-soon -t 10000
fi
