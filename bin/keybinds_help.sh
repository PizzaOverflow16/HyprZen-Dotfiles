#!/bin/bash

# Definimos la lista con secciones y separadores visuales
map="
󰨇  --- GESTIÓN DE VENTANAS ---
󰌌  Super + Q            ➜  Cerrar ventana activa
󱂬  Super + V            ➜  Alternar Flotante
󰀻  Super + P/J          ➜  Modos Dwindle (Pseudo/Split)
󱊄  Super + [+] / [-]    ➜  Redimensionar Ancho
󱊄  Super + Shft [+] / [-] ➜ Redimensionar Alto
󰍽  Super + Clic Izq/Der ➜  Mover / Redimensionar con el ratón

󰄀  --- NAVEGACIÓN (WORKSPACES) ---
󰄀  Super + [0-9]        ➜  Ir al Escritorio 1-10
󰒉  Super + Shft [0-9]   ➜  Enviar ventana al Escritorio 1-10
󱂶  Super + Flechas      ➜  Mover el foco entre ventanas
󰆽  Super + Shft Flechas ➜  Intercambiar posición de ventana
󰄀  Super + S            ➜  Abrir/Cerrar Workspace Mágico (Scratchpad)
󰄀  Super + Shft + S     ➜  Enviar ventana al Workspace Mágico
󰍽  Super + Rueda Ratón  ➜  Navegar por Workspaces con ratón

󰭻  --- HERRAMIENTAS Y APPS ---
󰌌  Super + Enter        ➜  Terminal (\$terminal)
󰉋  Super + E            ➜  Explorador (Nautilus)
󰀻  Super + Espacio      ➜  Lanzador de Apps (Rofi)
󰸉  Super + W            ➜  Cambiar Wallpaper y Tema Dinámico
󰒆  Super + L            ➜  Bloquear pantalla (Hyprlock)
󰅍  Super + Z            ➜  Historial portapapeles (Cliphist)
󰁨  Super + Shift + X    ➜  BORRAR historial de portapapeles
󰭻  Super + T            ➜  WhatsApp

󰄀  --- CAPTURAS (HYPRSHOT) ---
󰹑  Super + Shift + P    ➜  Captura Pantalla Completa
󰒉  Super + Shift + R    ➜  Captura Región Seleccionada
"

# Lanzamos rofi con el estilo de tu carpeta personal
echo -e "$map" | rofi -dmenu -i -p "󰌌 Guía de Atajos" -config /home/elton/dev/config/dotfiles/rofi/config.rasi