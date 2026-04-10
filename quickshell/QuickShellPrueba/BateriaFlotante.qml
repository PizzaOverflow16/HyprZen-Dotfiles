import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: batCajon
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    width: 360; implicitHeight: 380 // Arreglado el WARNING
    radius: 20

    // ✅ Colores dinámicos del panel principal
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2
    clip: true

    visible: opacity > 0
    opacity: menuActivo === "bateria" ? 1 : 0
    y: menuActivo === "bateria" ? 10 : -20
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent } // Cristal anti-clics

    Process { id: shCmd }

    // Variables de Estado
    property int batPct: 0
    property string batStatus: "Desconocido"
    property int brightPct: 50
    property string powerProfile: "balanced"

    // ✅ Lógica de colores híbrida (Matugen + Alertas reales)
    property color currentColor: {
        // Cargando = Verde clásico para indicar que todo está bien
        if (batStatus === "Charging") return "#A6E3A1";

        // Batería saludable = Usa el color dominante del Wallpaper
        if (batPct >= 50) return root.tema.primario;

        // Batería media = Usa el color secundario
        if (batPct >= 25) return root.tema.secundario;

        // Batería crítica = Rojo para salvar tu trabajo!
        return "#F38BA8";
    }

    Timer {
        interval: 1000; running: batCajon.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 8) {
                    batCajon.batPct = parseInt(info[3]);
                    batCajon.batStatus = info[2] === "󰂄" ? "Charging" : "Discharging";
                    if (!briMouseArea.pressed) batCajon.brightPct = parseInt(info[7]);
                }
            }
            profilePoller.running = true;
        }
    }

    Process {
        id: profilePoller
        command: ["powerprofilesctl", "get"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let res = this.text.trim();
                if (res === "performance" || res === "balanced" || res === "power-saver") {
                    batCajon.powerProfile = res;
                }
            }
        }
    }

    // ✅ Decoración de fondo adaptada al Tema
    Rectangle { width: 300; height: 300; radius: 150; x: -100; y: 50; color: root.tema.primario; opacity: 0.05 }
    Rectangle { width: 400; height: 400; radius: 200; x: 100; y: -100; color: root.tema.secundario; opacity: 0.05 }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // ==========================================
        // 1. EL ARO CENTRAL LUMINOSO
        // ==========================================
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 180

            Rectangle {
                anchors.centerIn: parent
                width: 170; height: 170
                radius: 85
                color: "transparent"
                border.color: root.tema.fondoVariante // ✅ Carril de batería dinámico
                border.width: 10

                // El "Glow" exterior
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 30; height: width; radius: width / 2
                    color: "transparent"
                    border.color: batCajon.currentColor
                    border.width: 2
                    opacity: 0.2
                }

                Item {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * (batCajon.batPct / 100)
                    clip: true
                    Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.OutQuint } }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: 170; height: 170
                        radius: 85
                        color: "transparent"
                        border.color: batCajon.currentColor
                        border.width: 10
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        Text { text: batCajon.batStatus === "Charging" ? "󰂄" : "󰁹"; color: batCajon.currentColor; font.pixelSize: 24 }
                        Text { text: batCajon.batPct + "%"; color: root.tema.textoPrimario; font.pixelSize: 42; font.weight: Font.Black; font.family: "JetBrains Mono" }
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: batCajon.batStatus === "Charging" ? "CARGANDO" : "DESCONECTADO"
                        color: Qt.alpha(root.tema.textoPrimario, 0.6)
                        font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 2
                    }
                }
            }
        }

        // ==========================================
        // 2. SLIDER DE BRILLO
        // ==========================================
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 60
            radius: 15;
            color: root.tema.fondoVariante; // ✅ Fondo dinámico

            RowLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 15
                Text { text: batCajon.brightPct > 50 ? "󰃠" : "󰃟"; color: root.tema.primario; font.pixelSize: 20 }
                Item {
                    Layout.fillWidth: true; height: 30
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 14; radius: 7;
                        color: Qt.alpha(root.tema.textoPrimario, 0.1) // Carril del brillo
                        Rectangle {
                            width: parent.width * (batCajon.brightPct / 100); height: parent.height; radius: 7;
                            color: root.tema.primario // ✅ Relleno con el color de acento
                            Behavior on width { NumberAnimation { duration: 100 } }
                        }
                    }
                    MouseArea {
                        id: briMouseArea
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onPositionChanged: (mouse) => {
                            if (mouse.buttons & Qt.LeftButton) {
                                let val = Math.max(1, Math.min(100, (mouse.x / width) * 100));
                                batCajon.brightPct = val;
                                Quickshell.execDetached(["brightnessctl", "s", val + "%"]);
                            }
                        }
                        onClicked: (mouse) => {
                            let val = Math.max(1, Math.min(100, (mouse.x / width) * 100));
                            batCajon.brightPct = val;
                            Quickshell.execDetached(["brightnessctl", "s", val + "%"]);
                        }
                    }
                }
            }
        }

        // ==========================================
        // 3. PERFILES DE ENERGÍA
        // ==========================================
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 50
            radius: 25;
            color: root.tema.fondoVariante

            RowLayout {
                anchors.fill: parent; anchors.margins: 5; spacing: 5

                // ✅ Los colores de los perfiles ahora cambian con el Wallpaper
                Repeater {
                    model: ListModel {
                        ListElement { code: "performance"; label: "Rendimiento"; icon: "󰓅"; activeRole: "rojo" }
                        ListElement { code: "balanced"; label: "Balanceado"; icon: "󰗑"; activeRole: "primario" }
                        ListElement { code: "power-saver"; label: "Ahorro"; icon: "󰌪"; activeRole: "secundario" }
                    }
                    delegate: Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true; radius: 20
                        property bool isActive: batCajon.powerProfile === code

                        // Lógica para asignar el color correcto de Matugen a cada botón
                        property color btnColor: {
                            if (activeRole === "primario") return root.tema.primario;
                            if (activeRole === "secundario") return root.tema.secundario;
                            return "#F38BA8"; // El rojo de rendimiento se mantiene rojo como alerta
                        }

                        color: isActive ? btnColor : (profMa.containsMouse ? root.tema.capsulaHover : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }

                        RowLayout {
                            anchors.centerIn: parent; spacing: 5
                            Text { text: icon; color: isActive ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 16 }
                            Text { text: label; color: isActive ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 12; font.weight: Font.Bold }
                        }
                        MouseArea {
                            id: profMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { Quickshell.execDetached(["powerprofilesctl", "set", code]); batCajon.powerProfile = code; }
                        }
                    }
                }
            }
        }
    }
}
