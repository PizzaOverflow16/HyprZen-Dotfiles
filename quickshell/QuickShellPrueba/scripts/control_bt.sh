#!/bin/bash

# Ruta: /home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/control_bt.sh

ACCION=$1
MAC=$2
ADAPTER="00:17:9A:2B:5A:A0"

case $ACCION in
    "scan")
        > /tmp/bt_scan_raw.log
        # Encendemos el AGENTE para que los celulares modernos confíen y muestren su nombre
        (echo "select $ADAPTER"; echo "agent on"; echo "default-agent"; sleep 0.2; echo "scan on"; sleep 6; echo "scan off"; sleep 0.2; echo "quit") | bluetoothctl > /tmp/bt_scan_raw.log 2>&1
        bash "$0" list
        ;;

    "connect")
        (echo "select $ADAPTER"; echo "agent on"; echo "default-agent"; sleep 0.2; echo "connect $MAC"; sleep 3; echo "quit") | bluetoothctl > /dev/null 2>&1
        bash "$0" list
        ;;

    "pair")
        (echo "select $ADAPTER"; echo "agent on"; echo "default-agent"; sleep 0.2; echo "pair $MAC"; sleep 2; echo "trust $MAC"; sleep 1; echo "connect $MAC"; sleep 3; echo "quit") | bluetoothctl > /dev/null 2>&1
        bash "$0" list
        ;;

    "disconnect")
        (echo "select $ADAPTER"; sleep 0.2; echo "disconnect $MAC"; sleep 1; echo "quit") | bluetoothctl > /dev/null 2>&1
        bash "$0" list
        ;;

    "list")
        > /tmp/qs_bt_tmp.txt

        # Sacamos dispositivos guardados y limpiamos la salida
        (echo "select $ADAPTER"; sleep 0.2; echo "devices Paired"; sleep 0.2; echo "quit") | bluetoothctl | sed 's/\x1B\[[0-9;]*[mK]//g' | sed 's/^.*# //' | grep "^Device " > /tmp/bt_paired_raw.log
        emparejados=$(grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' /tmp/bt_paired_raw.log)

        # Capturamos TODOS los dispositivos que pasaron por la terminal en el último escaneo O que ya conocíamos
        ( (echo "select $ADAPTER"; sleep 0.2; echo "devices"; sleep 0.2; echo "quit") | bluetoothctl ; cat /tmp/bt_scan_raw.log 2>/dev/null ) | sed 's/\x1B\[[0-9;]*[mK]//g' | grep "Device " | grep -v "Pairable" | grep -v "Discovering" > /tmp/bt_all_raw.log

        while read -r line; do
            mac=$(echo "$line" | grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' | head -n 1)
            name=$(echo "$line" | sed -E "s/.*Device $mac //" | tr -d '\r' | xargs)

            if [ -z "$mac" ] || [ -z "$name" ]; then continue; fi
            if grep -q "$mac" /tmp/qs_bt_tmp.txt 2>/dev/null; then continue; fi

            # Filtro para evitar basuras sin nombre. Comenta la siguiente línea con # si quieres ver TODO.
            if [ "$name" = "$mac" ] || [[ "$name" == "-"* ]]; then continue; fi

            if echo "$emparejados" | grep -i -q "$mac"; then
                is_connected=$( (echo "select $ADAPTER"; sleep 0.1; echo "info $mac"; sleep 0.1; echo "quit") | bluetoothctl | grep -i "Connected: yes" )

                if [ -n "$is_connected" ]; then
                    echo "*|$mac|$name" >> /tmp/qs_bt_tmp.txt
                else
                    echo "P|$mac|$name" >> /tmp/qs_bt_tmp.txt
                fi
            else
                echo "U|$mac|$name" >> /tmp/qs_bt_tmp.txt
            fi
        done < /tmp/bt_all_raw.log

        mv /tmp/qs_bt_tmp.txt /tmp/qs_bt.txt
        ;;
esac
