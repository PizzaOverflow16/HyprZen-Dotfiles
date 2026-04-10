// /home/elton/.config/matugen/templates/Tema.qml
import QtQuick

QtObject {
    // Colores base generados por Matugen
    property string primario: "{{colors.primary.default.hex}}"
    property string secundario: "{{colors.secondary.default.hex}}"
    property string fondoSuperficie: "{{colors.surface.default.hex}}"
    property string fondoVariante: "{{colors.surface_variant.default.hex}}"
    property string textoPrimario: "{{colors.on_surface.default.hex}}"

    // Tus reglas de diseño personalizadas basadas en Matugen
    property string barraFondo: "#11111B" // Negro/Gris súper oscuro constante
    property string capsulaFondo: "#1E1E2E" // Fondo base de cápsula
    property string capsulaHover: Qt.alpha("{{colors.primary_container.default.hex}}", 0.4) // Hover suave que hace contraste

    // Transparencias para flotantes
    property string flotanteFondo: Qt.alpha("{{colors.surface.default.hex}}", 0.85) // Transparencia a tono
    property string flotanteBorde: "{{colors.primary.default.hex}}"
}
