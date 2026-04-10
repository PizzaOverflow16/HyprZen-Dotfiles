#!/usr/bin/env python3
import os, glob, json

try:
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk
    tema_iconos = Gtk.IconTheme.get_default()

    def icono_es_real(nombre):
        if not nombre: return False
        if nombre.startswith("/"): return os.path.exists(nombre)
        return tema_iconos.has_icon(nombre)
except ImportError:
    def icono_es_real(nombre): return True

# ==========================================
# 1. LA LISTA NEGRA (ELIMINADOR DE BASURA)
# ==========================================
lista_negra = [
    "Xwayland",
    "Zenity",
    "Autostar",
    "Accessibility",
    "Account authentication",
    "LibreOffice XSLT based filters",
    "MATLAB Connector",
    "Night Time Service",
    "User folders update",
    "View file"
]

# ==========================================
# 2. DICCIONARIO PARA LAS QUE SÍ QUIERES CONSERVAR
# ==========================================
correcciones = {
    # Tus herramientas personales
    "Zen Music Downloader": "󰎆",          # Icono de nota musical
    "Reparar Wi-Fi": "󱘖",          # Icono de Wifi con llave inglesa
    "Activar Hotspot": "󱄙",           # Icono de torre de transmisión/hotspot
    "Solucionador de Ecuaciones": "󰪚",    # Icono de calculadora/matemáticas
    "RMPC-OFF": "󰝛",

    "wifi & networking": "󰤨",
    "Day-Night Cycle": "󰖨",
    "Connection Preferences": "󰤨",
    "Cursor": "󰆽",
    "System Setting": "󰒓",
    "System Settings": "󰒓"
}

directorios = [
    "/usr/share/applications", 
    os.path.expanduser("~/.local/share/applications"),
    "/var/lib/flatpak/exports/share/applications",                  # ✅ Flatpaks del Sistema
    os.path.expanduser("~/.local/share/flatpak/exports/share/applications") # ✅ Flatpaks del Usuario
]
apps = []

icono_por_defecto = "󰀲"
apps_cuadro_morado = []

for d in directorios:
    for f in glob.glob(d + "/**/*.desktop", recursive=True):
        try:
            with open(f, 'r', encoding='utf-8') as archivo:
                name, exec_cmd, icon, comment = "", "", "", ""
                ocultar = False

                for linea in archivo:
                    linea = linea.strip()
                    if linea.startswith("Name=") and not name: name = linea.split("=", 1)[1].strip()
                    elif linea.startswith("Exec=") and not exec_cmd: exec_cmd = linea.split("=", 1)[1].strip().split("%")[0].strip()
                    elif linea.startswith("Icon=") and not icon: icon = linea.split("=", 1)[1].strip()
                    elif linea.startswith("Comment=") and not comment: comment = linea.split("=", 1)[1].strip()

                    elif linea.startswith("NoDisplay=true") or linea.startswith("NoDisplay=True") or linea.startswith("Hidden=true") or linea.startswith("Hidden=True"):
                        ocultar = True

                if name and exec_cmd and not ocultar and name not in lista_negra:
                    if name in correcciones:
                        icon = correcciones[name]

                    es_texto = False

                    if not icon:
                        icon = icono_por_defecto
                        es_texto = True
                    elif len(icon) <= 3:
                        es_texto = True
                    elif not icono_es_real(icon):
                        apps_cuadro_morado.append((name, icon))
                        icon = icono_por_defecto
                        es_texto = True

                    apps.append({
                        "name": name,
                        "exec": exec_cmd,
                        "icon": icon,
                        "comment": comment,
                        "isCalc": False,
                        "isTextIcon": es_texto
                    })
        except: pass

# ==========================================
# GUARDADO Y REPORTES
# ==========================================
apps_unicas = { app['name']: app for app in apps }.values()

ruta_json = os.path.expanduser("~/.config/quickshell/apps.json")
with open(ruta_json, "w", encoding="utf-8") as out:
    json.dump(list(apps_unicas), out)

print("\n✅ ¡JSON generado! Tu launcher ahora está limpio de basura.")

if apps_cuadro_morado:
    print("\n🚨 SE DETECTARON POSIBLES CUADROS MORADOS EN APPS VISIBLES 🚨")
    for nombre, icono_falso in sorted(set(apps_cuadro_morado)):
        print(f" ❌ {nombre} (Pedía: '{icono_falso}')")

# ==========================================
# EL DETECTOR DE APPS PERSONALES
# ==========================================
print("\n🕵️ TUS APLICACIONES CREADAS MANUALMENTE:")
carpeta_personal = os.path.expanduser("~/.local/share/applications")
if os.path.exists(carpeta_personal):
    archivos_personales = [f for f in os.listdir(carpeta_personal) if f.endswith(".desktop")]
    if archivos_personales:
        for archivo in archivos_personales:
            print(f" 🛠️  {archivo}")
    else:
        print(" No tienes archivos .desktop en tu carpeta local.")
else:
    print(" No se encontró la carpeta de aplicaciones locales.")
