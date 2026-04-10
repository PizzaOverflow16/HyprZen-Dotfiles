import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: btCajon

    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    width: 380; height: 480
    radius: 15

    // ✅ Fondo y Borde Dinámicos
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "bluetooth" ? 1 : 0
    y: menuActivo === "bluetooth" ? 10 : -20

    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }

    Process { id: shCmd }

    Process {
        id: scanCmd
        command: ["bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/control_bt.sh", "scan"]
        onRunningChanged: {
            if (running) {
                console.log("🔵 [QML] Iniciando script de escaneo BT...");
            } else {
                btCajon.isScanning = false;
                console.log("✅ [QML] Script de escaneo BT terminó. Revisa /tmp/bt_debug.log para ver qué hizo.");
            }
        }
    }

    ListModel { id: btModel }

    property bool isScanning: false

    Timer {
        interval: 3000;
        running: btCajon.visible;
        repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_bt.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let lineas = xhr.responseText.trim().split("\n");
                btModel.clear();

                for (let i = 0; i < lineas.length; i++) {
                    if (lineas[i] === "") continue;

                    let partes = lineas[i].split("|");
                    if (partes.length >= 3) {
                        let estado = partes[0].trim();
                        let mac = partes[1].trim();
                        let nombre = partes[2].trim();

                        btModel.append({
                            "btName": nombre,
                            "btMac": mac,
                            "btStatus": estado // "*", "P", "U"
                        });
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // --- CABECERA ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: ""
                // ✅ Efecto Hover que combina con tu Wallpaper
                color: hoverRegresar.containsMouse ? root.tema.primario : root.tema.textoPrimario
                font.pixelSize: 18
                font.weight: Font.Bold
                Behavior on color { ColorAnimation { duration: 150 } }
                MouseArea {
                    id: hoverRegresar
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: btCajon.abrirMenu("control")
                }
            }

            Text {
                text: "Bluetooth"
                color: root.tema.textoPrimario
                font.pixelSize: 18
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            // --- BOTÓN DE ESCANEAR ---
            Rectangle {
                width: 100; height: 30; radius: 8
                // ✅ Botón de escanear (Hover y Active dinámicos)
                color: isScanning ? root.tema.fondoVariante : (hoverScan.containsMouse ? root.tema.primario : root.tema.fondoVariante)
                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.centerIn: parent; spacing: 5
                    Text {
                        text: "󰑐"
                        color: isScanning || hoverScan.containsMouse ? "#1E1E2E" : root.tema.textoPrimario
                        font.pixelSize: 14
                        RotationAnimation on rotation {
                            from: 0; to: 360; duration: 1000
                            loops: Animation.Infinite
                            running: btCajon.isScanning
                        }
                    }
                    Text {
                        text: isScanning ? "Buscando..." : "Escanear"
                        color: isScanning || hoverScan.containsMouse ? "#1E1E2E" : root.tema.textoPrimario
                        font.pixelSize: 12; font.weight: Font.Bold
                    }
                }

                MouseArea {
                    id: hoverScan
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !btCajon.isScanning
                    onClicked: {
                        btCajon.isScanning = true;
                        scanCmd.running = true;
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 2; color: root.tema.fondoVariante; radius: 1 }

        // --- LISTA DE DISPOSITIVOS ---
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: btModel

            Text {
                anchors.centerIn: parent
                text: isScanning ? "Buscando dispositivos..." : "No hay dispositivos a la vista"
                color: Qt.alpha(root.tema.textoPrimario, 0.6)
                font.pixelSize: 14
                visible: parent.count === 0
            }

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 55
                radius: 10

                property bool conectado: btStatus === "*"
                property bool guardado: btStatus === "P"
                property bool nuevo: btStatus === "U"

                // ✅ Fondo del dispositivo conectado es más brillante que el resto
                color: conectado ? root.tema.fondoVariante : (hoverBt.containsMouse ? root.tema.capsulaHover : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Text {
                        text: conectado ? "󰂱" : (guardado ? "󰂯" : "󰂲")
                        // ✅ Íconos: Primario si está conectado, Secundario si solo está guardado
                        color: conectado ? root.tema.primario : (guardado ? root.tema.textoPrimario : Qt.alpha(root.tema.textoPrimario, 0.5))
                        font.pixelSize: 22
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: btName === "" ? "Desconocido (" + btMac.substring(0,8) + "...)" : btName
                            // ✅ Título
                            color: conectado ? root.tema.primario : (guardado ? root.tema.textoPrimario : Qt.alpha(root.tema.textoPrimario, 0.6))
                            font.pixelSize: 14
                            font.weight: conectado ? Font.Bold : Font.Normal
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: conectado ? "Conectado" : (guardado ? "Guardado" : "Dispositivo Nuevo")
                            color: conectado ? Qt.alpha(root.tema.textoPrimario, 0.8) : Qt.alpha(root.tema.textoPrimario, 0.5)
                            font.pixelSize: 10
                        }
                    }

                    // Botón Dinámico (Desconectar / Conectar / Vincular)
                    Rectangle {
                        width: 90; height: 32; radius: 8
                        // ✅ Lógica híbrida: Rojo fijo para desconectar, colores dinámicos para conectar
                        color: conectado ? "#F38BA8" : (guardado ? root.tema.primario : root.tema.secundario)

                        Text {
                            anchors.centerIn: parent
                            text: conectado ? "Desconectar" : (guardado ? "Conectar" : "Vincular")
                            color: "#1E1E2E" // Texto oscuro para que resalte sobre el fondo de color
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }
                }

                MouseArea {
                    id: hoverBt
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let accion = conectado ? "disconnect" : (guardado ? "connect" : "pair");
                        console.log("👉 Ejecutando BT: " + accion + " en " + btMac);
                        shCmd.running = false;
                        shCmd.command = ["bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/control_bt.sh", accion, btMac];
                        shCmd.running = true;
                    }
                }
            }
        }
    }
}
