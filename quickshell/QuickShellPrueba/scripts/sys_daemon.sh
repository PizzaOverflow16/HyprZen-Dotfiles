#!/bin/bash
while true; do
    # 1. CPU
    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    total1=$((user+nice+system+idle+iowait+irq+softirq+steal))
    idle1=$((idle+iowait))
    sleep 1 # Pausa real para calcular la carga de CPU
    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    total2=$((user+nice+system+idle+iowait+irq+softirq+steal))
    idle2=$((idle+iowait))
    cpu_usage=$((100 * ( (total2-total1) - (idle2-idle1) ) / (total2-total1) ))

    # 2. RAM
    ram_usage=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

    # 3. DISCO
    disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    # 4. TEMPERATURA (Buscando el sensor universal térmico de Linux o el primer hwmon válido)
    temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1 || echo "0")
    temp_c=$((temp_raw / 1000))

    # Escribimos los datos crudos separados por una barra vertical
    echo "$cpu_usage|$ram_usage|$disk_usage|$temp_c" > /tmp/qs_sys.txt
done
