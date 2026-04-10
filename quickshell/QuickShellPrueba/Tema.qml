// /home/elton/.config/matugen/templates/Tema.qml
import QtQuick

QtObject {
    // Colores base generados por Matugen
    property string primario: "#a6c8ff"
    property string secundario: "#bdc7dc"
    property string fondoSuperficie: "#111318"
    property string fondoVariante: "#43474e"
    property string textoPrimario: "#e1e2e9"

    // Tus reglas de diseño personalizadas basadas en Matugen
    property string barraFondo: "#11111B" // Negro/Gris súper oscuro constante
    property string capsulaFondo: "#1E1E2E" // Fondo base de cápsula
    property string capsulaHover: Qt.alpha("#234776", 0.4) // Hover suave que hace contraste

    // Transparencias para flotantes
    property string flotanteFondo: Qt.alpha("#111318", 0.85) // Transparencia a tono
    property string flotanteBorde: "#a6c8ff"
}
