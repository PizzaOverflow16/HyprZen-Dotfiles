import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: audioCajon
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    width: 350
    height: Math.min(layoutPrincipal.implicitHeight + 40, 600)
    radius: 15

    // ✅ Colores dinámicos para el panel
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "audio" ? 1 : 0
    y: menuActivo === "audio" ? 10 : -20
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }
    Process { id: shCmd }

    property int volPct: 50
    property string currentDevName: "Sistema"

    property int micPct: 50
    property string currentMicName: "Micrófono"

    ListModel { id: sinksModel }
    ListModel { id: sourcesModel }

    Timer {
        interval: 1000; running: audioCajon.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            // 1. Leer Estados y Volúmenes
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 13) {
                    if (!volMouseArea.pressed) audioCajon.volPct = parseInt(info[6]);
                    audioCajon.currentDevName = info[9];

                    if (!micMouseArea.pressed) audioCajon.micPct = parseInt(info[11]);
                    audioCajon.currentMicName = info[12];
                }
            }

            // 2. Leer Salidas (Sinks)
            let xhrSinks = new XMLHttpRequest();
            xhrSinks.open("GET", "file:///tmp/qs_audio_sinks.txt?nocache=" + new Date().getTime(), false);
            xhrSinks.send(null);
            if (xhrSinks.status === 200) {
                let lineas = xhrSinks.responseText.trim().split("\n");
                sinksModel.clear();
                for (let i = 0; i < lineas.length; i++) {
                    let linea_actual = lineas[i].trim();
                    if (linea_actual === "") continue;
                    let partes = linea_actual.split("|");
                    if (partes.length >= 4) {
                        sinksModel.append({
                            "devId": partes[0],
                            "devName": partes[1] !== "" ? partes[1] : "Desconocido",
                            "devIcon": partes[2] !== "" ? partes[2] : "󰖁",
                            "devActive": (partes[3] === "1")
                        });
                    }
                }
            }

            // 3. Leer Entradas (Sources / Micrófonos)
            let xhrSources = new XMLHttpRequest();
            xhrSources.open("GET", "file:///tmp/qs_audio_sources.txt?nocache=" + new Date().getTime(), false);
            xhrSources.send(null);
            if (xhrSources.status === 200) {
                let lineas = xhrSources.responseText.trim().split("\n");
                sourcesModel.clear();
                for (let i = 0; i < lineas.length; i++) {
                    let linea_actual = lineas[i].trim();
                    if (linea_actual === "") continue;
                    let partes = linea_actual.split("|");
                    if (partes.length >= 4) {
                        sourcesModel.append({
                            "devId": partes[0],
                            "devName": partes[1] !== "" ? partes[1] : "Desconocido",
                            "devIcon": partes[2] !== "" ? partes[2] : "󰍬",
                            "devActive": (partes[3] === "1")
                        });
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: layoutPrincipal
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 15

        // ==========================================
        // SECCIÓN ALTAVOZ (Color Primario)
        // ==========================================
        Text {
            text: audioCajon.currentDevName
            color: root.tema.textoPrimario
            font.pixelSize: 16; font.weight: Font.Bold
            Layout.fillWidth: true; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter
        }

        // SLIDER DE VOLUMEN PRINCIPAL
        RowLayout {
            Layout.fillWidth: true; spacing: 15
            Text { text: "󰕾"; color: root.tema.primario; font.pixelSize: 22 }
            Item {
                Layout.fillWidth: true; height: 30
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 12; radius: 6;
                    color: root.tema.fondoVariante // Fondo del slider
                    Rectangle {
                        width: parent.width * (audioCajon.volPct / 100); height: parent.height; radius: 6;
                        color: root.tema.primario // Relleno del slider
                        Behavior on width { NumberAnimation { duration: 100 } }
                    }
                }
                MouseArea {
                    id: volMouseArea
                    anchors.fill: parent
                    onPositionChanged: (mouse) => {
                        if (mouse.buttons & Qt.LeftButton) {
                            let val = Math.max(0, Math.min(100, (mouse.x / width) * 100));
                            audioCajon.volPct = val;
                            shCmd.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (val/100).toFixed(2)];
                            shCmd.running = true;
                        }
                    }
                    onClicked: (mouse) => {
                        let val = Math.max(0, Math.min(100, (mouse.x / width) * 100));
                        audioCajon.volPct = val;
                        shCmd.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (val/100).toFixed(2)];
                        shCmd.running = true;
                    }
                }
            }
            Text { text: audioCajon.volPct + "%"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 13; Layout.preferredWidth: 35; horizontalAlignment: Text.AlignRight }
        }

        // LISTA DE SALIDAS
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 150)
            clip: true
            spacing: 8
            model: sinksModel
            delegate: Rectangle {
                width: ListView.view.width; height: 45; radius: 10
                // Fondo activo = variante oscura, Hover = hover dinámico
                color: devActive ? root.tema.fondoVariante : (hoverDevice.containsMouse ? root.tema.capsulaHover : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
                RowLayout {
                    anchors.fill: parent; anchors.margins: 10; spacing: 12
                    Text { text: devIcon; color: devActive ? root.tema.primario : root.tema.textoPrimario; font.pixelSize: 18 }
                    Text { text: devName; color: devActive ? root.tema.primario : root.tema.textoPrimario; font.pixelSize: 14; font.weight: devActive ? Font.Bold : Font.Normal; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { visible: devActive; text: "󰄬"; color: root.tema.primario; font.pixelSize: 16 }
                }
                MouseArea {
                    id: hoverDevice
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { if (!devActive) { shCmd.command = ["wpctl", "set-default", devId]; shCmd.running = true; } }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 2; color: root.tema.fondoVariante; radius: 1 }

        // ==========================================
        // SECCIÓN MICRÓFONO (Color Secundario)
        // ==========================================
        Text {
            text: audioCajon.currentMicName
            color: root.tema.textoPrimario
            font.pixelSize: 16; font.weight: Font.Bold
            Layout.fillWidth: true; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter
        }

        // SLIDER DE MICRÓFONO
        RowLayout {
            Layout.fillWidth: true; spacing: 15
            Text { text: "󰍬"; color: root.tema.secundario; font.pixelSize: 22 }
            Item {
                Layout.fillWidth: true; height: 30
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 12; radius: 6;
                    color: root.tema.fondoVariante
                    Rectangle {
                        width: parent.width * (audioCajon.micPct / 100); height: parent.height; radius: 6;
                        color: root.tema.secundario // Relleno con color secundario
                        Behavior on width { NumberAnimation { duration: 100 } }
                    }
                }
                MouseArea {
                    id: micMouseArea
                    anchors.fill: parent
                    onPositionChanged: (mouse) => {
                        if (mouse.buttons & Qt.LeftButton) {
                            let val = Math.max(0, Math.min(100, (mouse.x / width) * 100));
                            audioCajon.micPct = val;
                            shCmd.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", (val/100).toFixed(2)];
                            shCmd.running = true;
                        }
                    }
                    onClicked: (mouse) => {
                        let val = Math.max(0, Math.min(100, (mouse.x / width) * 100));
                        audioCajon.micPct = val;
                        shCmd.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", (val/100).toFixed(2)];
                        shCmd.running = true;
                    }
                }
            }
            Text { text: audioCajon.micPct + "%"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 13; Layout.preferredWidth: 35; horizontalAlignment: Text.AlignRight }
        }

        // LISTA DE MICRÓFONOS
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 150)
            clip: true
            spacing: 8
            model: sourcesModel
            delegate: Rectangle {
                width: ListView.view.width; height: 45; radius: 10
                color: devActive ? root.tema.fondoVariante : (hoverMic.containsMouse ? root.tema.capsulaHover : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
                RowLayout {
                    anchors.fill: parent; anchors.margins: 10; spacing: 12
                    Text { text: devIcon; color: devActive ? root.tema.secundario : root.tema.textoPrimario; font.pixelSize: 18 }
                    Text { text: devName; color: devActive ? root.tema.secundario : root.tema.textoPrimario; font.pixelSize: 14; font.weight: devActive ? Font.Bold : Font.Normal; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { visible: devActive; text: "󰄬"; color: root.tema.secundario; font.pixelSize: 16 }
                }
                MouseArea {
                    id: hoverMic
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { if (!devActive) { shCmd.command = ["wpctl", "set-default", devId]; shCmd.running = true; } }
                }
            }
        }
    }
}
