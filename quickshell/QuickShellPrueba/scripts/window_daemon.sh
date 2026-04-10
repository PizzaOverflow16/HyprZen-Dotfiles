#!/bin/bash
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if [[ "$line" == "activewindow"* ]] || [[ "$line" == "activewindowv2"* ]] || [[ "$line" == "closewindow"* ]]; then
        # Obtenemos la clase de la ventana (ej: firefox, kitty, code-oss)
        clase=$(hyprctl activewindow | grep "class: " | awk '{print $2}')
        
        # Si cerramos todas las ventanas, mostramos "Escritorio"
        if [ -z "$clase" ]; then
            echo "Escritorio" > /tmp/qs_window.txt
        else
            echo "$clase" > /tmp/qs_window.txt
        fi
    fi
done
