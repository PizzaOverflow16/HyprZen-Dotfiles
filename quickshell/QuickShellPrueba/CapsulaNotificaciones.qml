import QtQuick
import QtQuick.Layouts

Rectangle {
    id: notifCapsule
    signal toggleMenu()
    property bool menuAbierto: false

    // Escucha directamente al motor de notificaciones que instanciamos en shell.qml (root)
    property int cantidad: root.motorNotificaciones ? root.motorNotificaciones.historial.length : 0
    property bool critica: root.motorNotificaciones ? root.motorNotificaciones.hayCriticas : false

    implicitHeight: 30
    implicitWidth: layoutNotif.implicitWidth + 24
    radius: 15

    // Variable auxiliar para saber si el mouse está encima o el menú está abierto
    property bool isActive: controlMouse.containsMouse || menuAbierto

    // ✅ Fondo transparente en reposo. Hover rojo sólido (si es crítica) o Hover suave de Matugen (si es normal).
    color: isActive ? (critica ? "#F38BA8" : root.tema.capsulaHover) : "transparent"

    // ✅ Borde de emergencia rojo. Si no hay emergencia, usa el color dominante del wallpaper.
    border.color: critica ? "#F38BA8" : root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    RowLayout {
        id: layoutNotif
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: critica ? "󰂢" : "󰂚"
            // ✅ Ícono: Rojo si es crítico. Si pasas el mouse y el fondo se hace rojo sólido, se vuelve oscuro para hacer contraste. Si es normal, usa el primario.
            color: critica ? (isActive ? "#1E1E2E" : "#F38BA8") : root.tema.primario
            font.pixelSize: 18
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Text {
            text: notifCapsule.cantidad.toString()
            // ✅ Texto: Oscuro solo si el fondo es rojo sólido, de lo contrario usa el texto adaptable de Matugen.
            color: critica && isActive ? "#1E1E2E" : root.tema.textoPrimario
            font.pixelSize: 13
            font.weight: Font.Bold
            visible: notifCapsule.cantidad > 0
        }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: notifCapsule.toggleMenu()
    }
}
