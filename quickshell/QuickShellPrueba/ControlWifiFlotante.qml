import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: controlCajon
    property string menuActivo: ""

    signal abrirMenu(string nombreMenu)

    width: 380; height: 110
    radius: 15
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde; border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "control" ? 1 : 0
    y: menuActivo === "control" ? 10 : -20

    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }

    property bool wifiOn: false
    property bool btOn: false

    Timer {
        interval: 500; running: controlCajon.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let info = xhr.responseText.trim().split("|");
                if (info.length >= 6) {
                    controlCajon.wifiOn = (info[4] === "1");
                    controlCajon.btOn = (info[5] === "1");
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 25

        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            // ==========================================
            // BOTÓN WI-FI DIVIDIDO
            // ==========================================
            Rectangle {
                Layout.fillWidth: true; height: 60; radius: 15
                // Fondo global: Primario si está ON, Variante si está OFF
                color: controlCajon.wifiOn ? root.tema.primario : root.tema.fondoVariante
                Behavior on color { ColorAnimation { duration: 200 } }
                clip: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 1. ZONA IZQUIERDA: PRENDER / APAGAR
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        color: hoverWifiTog.containsMouse ? Qt.alpha("#000000", 0.1) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.centerIn: parent; spacing: 12
                            Text { text: controlCajon.wifiOn ? "󰖩" : "󰖪"; color: controlCajon.wifiOn ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 22 }
                            Text { text: "Wi-Fi"; color: controlCajon.wifiOn ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 16; font.weight: Font.Bold }
                        }

                        MouseArea {
                            id: hoverWifiTog
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // 🚀 FIX: Dispara y olvida usando nmcli. ¡Adiós a los congelamientos!
                                Quickshell.execDetached(["bash", "-c", "nmcli radio wifi | grep -q 'enabled' && nmcli radio wifi off || nmcli radio wifi on"]);
                            }
                        }
                    }

                    // 2. SEPARADOR
                    Rectangle {
                        width: 1; Layout.fillHeight: true
                        Layout.topMargin: 10; Layout.bottomMargin: 10
                        color: controlCajon.wifiOn ? Qt.alpha("#1E1E2E", 0.2) : Qt.alpha(root.tema.textoPrimario, 0.1)
                    }

                    // 3. ZONA DERECHA: ABRIR MENÚ DE REDES
                    Rectangle {
                        width: 50; Layout.fillHeight: true
                        color: hoverWifiArr.containsMouse ? Qt.alpha("#000000", 0.1) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅂"
                            color: controlCajon.wifiOn ? "#1E1E2E" : root.tema.textoPrimario
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: hoverWifiArr
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: controlCajon.abrirMenu("redes")
                        }
                    }
                }
            }

            // ==========================================
            // BOTÓN BLUETOOTH DIVIDIDO
            // ==========================================
            Rectangle {
                Layout.fillWidth: true; height: 60; radius: 15
                color: controlCajon.btOn ? root.tema.primario : root.tema.fondoVariante
                Behavior on color { ColorAnimation { duration: 200 } }
                clip: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 1. ZONA IZQUIERDA: PRENDER / APAGAR
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        color: hoverBtTog.containsMouse ? Qt.alpha("#000000", 0.1) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.centerIn: parent; spacing: 12
                            Text { text: controlCajon.btOn ? "󰂯" : "󰂲"; color: controlCajon.btOn ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 22 }
                            Text { text: "Bluetooth"; color: controlCajon.btOn ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 16; font.weight: Font.Bold }
                        }

                        MouseArea {
                            id: hoverBtTog
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // 🚀 FIX: Usa bluetoothctl nativo
                                Quickshell.execDetached(["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]);
                            }
                        }
                    }

                    // 2. SEPARADOR
                    Rectangle {
                        width: 1; Layout.fillHeight: true
                        Layout.topMargin: 10; Layout.bottomMargin: 10
                        color: controlCajon.btOn ? Qt.alpha("#1E1E2E", 0.2) : Qt.alpha(root.tema.textoPrimario, 0.1)
                    }

                    // 3. ZONA DERECHA: ABRIR MENÚ DE BLUETOOTH
                    Rectangle {
                        width: 50; Layout.fillHeight: true
                        color: hoverBtArr.containsMouse ? Qt.alpha("#000000", 0.1) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅂"
                            color: controlCajon.btOn ? "#1E1E2E" : root.tema.textoPrimario
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: hoverBtArr
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: controlCajon.abrirMenu("bluetooth")
                        }
                    }
                }
            }
        }
    }
}
