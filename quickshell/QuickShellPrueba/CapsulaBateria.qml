import QtQuick
import QtQuick.Layouts

Rectangle {
    id: batWidget
    signal toggleMenu()
    property bool menuAbierto: false

    implicitHeight: 30
    implicitWidth: layoutBat.implicitWidth + 30
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: controlMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    property string iconBat: "󰂎"
    property int pctBat: 0

    // ✅ LÓGICA DE COLORES HÍBRIDA (Idéntica a la de tu cajón flotante)
    property color colorBat: {
        if (iconBat === "󰂄") return "#A6E3A1"; // Cargando (Verde clásico)
        if (pctBat >= 50) return root.tema.primario;   // Batería alta: Color principal del wallpaper
        if (pctBat >= 25) return root.tema.secundario; // Batería media: Color secundario
        return "#F38BA8";                              // Batería baja: Rojo de alerta constante
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 8) {
                    batWidget.iconBat = info[2];
                    batWidget.pctBat = parseInt(info[3]);
                }
            }
        }
    }

    RowLayout {
        id: layoutBat
        anchors.centerIn: parent
        spacing: 6
        Text {
            text: batWidget.iconBat;
            color: batWidget.colorBat;
            font.pixelSize: 18;
            Behavior on color { ColorAnimation { duration: 300 } }
        }
        Text {
            text: batWidget.pctBat + "%";
            color: root.tema.textoPrimario; // ✅ Texto adaptativo
            font.pixelSize: 13;
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: batWidget.toggleMenu()
    }
}
