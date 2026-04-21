import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: aiWindow

    anchors { top: true; bottom: true; right: true }
    implicitWidth: 400
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    mask: Region { item: panelDeslizante }

    property bool abierto: false

    // ✅ ESTA ES LA MAGIA QUE FALTA
    onAbiertoChanged: {
        if (abierto) {
            inputMensaje.forceActiveFocus(); // Obliga al cursor a ir a la caja de texto
        } else {
            inputMensaje.focus = false; // Suelta el foco cuando se cierra
        }
    }

    property bool cargando: false
    property string apiKey: "" // <--- MANTÉN TU LLAVE AQUÍ

    function enviarMensaje() {
        let texto = inputMensaje.text.trim();
        if (texto === "" || cargando) return;

        chatModel.append({ "rol": "user", "texto": texto });

        inputMensaje.text = "";
        cargando = true;
        scrollChat.positionViewAtEnd();

        let xhr = new XMLHttpRequest();
        xhr.open("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=" + apiKey);
        xhr.setRequestHeader("Content-Type", "application/json");

        // Petición blindada: solo mandamos el mensaje actual
        let payload = {
            "contents": [{ "parts": [{ "text": texto }] }]
        };

        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                cargando = false;
                if (xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText);
                    let respuestaIA = response.candidates[0].content.parts[0].text;
                    chatModel.append({ "rol": "model", "texto": respuestaIA });
                } else {
                    console.log("=== ERROR GEMINI API ===");
                    console.log(xhr.responseText);
                    chatModel.append({ "rol": "model", "texto": "Error de conexión." });
                }
                scrollChat.positionViewAtEnd();
            }
        };
        xhr.send(JSON.stringify(payload));
    }

    Rectangle {
        id: panelDeslizante
        width: parent.width
        height: parent.height

        x: aiWindow.abierto ? 0 : aiWindow.width - 5
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

        // ✅ Fondo translúcido adaptado al tema actual
        color: root.tema.flotanteFondo
        border.color: root.tema.flotanteBorde
        border.width: 1

        MouseArea {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // ✅ La pestaña que "jala" el menú cambia sutilmente con tu tema
            onEntered: panelDeslizante.color = Qt.alpha(root.tema.fondoVariante, 0.95)
            onExited: panelDeslizante.color = root.tema.flotanteFondo
            onClicked: aiWindow.abierto = !aiWindow.abierto
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            anchors.leftMargin: 25
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰚩 Gemini Assistant"
                    // ✅ Título con el color principal
                    color: root.tema.primario; font.pixelSize: 18; font.weight: Font.Bold; font.family: "FiraCode Nerd Font"
                }
                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: btnCloseIA.containsMouse ? "#F38BA8" : "transparent"
                    Text {
                        anchors.centerIn: parent; text: "󰅖"
                        color: btnCloseIA.containsMouse ? "#1E1E2E" : Qt.alpha(root.tema.textoPrimario, 0.6)
                        font.pixelSize: 20
                    }
                    MouseArea {
                        id: btnCloseIA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: aiWindow.abierto = false
                    }
                }
            }

            ListView {
                id: scrollChat
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 20
                model: ListModel { id: chatModel }

                add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 } }

                delegate: ColumnLayout {
                    width: scrollChat.width
                    spacing: 6

                    Text {
                        text: model.rol === "user" ? "󰀉 Elton" : "󰚩 Gemini"
                        // ✅ Usuario = Color Secundario, Gemini = Color Primario
                        color: model.rol === "user" ? root.tema.secundario : root.tema.primario
                        font.pixelSize: 12; font.weight: Font.Bold; font.family: "FiraCode Nerd Font"
                        Layout.alignment: model.rol === "user" ? Qt.AlignRight : Qt.AlignLeft
                    }

                    Rectangle {
                        Layout.alignment: model.rol === "user" ? Qt.AlignRight : Qt.AlignLeft
                        Layout.preferredWidth: Math.min(txtNotif.implicitWidth + 24, scrollChat.width * 0.85)
                        Layout.preferredHeight: txtNotif.implicitHeight + 20
                        radius: 12

                        // ✅ Las burbujas combinan con el fondo de tu sistema
                        color: model.rol === "user" ? root.tema.fondoVariante : Qt.alpha(root.tema.barraFondo, 0.8)
                        border.color: model.rol === "user" ? root.tema.secundario : root.tema.primario
                        border.width: 1

                        Text {
                            id: txtNotif
                            anchors.fill: parent
                            anchors.margins: 10
                            text: model.texto
                            color: root.tema.textoPrimario
                            font.pixelSize: 14
                            font.family: "FiraCode Nerd Font"
                            wrapMode: Text.Wrap
                            textFormat: Text.MarkdownText // Soporte para negritas y formato bonito
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: aiWindow.cargando
                spacing: 10

                Text {
                    text: "󰚩"
                    color: root.tema.primario
                    font.pixelSize: 16
                    font.family: "FiraCode Nerd Font"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 500 }
                        NumberAnimation { to: 1.0; duration: 500 }
                    }
                }
                Text {
                    text: "Analizando..."
                    color: Qt.alpha(root.tema.textoPrimario, 0.7)
                    font.pixelSize: 13
                    font.family: "FiraCode Nerd Font"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 25
                // ✅ Barra de entrada oscurecida
                color: Qt.alpha(root.tema.barraFondo, 0.6)
                border.color: inputMensaje.activeFocus ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.2)
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextInput {
                    id: inputMensaje
                    anchors.fill: parent
                    anchors.leftMargin: 20; anchors.rightMargin: 20
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.tema.textoPrimario
                    font.pixelSize: 14
                    clip: true

                    Keys.onEscapePressed: {
                        aiWindow.abierto = false;
                        inputMensaje.focus = false;
                    }

                    onActiveFocusChanged: {
                        if (!activeFocus && aiWindow.abierto) {
                            aiWindow.abierto = false;
                        }
                    }

                    onAccepted: aiWindow.enviarMensaje()

                    Text {
                        text: "Escribe algo y presiona Enter..."
                        color: Qt.alpha(root.tema.textoPrimario, 0.4)
                        visible: !parent.text && !parent.activeFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
