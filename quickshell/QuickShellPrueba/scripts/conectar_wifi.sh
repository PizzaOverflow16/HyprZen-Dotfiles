#!/bin/bash

SSID="$1"
PASS="$2"
LOG="/tmp/qs_wifi_debug.log"

> "$LOG"
echo "[DEBUG] Intentando conectar a la red: $SSID" >> "$LOG"

if [ -z "$PASS" ]; then
    echo "[DEBUG] Sin contraseña ingresada. Intentando usar perfil guardado..." >> "$LOG"
    
    # Capturamos toda la respuesta de NetworkManager
    OUTPUT=$(nmcli connection up id "$SSID" 2>&1)
    echo "$OUTPUT" >> "$LOG"
    
    if echo "$OUTPUT" | grep -iq "éxito\|successfully"; then
        echo "[DEBUG] ¡Éxito usando el perfil guardado!" >> "$LOG"
        exit 0
    fi
    
    # ¡LA TRAMPA DE AUTO-REPARACIÓN!
    # Si detecta que faltan secretos/contraseña en el perfil guardado...
    if echo "$OUTPUT" | grep -iq "secretos\|secrets\|contraseña\|password"; then
        echo "[DEBUG] Perfil inaccesible o sin contraseña. Borrándolo de la memoria..." >> "$LOG"
        nmcli connection delete "$SSID" >> "$LOG" 2>&1
        exit 1
    fi
    
    echo "[DEBUG] Falló por otra razón. Intentando conexión abierta..." >> "$LOG"
    nmcli dev wifi connect "$SSID" >> "$LOG" 2>&1
else
    echo "[DEBUG] Contraseña detectada. Intentando autenticación forzada..." >> "$LOG"
    # Al pasar la clave manualmente, NetworkManager sobrescribe cualquier perfil dañado
    nmcli dev wifi connect "$SSID" password "$PASS" >> "$LOG" 2>&1
fi
