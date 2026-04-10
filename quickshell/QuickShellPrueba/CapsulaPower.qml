import QtQuick
import QtQuick.Layouts

Rectangle {
    id: powerWidget
    signal toggleMenu()
    property bool menuAbierto: false

    implicitHeight: 30
    implicitWidth: 40
    radius: 15

    // ✅ Fondo transparente en reposo. Al pasar el mouse, se vuelve rojo sólido como advertencia.
    color: controlMouse.containsMouse || menuAbierto ? "#F38BA8" : "transparent"

    // ✅ Borde iluminado con el color dominante para que haga juego con el resto de la barra
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        anchors.centerIn: parent
        text: ""
        // ✅ Ícono rojo en reposo. Se vuelve oscuro al pasar el mouse para resaltar sobre el rojo.
        color: controlMouse.containsMouse || menuAbierto ? "#1E1E2E" : "#F38BA8"
        font.pixelSize: 16
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: powerWidget.toggleMenu()
    }
}
