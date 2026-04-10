#!/bin/bash
mkdir -p /tmp/qs_cava

# Configuramos Cava para que nos de 60 barras, a 30 FPS, en números crudos
cat << 'CONF' > /tmp/qs_cava/config
[general]
framerate = 30
bars = 60
[output]
method = raw
data_format = ascii
ascii_max_range = 100
CONF

killall cava 2>/dev/null

# stdbuf evita que Bash se trague la información y la manda en tiempo real
stdbuf -oL cava -p /tmp/qs_cava/config | while read -r line; do
    echo "$line" > /tmp/qs_cava.txt
done
