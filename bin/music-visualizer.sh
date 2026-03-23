#!/bin/bash

# Aseguramos que el motor de audio esté corriendo
pgrep -x "kwybars-daemon" > /dev/null || kwybars-daemon &

while true; do
    PLAYER_STATUS=$(playerctl status 2>/dev/null)
    WS_JSON=$(hyprctl activeworkspace -j)
    WINDOW_COUNT=$(echo "$WS_JSON" | jq '.windows')

    if [ "$PLAYER_STATUS" = "Playing" ] && [ "$WINDOW_COUNT" -eq 0 ]; then
        if ! pgrep -x "kwybars-overlay" > /dev/null; then
            kwybars-overlay &
        fi
    else
        if pgrep -x "kwybars-overlay" > /dev/null; then
             # EL CAMBIO CLAVE: Matamos el proceso sin dejar que hable
             pkill -9 -x kwybars-overlay
        fi
    fi
    sleep 1
done
