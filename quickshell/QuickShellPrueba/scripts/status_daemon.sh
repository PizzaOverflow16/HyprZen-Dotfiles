#!/bin/bash

export LC_ALL=C

contador=0

# --- AUTO-DETECTAR INTERFAZ WIFI ---
# Busca en el sistema la primera tarjeta de red que empiece con "wl" (wireless)
WIFI_IFACE=$(ls /sys/class/net/ | grep -E '^wl' | head -n 1)
if [ -z "$WIFI_IFACE" ]; then WIFI_IFACE="wlan0"; fi # Respaldo por si acaso

# Variables iniciales del monitor de red
rx_old=$(cat /sys/class/net/$WIFI_IFACE/statistics/rx_bytes 2>/dev/null)
tx_old=$(cat /sys/class/net/$WIFI_IFACE/statistics/tx_bytes 2>/dev/null)
rx_old=${rx_old:-0} # Si está vacío, ponle 0
tx_old=${tx_old:-0}

while true; do
    # --- 1. RED ---
    # Primero revisamos si hay un cable conectado (interfaces que empiezan con e, como enp o eth)
    eth_ip=$(ip -4 addr show 2>/dev/null | grep inet | grep -E ' enp| eth')

    if [ -n "$eth_ip" ]; then
        # Hay Ethernet
        wifi_icon="󰈀"
        wifi_on="1"
    else
        # No hay Ethernet, revisamos el Wi-Fi normal
        wifi_ip=$(ip -4 addr show $WIFI_IFACE 2>/dev/null | grep inet)
        if [ -n "$wifi_ip" ]; then
            wifi_icon="󰖩"
            wifi_on="1"
        else
            wifi_icon="󰖪"
            wifi_on="0"
        fi
    fi

    # --- 2. VOLUMEN ACTUAL ---
    vol_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    vol_pct=$(echo "$vol_info" | awk '{print int($2 * 100)}')
    if [[ "$vol_info" == *"[MUTED]"* ]] || [ -z "$vol_pct" ]; then
        vol_icon="󰖁"; vol_pct=0
    elif [ "$vol_pct" -gt 60 ]; then vol_icon="󰕾"
    elif [ "$vol_pct" -gt 20 ]; then vol_icon="󰖀"
    else vol_icon="󰕿"; fi

    # --- 2.5 MICRÓFONO ACTUAL ---
    mic_info=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
    mic_pct=$(echo "$mic_info" | awk '{print int($2 * 100)}')
    if [[ "$mic_info" == *"[MUTED]"* ]] || [ -z "$mic_pct" ]; then
        mic_icon="󰍭"; mic_pct=0
    else
        mic_icon="󰍬"
    fi

    # --- 3. ESCÁNER DE SALIDAS (SINKS) ---
    > /tmp/qs_sinks_temp.txt
    current_dev_icon="󰌢"
    current_dev_name="Sistema"

    wpctl status | awk '/Sinks:/{f=1; next} /Sources:/{f=0} f' | grep -E "[0-9]+\." | while read -r line; do
        is_active=0
        if echo "$line" | grep -q "\*"; then is_active=1; fi

        id=$(echo "$line" | grep -oE '[0-9]+\.' | head -n 1 | tr -d '.')
        name=$(echo "$line" | sed -E 's/^[│├└─* ]*[0-9]+\.[ ]*//' | sed -E 's/ \[.*$//' | sed 's/[ \t]*$//')

        if echo "$name" | grep -iq "headset\|headphone\|bluez\|airpods\|buds"; then icon="󰋋"
        elif echo "$name" | grep -iq "hdmi\|monitor\|tv"; then icon="󰍹"
        elif echo "$name" | grep -iq "usb\|bose\|jbl\|speaker"; then icon="󰓃"
        else icon="󰌢"; fi

        if [ "$is_active" = "1" ]; then
            current_dev_icon="$icon"
            current_dev_name="$name"
        fi

        echo "$id|$name|$icon|$is_active" >> /tmp/qs_sinks_temp.txt
    done
    mv /tmp/qs_sinks_temp.txt /tmp/qs_audio_sinks.txt

    # --- 3.5 ESCÁNER DE ENTRADAS (MICRÓFONOS) ---
    > /tmp/qs_sources_temp.txt
    current_mic_name="Micrófono"

    wpctl status | awk '/Sources:/{f=1; next} /Filters:|Streams:|Video:/{f=0} f' | grep -E "[0-9]+\." | while read -r line; do
        is_active_mic=0
        if echo "$line" | grep -q "\*"; then is_active_mic=1; fi

        mic_id=$(echo "$line" | grep -oE '[0-9]+\.' | head -n 1 | tr -d '.')
        mic_name=$(echo "$line" | sed -E 's/^[│├└─* ]*[0-9]+\.[ ]*//' | sed -E 's/ \[.*$//' | sed 's/[ \t]*$//')
        mic_icon_list="󰍬"

        if [ "$is_active_mic" = "1" ]; then
            current_mic_name="$mic_name"
        fi

        echo "$mic_id|$mic_name|$mic_icon_list|$is_active_mic" >> /tmp/qs_sources_temp.txt
    done
    mv /tmp/qs_sources_temp.txt /tmp/qs_audio_sources.txt

    # --- 4. BATERÍA ---
    bat_cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    bat_stat=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    if [ "$bat_stat" = "Charging" ]; then bat_icon="󰂄"
    else
        if [ -z "$bat_cap" ]; then bat_icon="󰂎"; bat_cap="0"
        elif [ "$bat_cap" -gt 90 ]; then bat_icon="󰁹"
        elif [ "$bat_cap" -gt 60 ]; then bat_icon="󰂀"
        elif [ "$bat_cap" -gt 30 ]; then bat_icon="󰁼"
        elif [ "$bat_cap" -gt 10 ]; then bat_icon="󰁺"
        else bat_icon="󰂎"; fi
    fi

    # --- 5. CENTRO DE CONTROL ---
    bt_state=$(rfkill list bluetooth 2>/dev/null | grep -i "soft blocked: yes")
    if [ -z "$bt_state" ]; then bt_on="1"; else bt_on="0"; fi
    bright_pct=$(brightnessctl -m 2>/dev/null | awk -F, '{print int($4)}')
    if [ -z "$bright_pct" ]; then bright_pct="100"; fi

    # --- 6. LISTA DE BT ---
    if [ $((contador % 3)) -eq 0 ]; then
        bash /home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/control_bt.sh list &
    fi

    # --- 7. VENTANAS MINIMIZADAS (Special Workspace: magic) ---
    > /tmp/qs_minimized_temp.txt
    hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:magic") | "\(.address)|\(.class)|\(.title)"' > /tmp/qs_minimized_temp.txt 2>/dev/null
    grep "|" /tmp/qs_minimized_temp.txt > /tmp/qs_minimized.txt
    min_count=$(cat /tmp/qs_minimized.txt | wc -l)

    # --- 8. MONITOR DE VELOCIDAD DE RED ---
    rx_new=$(cat /sys/class/net/$WIFI_IFACE/statistics/rx_bytes 2>/dev/null)
    tx_new=$(cat /sys/class/net/$WIFI_IFACE/statistics/tx_bytes 2>/dev/null)
    rx_new=${rx_new:-0}
    tx_new=${tx_new:-0}

    # Calculamos la diferencia en 1 segundo y lo pasamos a Kilobytes
    rx_rate=$(( (rx_new - rx_old) / 1024 ))
    tx_rate=$(( (tx_new - tx_old) / 1024 ))

    # Seguro anticongelamiento (por si la red se reinicia y arroja negativos)
    if [ "$rx_rate" -lt 0 ]; then rx_rate=0; fi
    if [ "$tx_rate" -lt 0 ]; then tx_rate=0; fi

    rx_old=$rx_new
    tx_old=$tx_new

    # --- IMPRIMIR TODO ---
    echo "$wifi_icon|$vol_icon|$bat_icon|$bat_cap|$wifi_on|$bt_on|$vol_pct|$bright_pct|$current_dev_icon|$current_dev_name|$mic_icon|$mic_pct|$current_mic_name|$min_count|$rx_rate|$tx_rate" > /tmp/qs_status.txt

    contador=$((contador + 1))
    sleep 1
done
