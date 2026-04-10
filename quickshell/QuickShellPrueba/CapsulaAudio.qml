import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: audioWidget
    signal toggleMenu()
    property bool menuAbierto: false

    implicitHeight: 30
    implicitWidth: layoutAudio.implicitWidth + 30
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: controlMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    // Propiedades del altavoz
    property string iconVol: "󰕾"
    property string textVol: "0"

    // Propiedades del micrófono
    property string iconMic: "󰍬"
    property string textMic: "0"

    Process { id: shCmd }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 12) {
                    // Altavoz
                    audioWidget.iconVol = info[1];
                    audioWidget.textVol = info[6];
                    // Micrófono
                    audioWidget.iconMic = info[10];
                    audioWidget.textMic = info[11];
                }
            }
        }
    }

    RowLayout {
        id: layoutAudio
        anchors.centerIn: parent
        spacing: 10 // Espaciado mayor para separar mic de altavoz

        // ==========================================
        // Bloque del Micrófono (Color Secundario)
        // ==========================================
        RowLayout {
            spacing: 4
            Text {
                text: audioWidget.iconMic;
                // Rojo si está muteado, Color Secundario si está activo
                color: audioWidget.iconMic === "󰍭" ? "#F38BA8" : root.tema.secundario;
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text { text: audioWidget.textMic + "%"; color: root.tema.textoPrimario; font.pixelSize: 13; font.weight: Font.Bold }
        }

        // Separador visual translúcido
        Rectangle { width: 1; height: 12; color: Qt.alpha(root.tema.textoPrimario, 0.3) }

        // ==========================================
        // Bloque del Altavoz (Color Primario)
        // ==========================================
        RowLayout {
            spacing: 4
            Text {
                text: audioWidget.iconVol;
                // Rojo si está muteado, Color Primario si está activo
                color: audioWidget.iconVol === "󰖁" ? "#F38BA8" : root.tema.primario;
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text { text: audioWidget.textVol + "%"; color: root.tema.textoPrimario; font.pixelSize: 13; font.weight: Font.Bold }
        }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: audioWidget.toggleMenu()

        // El scroll del mouse sigue controlando el volumen principal
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                shCmd.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"];
            } else {
                shCmd.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"];
            }
            shCmd.running = true;
        }
    }
}
