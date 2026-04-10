import QtQuick
import QtQuick.Layouts

Rectangle {
    id: cpuWidget

    // Propiedades para comunicarse con la barra principal
    property bool menuAbierto: false
    signal toggleMenu()

    // ✅ Ajustamos el ancho dinámicamente y aplicamos estética de cristal
    implicitWidth: layoutContenedor.implicitWidth + 24
    implicitHeight: 30
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico
    color: mouseArea.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde sutil con el color secundario del wallpaper
    border.color: Qt.alpha(root.tema.secundario, 0.5)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    property real cpuPorcentaje: 0

    function leerCPU() {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/qs_sys.txt?nocache=" + new Date().getTime(), false);
        xhr.send(null);
        if (xhr.status === 200 || xhr.status === 0) {
            let info = xhr.responseText.trim().split("|");
            if (info.length >= 1) {
                cpuWidget.cpuPorcentaje = parseFloat(info[0]) || 0;
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: cpuWidget.leerCPU()
    }

    RowLayout {
        id: layoutContenedor
        anchors.centerIn: parent
        spacing: 6

        // ✅ Icono con el color secundario de Matugen
        Text {
            text: ""
            color: root.tema.secundario
            font.pixelSize: 14
        }

        // ✅ Texto con el color primario adaptativo
        Text {
            text: Math.round(cpuWidget.cpuPorcentaje) + "%"
            color: root.tema.textoPrimario
            font.pixelSize: 13
            font.weight: Font.Bold
            font.family: "FiraCode Nerd Font"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: cpuWidget.toggleMenu()
    }
}
