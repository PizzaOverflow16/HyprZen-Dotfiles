import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: redesCajon

    property string menuActivo: ""
    property bool algunaRedExpandida: false
    signal abrirMenu(string nombreMenu)

    width: 350; height: 450
    radius: 15

    // ✅ Fondo cristalino y borde reactivo de Matugen
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "redes" ? 1 : 0
    y: menuActivo === "redes" ? 10 : -20

    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }

    Process { id: shCmd }

    ListModel { id: wifiModel }

    Timer {
        interval: 3000;
        running: redesCajon.visible && !redesCajon.algunaRedExpandida;
        repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_wifi.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let lineas = xhr.responseText.trim().split("\n");
                wifiModel.clear();

                for (let i = 0; i < lineas.length; i++) {
                    if (lineas[i] === "") continue;
                    let partes = lineas[i].split(":");

                    let guardada = (partes.pop() === "1");
                    let ssid = partes.slice(3).join(":");
                    let enUso = (partes[0] === "*");
                    let senal = parseInt(partes[1]);
                    let seguridad = partes[2];

                    wifiModel.append({
                        "netSsid": ssid,
                        "netEnUso": enUso,
                        "netSenal": senal,
                        "netSegura": (seguridad !== "" && seguridad !== "--"),
                                     "netGuardada": guardada
                    });
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: ""
                // ✅ Botón de regreso con color secundario al hover
                color: hoverRegresar.containsMouse ? root.tema.primario : root.tema.textoPrimario
                font.pixelSize: 18
                font.weight: Font.Bold
                Behavior on color { ColorAnimation { duration: 150 } }
                MouseArea {
                    id: hoverRegresar
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: redesCajon.abrirMenu("control")
                }
            }

            Text {
                text: "Redes Wi-Fi"
                color: root.tema.textoPrimario
                font.pixelSize: 18
                font.weight: Font.Bold
                Layout.fillWidth: true
            }
        }

        // ✅ Separador suave
        Rectangle { Layout.fillWidth: true; height: 2; color: Qt.alpha(root.tema.textoPrimario, 0.1); radius: 1 }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: wifiModel

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: isExpanded ? 90 : 50
                radius: 10

                // ✅ Fondo: Variante oscura si está en uso, transparente de lo contrario
                color: netEnUso ? root.tema.fondoVariante : (hoverRed.containsMouse ? root.tema.capsulaHover : "transparent")

                Behavior on height { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }

                property bool isExpanded: false

                onIsExpandedChanged: { redesCajon.algunaRedExpandida = isExpanded; }

                ColumnLayout {
                    z: 2
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: netSenal > 70 ? "󰤨" : (netSenal > 40 ? "󰤥" : "󰤢")
                            // ✅ Ícono de señal con el color principal del sistema
                            color: netEnUso ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.6)
                            font.pixelSize: 18
                        }

                        Text {
                            text: netSsid
                            color: netEnUso ? root.tema.primario : root.tema.textoPrimario
                            font.pixelSize: 14
                            font.weight: netEnUso ? Font.Bold : Font.Normal
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // BOTÓN QR TERMINAL
                        Text {
                            visible: netGuardada || netEnUso
                            text: ""
                            // ✅ El QR brilla con el color secundario al hover
                            color: hoverQR.containsMouse ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.5)
                            font.pixelSize: 18
                            z: 10

                            MouseArea {
                                id: hoverQR
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    shCmd.command = ["kitty", "--class", "wifi-qr", "-e", "bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/show_qr_terminal.sh", netSsid];
                                    shCmd.running = true;
                                    redesCajon.abrirMenu("");
                                }
                            }
                        }

                        Text {
                            visible: netGuardada && !netEnUso
                            text: "󰆓"
                            color: root.tema.secundario
                            font.pixelSize: 14
                        }

                        Text {
                            visible: netSegura
                            text: "󰌾"
                            color: Qt.alpha(root.tema.textoPrimario, 0.4)
                            font.pixelSize: 14
                        }
                    }

                    // ÁREA DE CONTRASEÑA (Cuando expandes una red)
                    RowLayout {
                        visible: isExpanded && !netEnUso
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true; height: 30; radius: 5
                            color: root.tema.fondoVariante
                            border.color: Qt.alpha(root.tema.textoPrimario, 0.2); border.width: 1
                            TextInput {
                                id: inputPass
                                anchors.fill: parent; anchors.margins: 5
                                color: root.tema.textoPrimario; font.pixelSize: 13
                                verticalAlignment: TextInput.AlignVCenter
                                passwordCharacter: "•"; echoMode: TextInput.Password
                                clip: true
                                Text {
                                    text: "Contraseña..."; color: Qt.alpha(root.tema.textoPrimario, 0.4); font.pixelSize: 13;
                                    visible: !inputPass.text; anchors.verticalCenter: parent.verticalCenter
                                }
                                onAccepted: {
                                    shCmd.command = ["bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/conectar_wifi.sh", netSsid, inputPass.text];
                                    shCmd.running = true;
                                    isExpanded = false;
                                }
                            }
                        }

                        Rectangle {
                            width: 80; height: 30; radius: 5
                            // ✅ Botón conectar con color primario
                            color: root.tema.primario
                            Text { anchors.centerIn: parent; text: "Conectar"; color: root.tema.fondoSuperficie; font.pixelSize: 12; font.weight: Font.Bold }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    shCmd.command = ["bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/conectar_wifi.sh", netSsid, inputPass.text];
                                    shCmd.running = true;
                                    isExpanded = false;
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: hoverRed
                    z: 1
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 50

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (netEnUso) return;

                        if (netGuardada || !netSegura) {
                            shCmd.command = ["bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/conectar_wifi.sh", netSsid];
                            shCmd.running = true;
                        } else {
                            if (!redesCajon.algunaRedExpandida || isExpanded) {
                                isExpanded = !isExpanded;
                                if (isExpanded) {
                                    inputPass.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
