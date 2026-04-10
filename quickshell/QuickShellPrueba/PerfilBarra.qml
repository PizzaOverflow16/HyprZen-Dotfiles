import QtQuick
import QtQuick.Layouts

Rectangle {
    id: perfilWidget

    property bool menuAbierto: false
    signal toggleMenu()

    // ✅ Caja adaptativa: usa el color de hover del tema cuando está activo
    width: 30; height: 30; radius: 15
    color: menuAbierto ? root.tema.capsulaHover : "transparent"

    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        anchors.centerIn: parent
        text: "" // Ícono de EndeavourOS
        // ✅ Ahora el logo de tu distro se tiñe con el color dominante del wallpaper
        color: root.tema.primario
        font.pixelSize: 22

        Behavior on color { ColorAnimation { duration: 300 } }
    }

    MouseArea {
        anchors.fill: parent; anchors.margins: -5
        cursorShape: Qt.PointingHandCursor
        onClicked: perfilWidget.toggleMenu()
    }
}
