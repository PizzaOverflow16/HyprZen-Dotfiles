import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    id: mediaCajon
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    // Altura ampliada para que quepa Cava + Ecualizador
    width: 480; height: 600
    radius: 20

    // ✅ Fondo cristalino y borde reactivo
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "media" ? 1 : 0
    y: menuActivo === "media" ? 10 : -20
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }

    Process { id: shCmd }

    // ==========================================
    // ESTADO DEL REPRODUCTOR (MPRIS)
    // ==========================================
    property var reproductorActivo: null
    property bool estaSonando: reproductorActivo ? reproductorActivo.playbackState === MprisPlaybackState.Playing : false
    property string urlPortada: reproductorActivo && reproductorActivo.trackArtUrl ? reproductorActivo.trackArtUrl : ""
    property string titulo: reproductorActivo && reproductorActivo.trackTitle ? reproductorActivo.trackTitle : "Sin música"
    property string artista: reproductorActivo && reproductorActivo.trackArtist ? reproductorActivo.trackArtist : "Artista desconocido"
    property string fuenteNombre: reproductorActivo ? (reproductorActivo.identity || reproductorActivo.desktopEntry || "Audio") : "Sistema"

    // ==========================================
    // ESTADO DEL ECUALIZADOR (JSON)
    // ==========================================
    property var eqData: {"b1":0, "b2":0, "b3":0, "b4":0, "b5":0, "b6":0, "b7":0, "b8":0, "b9":0, "b10":0, "preset":"Flat"}
    property string scriptEq: "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/eq_control.sh"
    property bool arrastrandoEq: false

    Timer {
        interval: 500; running: mediaCajon.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            let lista = Mpris.players.values;
            let tocando = lista.find(p => p.playbackState === MprisPlaybackState.Playing);
            mediaCajon.reproductorActivo = tocando ? tocando : (lista.length > 0 ? lista[0] : null);

            if (!arrastrandoEq) {
                let xhr = new XMLHttpRequest();
                xhr.open("GET", "file:///tmp/eq_state.json?nocache=" + new Date().getTime(), false);
                xhr.send(null);
                if (xhr.status === 200) {
                    try {
                        mediaCajon.eqData = JSON.parse(xhr.responseText);
                    } catch(e) { console.log("[DEBUG] JSON EQ inválido"); }
                }
            }
        }
    }

    // ==========================================
    // EL MOTOR DE CAVA (30 FPS)
    // ==========================================
    property var cavaValores: []

    Timer {
        interval: 33
        running: mediaCajon.visible && mediaCajon.estaSonando
        repeat: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_cava.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200 || xhr.status === 0) {
                let datosBrutos = xhr.responseText.trim().split(";");
                let arrTemporal = [];
                for(let i = 0; i < 60; i++) {
                    let val = parseInt(datosBrutos[i]);
                    arrTemporal.push(isNaN(val) ? 0 : val);
                }
                mediaCajon.cavaValores = arrTemporal;
            }
        }
    }

    // ✅ Decoración de fondo dinámica
    Rectangle { width: 350; height: 350; radius: 175; x: -50; y: -50; color: root.tema.secundario; opacity: 0.05 }
    Rectangle { width: 400; height: 400; radius: 200; x: 150; y: 150; color: root.tema.primario; opacity: 0.04 }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // ==========================================
        // SECCIÓN SUPERIOR: REPRODUCTOR + CAVA
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            spacing: 25

            // --- VISUALIZADOR CAVA Y PORTADA ---
            Item {
                width: 180; height: 180
                Layout.alignment: Qt.AlignVCenter

                // 1. Barras Cava
                Repeater {
                    model: 60
                    Item {
                        anchors.centerIn: parent
                        width: 4; height: 180
                        rotation: index * 6
                        Rectangle {
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            property int valorCava: mediaCajon.cavaValores.length > index ? mediaCajon.cavaValores[index] : 0
                            width: 4; height: 6 + (valorCava * 0.3); radius: 2
                            // ✅ Barras brillan con el color primario cuando hay sonido fuerte, variante suave en reposo
                            color: valorCava > 15 ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.2)
                            Behavior on height { NumberAnimation { duration: 33 } }
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                    }
                }

                // 2. La Portada Circular
                ClippingRectangle {
                    anchors.centerIn: parent
                    width: 130; height: 130
                    radius: 65
                    color: root.tema.fondoVariante

                    Image {
                        anchors.fill: parent
                        source: mediaCajon.urlPortada
                        fillMode: Image.PreserveAspectCrop
                        visible: mediaCajon.urlPortada !== ""
                        smooth: true; mipmap: true

                        RotationAnimation on rotation {
                            from: 0; to: 360; duration: 15000; loops: Animation.Infinite
                            running: mediaCajon.estaSonando
                        }
                    }
                    Text { anchors.centerIn: parent; text: "󰎆"; color: Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 42; visible: mediaCajon.urlPortada === "" }
                }
            }

            // --- INFO Y CONTROLES ---
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                spacing: 5

                Text { text: mediaCajon.titulo; color: root.tema.textoPrimario; font.pixelSize: 22; font.weight: Font.Bold; Layout.fillWidth: true; elide: Text.ElideRight }
                Text { text: "BY " + mediaCajon.artista; color: root.tema.secundario; font.pixelSize: 14; font.weight: Font.Bold; Layout.fillWidth: true; elide: Text.ElideRight }

                Rectangle {
                    Layout.topMargin: 5
                    implicitWidth: txtFuente.implicitWidth + 30; implicitHeight: 24; radius: 12;
                    color: root.tema.fondoVariante
                    RowLayout {
                        anchors.centerIn: parent; spacing: 5
                        Text { text: "󰎈"; color: root.tema.primario; font.pixelSize: 12 }
                        Text { id: txtFuente; text: "VIA " + mediaCajon.fuenteNombre; color: root.tema.textoPrimario; font.pixelSize: 11; font.weight: Font.Bold }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    // BOTÓN ALEATORIO
                    Text {
                        property bool modoAleatorio: reproductorActivo ? reproductorActivo.shuffle : false
                        text: "󰒝"
                        // ✅ Verde si está activo, colores del tema si no
                        color: modoAleatorio ? "#A6E3A1" : (hoverShuffle.containsMouse ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.6))
                        font.pixelSize: 22
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea {
                            id: hoverShuffle; anchors.fill: parent; anchors.margins: -10;
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor;
                            onClicked: if(reproductorActivo) reproductorActivo.shuffle = !reproductorActivo.shuffle
                        }
                    }

                    Text {
                        text: "󰒮"; color: hoverPrev.containsMouse ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.8); font.pixelSize: 24
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea { id: hoverPrev; anchors.fill: parent; anchors.margins: -10; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if(reproductorActivo) reproductorActivo.previous() }
                    }
                    Rectangle {
                        width: 46; height: 46; radius: 12;
                        // ✅ Botón de play principal usa el color primario
                        color: root.tema.primario
                        Text { anchors.centerIn: parent; text: mediaCajon.estaSonando ? "󰏤" : "󰐊"; color: "#11111B"; font.pixelSize: 24 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if(reproductorActivo) reproductorActivo.togglePlaying() }
                    }
                    Text {
                        text: "󰒭"; color: hoverNext.containsMouse ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.8); font.pixelSize: 24
                        Behavior on color { ColorAnimation { duration: 150 } }
                        MouseArea { id: hoverNext; anchors.fill: parent; anchors.margins: -10; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if(reproductorActivo) reproductorActivo.next() }
                    }
                }
            }
        }

        // Línea Separadora
        Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(root.tema.textoPrimario, 0.15) }

        // ==========================================
        // SECCIÓN INFERIOR: ECUALIZADOR
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Ecualizador"; color: root.tema.textoPrimario; font.pixelSize: 16; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            Text { text: "Perfil:"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 12 }
            Text { text: mediaCajon.eqData["preset"] || "Personalizado"; color: root.tema.primario; font.pixelSize: 14; font.weight: Font.Bold }
        }

        // SLIDERS VERTICALES (10 Bandas)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            spacing: 0

            Repeater {
                model: [
                    { label: "31", key: "b1" }, { label: "63", key: "b2" }, { label: "125", key: "b3" },
                    { label: "250", key: "b4" }, { label: "500", key: "b5" }, { label: "1k", key: "b6" },
                    { label: "2k", key: "b7" }, { label: "4k", key: "b8" }, { label: "8k", key: "b9" }, { label: "16k", key: "b10" }
                ]
                delegate: Item {
                    Layout.fillWidth: true; Layout.fillHeight: true

                    property real valDb: mediaCajon.eqData[modelData.key] !== undefined ? parseFloat(mediaCajon.eqData[modelData.key]) : 0
                    property real fillPct: Math.max(0.0, Math.min(1.0, (valDb + 15) / 30))

                    ColumnLayout {
                        anchors.fill: parent; spacing: 10

                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true

                            Rectangle {
                                width: 6; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                                radius: 3; color: Qt.alpha(root.tema.textoPrimario, 0.1) // ✅ Fondo de la barra
                                Rectangle {
                                    width: 6; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                                    height: parent.height * fillPct
                                    radius: 3; color: root.tema.primario // ✅ Relleno de la barra
                                }
                            }
                            Rectangle {
                                width: 14; height: 14; radius: 7;
                                color: root.tema.secundario // ✅ El "botón" del slider en secundario
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: parent.height - (parent.height * fillPct) - (height / 2)
                                Behavior on y { enabled: !mediaCajon.arrastrandoEq; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            }

                            MouseArea {
                                anchors.fill: parent; anchors.margins: -10; cursorShape: Qt.PointingHandCursor
                                onPressed: (mouse) => { mediaCajon.arrastrandoEq = true; actualizarBanda(mouse.y); }
                                onPositionChanged: (mouse) => { if(pressed) actualizarBanda(mouse.y); }
                                onReleased: {
                                    mediaCajon.arrastrandoEq = false;
                                    Quickshell.execDetached(["bash", scriptEq, "apply"]);
                                }
                                function actualizarBanda(my) {
                                    let rawPct = 1.0 - (my / height);
                                    let safePct = Math.max(0.0, Math.min(1.0, rawPct));
                                    let nuevoDb = Math.round((safePct * 30) - 15);

                                    let tempObj = JSON.parse(JSON.stringify(mediaCajon.eqData));
                                    tempObj[modelData.key] = nuevoDb;
                                    tempObj["preset"] = "Personalizado";
                                    mediaCajon.eqData = tempObj;

                                    Quickshell.execDetached(["bash", scriptEq, "set_band", index + 1, nuevoDb]);
                                }
                            }
                        }

                        Text {
                            text: modelData.label
                            color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 10; font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // BOTONERA DE PRESETS
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            rowSpacing: 10; columnSpacing: 10

            Repeater {
                model: ["Flat", "Bass", "Treble", "Vocal", "Pop", "Rock", "Jazz", "Classic"]
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 35
                    radius: 8
                    property bool esActivo: mediaCajon.eqData["preset"] === modelData

                    // ✅ Botones de preset reactivos
                    color: esActivo ? root.tema.primario : (hoverPreset.containsMouse ? root.tema.capsulaHover : root.tema.fondoVariante)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent; text: modelData
                        color: esActivo ? "#11111B" : root.tema.textoPrimario
                        font.pixelSize: 12; font.weight: Font.Bold
                    }

                    MouseArea {
                        id: hoverPreset; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["bash", scriptEq, "preset", modelData]);
                            let tempObj = JSON.parse(JSON.stringify(mediaCajon.eqData));
                            tempObj["preset"] = modelData;
                            mediaCajon.eqData = tempObj;
                        }
                    }
                }
            }
        }
    }
}
