import QtQuick
import Quickshell

QtObject {
    // Leemos la variable que manda Hyprland/Waybar
    property string modo: Quickshell.env("WIDGET")

    // Instanciamos el reproductor como una propiedad
    property var reproductor: Reproductor {
        visible: modo !== "galeria" // Se muestra si no es galería
    }

    // Instanciamos la galería como una propiedad
    property var galeria: Galeria {
        visible: modo === "galeria" // Solo se muestra si piden galería
    }
}
