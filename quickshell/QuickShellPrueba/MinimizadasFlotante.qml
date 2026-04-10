import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Rectangle {
    id: minCajon
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    width: 300
    height: Math.min(layoutPrincipal.implicitHeight + 40, 400)
    radius: 15

    // ✅ Fondo cristalino y borde reactivo de Matugen
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "minimizadas" ? 1 : 0
    y: menuActivo === "minimizadas" ? 10 : -20
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }
    Process { id: shCmd }

    ListModel { id: ventanasModel }

    Timer {
        interval: 1000; running: minCajon.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_minimized.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200) {
                let lineas = xhr.responseText.trim().split("\n");
                ventanasModel.clear();
                for (let i = 0; i < lineas.length; i++) {
                    let linea = lineas[i].trim();
                    if (linea === "") continue;
                    let partes = linea.split("|");
                    if (partes.length >= 3) {

                        // Asignador básico de iconos según la app
                        let claseApp = partes[1].toLowerCase();
                        let icono = "󰖯"; // Por defecto
                        if (claseApp.includes("firefox") || claseApp.includes("brave")) icono = "󰈹";
                        if (claseApp.includes("kitty") || claseApp.includes("alacritty")) icono = "󰄛";
                        if (claseApp.includes("code")) icono = "󰨞";
                        if (claseApp.includes("thunar") || claseApp.includes("dolphin")) icono = "󰉋";
                        if (claseApp.includes("spotify")) icono = "󰓇";

                        ventanasModel.append({
                            "winId": partes[0],
                            "winIcon": icono,
                            "winTitle": partes[2]
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

        Text {
            text: "Cápsula de Contención"
            color: root.tema.textoPrimario
            font.pixelSize: 16; font.weight: Font.Bold
            Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
        }

        // ✅ Separador usando una variante suave del tema
        Rectangle { Layout.fillWidth: true; height: 2; color: Qt.alpha(root.tema.textoPrimario, 0.2); radius: 1 }

        ListView {
            Layout.fillWidth: true

            // ¡LA MAGIA!: Obligamos a la lista a medir 53 píxeles por cada ventana detectada.
            // Así jamás volverá a colapsar a 0 altura.
            Layout.preferredHeight: ventanasModel.count * 53

            clip: true
            spacing: 8
            model: ventanasModel

            delegate: Rectangle {
                width: ListView.view.width; height: 45; radius: 10
                // ✅ Efecto de selección suave usando tu tema
                color: hoverWin.containsMouse ? root.tema.capsulaHover : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent; anchors.margins: 10; spacing: 12
                    // ✅ El ícono de la app brilla con tu color primario actual
                    Text { text: winIcon; color: root.tema.primario; font.pixelSize: 20 }
                    Text { text: winTitle; color: root.tema.textoPrimario; font.pixelSize: 13; Layout.fillWidth: true; elide: Text.ElideRight }
                }

                MouseArea {
                    id: hoverWin
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        shCmd.running = false;
                        shCmd.command = ["bash", "-c", "hyprctl dispatch movetoworkspace e+0,address:" + winId + " && hyprctl dispatch focuswindow address:" + winId];
                        shCmd.running = true;

                        // FIX: Borramos la línea que rompía el binding.
                        // Para cerrar el menú, usaremos la señal correcta que habla con el Overlay central:
                        minCajon.abrirMenu("")
                    }
                }
            }
        }
    }
}
