#!/bin/bash

# Ruta a tu tema de cristal
THEME="/home/elton/dev/config/dotfiles/rofi/config.rasi"

# Usamos cliphist para obtener la lista y se la pasamos a Rofi
case $1 in
    d)
        # Modo borrar: Seleccionas y eliminas del historial
        cliphist list | rofi -dmenu -i -p "Borrar del portapapeles:" -theme $THEME | cliphist decode | cliphist delete
        ;;
    *)
        # Modo normal: Copiar al portapapeles
        result=$(cliphist list | rofi -dmenu -i -p "Portapapeles:" -theme $THEME)

        # Si el usuario seleccionó algo (no presionó Esc), lo copiamos
        if [ ! -z "$result" ]; then
            echo "$result" | cliphist decode | wl-copy
            # ✅ Metemos el símbolo Nerd Font directo en el título y quitamos la imagen
            notify-send -a "Sistema" "󰅍 Portapapeles" "Texto copiado al historial"
        fi
        ;;
esac
