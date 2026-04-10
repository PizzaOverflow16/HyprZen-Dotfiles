import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: minWidget
    signal toggleMenu()
    property bool menuAbierto: false

    property int numMinimizadas: 0
    property string unicaDireccion: ""

    // ¡Magia!: Solo se muestra si hay ventanas escondidas
    visible: numMinimizadas > 0

    implicitHeight: 30
    implicitWidth: layoutMin.implicitWidth + 24
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: controlMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    Process { id: shCmd }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            // Leer cantidad
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 14) {
                    minWidget.numMinimizadas = parseInt(info[13]);
                }
            }

            // Si solo hay una, preparar su ID para restaurarla directo
            if (minWidget.numMinimizadas === 1) {
                let xhrMin = new XMLHttpRequest();
                xhrMin.open("GET", "file:///tmp/qs_minimized.txt?nocache=" + new Date().getTime(), false);
                xhrMin.send(null);
                if (xhrMin.status === 200) {
                    let lineas = xhrMin.responseText.trim().split("\n");
                    if (lineas.length > 0 && lineas[0] !== "") {
                        minWidget.unicaDireccion = lineas[0].split("|")[0];
                    }
                }
            }
        }
    }

    RowLayout {
        id: layoutMin
        anchors.centerIn: parent
        spacing: 8
        Text {
            text: "󰖯"
            // ✅ Ícono con el color principal
            color: root.tema.primario
            font.pixelSize: 16
            Behavior on color { ColorAnimation { duration: 300 } }
        }
        Text {
            text: minWidget.numMinimizadas
            // ✅ Texto dinámico para siempre ser legible
            color: root.tema.textoPrimario
            font.pixelSize: 13
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (minWidget.numMinimizadas === 1 && minWidget.unicaDireccion !== "") {
                // FIX: Apagar y prender para evitar que se quede trabado
                shCmd.running = false;
                shCmd.command = ["hyprctl", "dispatch", "movetoworkspace", "e+0,address:" + minWidget.unicaDireccion];
                shCmd.running = true;
            } else if (minWidget.numMinimizadas > 1) {
                // Hay varias: Abrir el menú para elegir
                minWidget.toggleMenu()
            }
        }
    }
}
