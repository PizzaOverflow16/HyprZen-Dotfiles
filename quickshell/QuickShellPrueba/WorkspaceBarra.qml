import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: wsWidget

    // ✅ Estética unificada con el resto de la barra
    implicitWidth: rowLayout.implicitWidth + 20
    implicitHeight: 30
    radius: 15
    color: "transparent" // Dejamos que la barra principal o el fondo luzcan

    // ✅ Borde sutil reactivo
    border.color: Qt.alpha(root.tema.primario, 0.3)
    border.width: 1

    property int escritorioActivo: 1
    property var listaWorkspaces: [1]

    Timer {
        interval: 100
        running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_workspaces.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200 || xhr.status === 0) {
                let info = xhr.responseText.trim().split("|");
                if (info.length === 2) {
                    wsWidget.escritorioActivo = parseInt(info[0]) || 1;
                    wsWidget.listaWorkspaces = info[1].split(",").map(Number);
                }
            }
        }
    }

    function numeroJapones(num) {
        let kanjiMap = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
        return kanjiMap[num] !== undefined ? kanjiMap[num] : num.toString();
    }

    Process { id: hyprlandCmd }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: wsWidget.listaWorkspaces

            Rectangle {
                property int wsID: modelData
                property bool esActivo: wsID === wsWidget.escritorioActivo

                height: 14
                implicitWidth: esActivo ? 35 : 14
                radius: 7

                // ✅ Color: Primario si es el activo, fondo variante si no
                color: esActivo ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.2)

                Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.centerIn: parent
                    text: wsWidget.numeroJapones(wsID)
                    // ✅ Contraste: Texto oscuro sobre fondo claro (primario)
                    color: root.tema.barraFondo
                    font.pixelSize: 10; font.weight: Font.Bold
                    visible: esActivo
                    opacity: esActivo ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        hyprlandCmd.command = ["hyprctl", "dispatch", "workspace", wsID.toString()];
                        hyprlandCmd.running = true;
                    }
                }
            }
        }
    }
}
