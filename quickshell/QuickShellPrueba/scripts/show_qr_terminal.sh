#!/bin/bash

SSID="$1"
PASS=$(nmcli -s -g 802-11-wireless-security.psk connection show "$SSID" 2>/dev/null)

clear
echo -e "\e[1;36m========================================\e[0m"
echo -e "\e[1;37m  Red Wi-Fi: \e[1;32m$SSID\e[0m"

if [ -z "$PASS" ]; then
    echo -e "\e[1;37m  Contraseña: \e[1;31m(Red Abierta)\e[0m"
    echo -e "\e[1;36m========================================\e[0m"
    echo ""
    # El parámetro ANSIUTF8 dibuja bloques sólidos en la terminal
    qrencode -t ANSIUTF8 "WIFI:S:$SSID;T:nopass;;"
else
    echo -e "\e[1;37m  Contraseña: \e[1;32m$PASS\e[0m"
    echo -e "\e[1;36m========================================\e[0m"
    echo ""
    qrencode -t ANSIUTF8 "WIFI:S:$SSID;T:WPA;P:$PASS;;"
fi

echo ""
# Espera a que presiones cualquier tecla (sin mostrarla) para cerrar
read -n 1 -s -r -p "Presiona cualquier tecla para cerrar..."
