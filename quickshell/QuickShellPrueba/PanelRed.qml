import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: redWindow

    anchors { top: true; left: true }
    implicitWidth: 250
    implicitHeight: 280
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    mask: Region { item: panelDeslizante }

    property bool abierto: false
    property int rxKbps: 0
    property int txKbps: 0
    property int maxSpeedVisual: 10000

    Timer {
        interval: 1000; running: redWindow.abierto; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 16) {
                    redWindow.rxKbps = parseInt(info[14]);
                    redWindow.txKbps = parseInt(info[15]);
                    canvasRx.requestPaint();
                    canvasTx.requestPaint();
                }
            }
        }
    }

    function formatSpeed(kbps) {
        if (kbps >= 1024) return (kbps / 1024).toFixed(2) + " MB/s";
        return kbps + " KB/s";
    }

    // ✅ Lógica de color reactiva al wallpaper con alerta de error
    function getStatusColor(kbps) {
        if (kbps < 50) return "#F38BA8"; // Rojo (Alerta de caída)
        return root.tema.primario;      // Color dominante del wallpaper
    }

    Rectangle {
        id: panelDeslizante
        width: parent.width
        height: parent.height

        x: redWindow.abierto ? 0 : -width + 4
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

        // ✅ Estilo Frost
        color: root.tema.flotanteFondo
        opacity: 0.95
        border.color: redWindow.abierto ? root.tema.primario : root.tema.flotanteBorde
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 200 } }

        focus: redWindow.abierto
        Keys.onEscapePressed: redWindow.abierto = false

        onActiveFocusChanged: {
            if (!activeFocus && redWindow.abierto) {
                redWindow.abierto = false;
            }
        }

        MouseArea {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 15
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                redWindow.abierto = !redWindow.abierto;
                if (redWindow.abierto) panelDeslizante.forceActiveFocus();
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            anchors.rightMargin: 15
            spacing: 15

            Text {
                text: "Monitor de Red"
                color: root.tema.textoPrimario
                font.pixelSize: 16; font.weight: Font.Bold
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(root.tema.textoPrimario, 0.1) }

            // =====================================
            // VELOCÍMETRO DE DESCARGA (RX)
            // =====================================
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Canvas {
                    id: canvasRx
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var centerX = width / 2;
                        var centerY = height - 5;
                        var radius = 60;

                        // 1. Carril de fondo (Variante suave)
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, Math.PI, 2 * Math.PI);
                        ctx.lineWidth = 10;
                        ctx.strokeStyle = Qt.alpha(root.tema.textoPrimario, 0.1);
                        ctx.stroke();

                        // 2. Barra de velocidad (Color dinámico)
                        var ratio = Math.min(redWindow.rxKbps / redWindow.maxSpeedVisual, 1.0);
                        var endAngle = Math.PI + (ratio * Math.PI);

                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, Math.PI, endAngle);
                        ctx.lineWidth = 10;
                        ctx.lineCap = "round"; // Bordes redondeados para el arco
                        ctx.strokeStyle = redWindow.getStatusColor(redWindow.rxKbps);
                        ctx.stroke();
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 15
                    spacing: 2
                    Text { text: "󰇚 Descarga"; color: Qt.alpha(root.tema.textoPrimario, 0.6); font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
                    Text {
                        text: redWindow.formatSpeed(redWindow.rxKbps)
                        color: redWindow.getStatusColor(redWindow.rxKbps)
                        font.pixelSize: 15; font.weight: Font.Bold
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // =====================================
            // VELOCÍMETRO DE SUBIDA (TX)
            // =====================================
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Canvas {
                    id: canvasTx
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var centerX = width / 2;
                        var centerY = height - 5;
                        var radius = 60;

                        // Carril de fondo
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, Math.PI, 2 * Math.PI);
                        ctx.lineWidth = 10;
                        ctx.strokeStyle = Qt.alpha(root.tema.textoPrimario, 0.1);
                        ctx.stroke();

                        // Barra de velocidad
                        var ratio = Math.min(redWindow.txKbps / redWindow.maxSpeedVisual, 1.0);
                        var endAngle = Math.PI + (ratio * Math.PI);

                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, Math.PI, endAngle);
                        ctx.lineWidth = 10;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = redWindow.getStatusColor(redWindow.txKbps);
                        ctx.stroke();
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 15
                    spacing: 2
                    Text { text: "󰕒 Subida"; color: Qt.alpha(root.tema.textoPrimario, 0.6); font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
                    Text {
                        text: redWindow.formatSpeed(redWindow.txKbps)
                        color: redWindow.getStatusColor(redWindow.txKbps)
                        font.pixelSize: 15; font.weight: Font.Bold
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
