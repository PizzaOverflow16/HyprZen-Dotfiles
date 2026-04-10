#!/bin/bash

while true; do
    # 1. Sacamos la lista de redes guardadas (perfiles)
    nmcli -t -f NAME c 2>/dev/null > /tmp/qs_saved_wifi.txt
    
    # 2. Sacamos la lista de redes visibles
    nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list 2>/dev/null | awk -F':' '!seen[$4]++ && $4 != ""' > /tmp/qs_avail_wifi.txt
    
    # 3. Cruzamos los datos
    > /tmp/qs_wifi_final.txt
    while IFS= read -r line; do
        ssid=$(echo "$line" | cut -d':' -f4-)
        # Si el SSID exacto existe en nuestras redes guardadas, le ponemos :1 al final
        if grep -Fxq "$ssid" /tmp/qs_saved_wifi.txt; then
            echo "${line}:1" >> /tmp/qs_wifi_final.txt
        else
            echo "${line}:0" >> /tmp/qs_wifi_final.txt
        fi
    done < /tmp/qs_avail_wifi.txt
    
    # Movemos el archivo final para que QML lo lea
    mv /tmp/qs_wifi_final.txt /tmp/qs_wifi.txt
    sleep 5
done
