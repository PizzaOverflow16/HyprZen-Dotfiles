import QtQuick
import QtQuick.Layouts

Rectangle {
    id: wifiBtWidget

    signal toggleMenu()
    property bool menuAbierto: false

    // ✅ Ajuste dinámico y estética unificada
    implicitHeight: 30
    implicitWidth: rowLayout.implicitWidth + 30
    radius: 15

    // ✅ Fondo transparente con hover dinámico
    color: controlMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante
    border.color: Qt.alpha(root.tema.primario, 0.4)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    property string iconWifi: "󰖪"
    property string iconBt: ""

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200 || xhr.status === 0) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 1) {
                    wifiBtWidget.iconWifi = info[0];
                }
            }
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 12

        // ✅ Wi-Fi con color primario/texto según estado
        Text {
            text: wifiBtWidget.iconWifi
            color: root.tema.textoPrimario
            font.pixelSize: 16
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        // ✅ Bluetooth con color secundario para destacar
        Text {
            text: wifiBtWidget.iconBt
            color: root.tema.secundario
            font.pixelSize: 16
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: wifiBtWidget.toggleMenu()
    }
}
