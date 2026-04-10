import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: capsula

    // ✅ Homologamos las medidas con el resto de la barra
    implicitWidth: 40
    implicitHeight: 30
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: mouseArea.containsMouse ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    // Definimos el "grito" que escuchará la barra
    signal clicked()

    Text {
        anchors.centerIn: parent
        text: "󰸉" // Icono de wallpaper/galería
        // ✅ Ícono teñido con el color principal del sistema
        color: root.tema.primario
        font.pixelSize: 18
        Behavior on color { ColorAnimation { duration: 300 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: capsula.clicked()
    }
}
