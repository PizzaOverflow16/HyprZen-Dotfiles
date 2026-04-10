import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick.Shapes
import Quickshell.Services.Notifications

Rectangle {
    id: rootLock // Cambié el ID para evitar conflictos con el 'root' de shell.qml
    required property var context

    // ✅ Fondo base al tono del sistema por si el blur tarda un milisegundo en cargar
    color: "transparent"

    // ==========================================
    // 1. EL FONDO TOTAL (Con Blur global y Respaldo)
    // ==========================================

    // CAPA A: Tu wallpaper real de respaldo
    Image {
        id: wallpaperBackup
        anchors.fill: parent
        source: root.wallpaperActual
        fillMode: Image.PreserveAspectCrop

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            // 📉 Bajamos el desenfoque para que se distingan las formas (antes 64)
            blurMax: 24
        }
    }

    // CAPA B: La captura de pantalla en vivo
    ScreencopyView {
        id: backgroundCapture
        anchors.fill: parent
        captureSource: screen
        visible: backgroundCapture.active

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            // 📉 Bajamos el desenfoque aquí también
            blurMax: 24
            saturation: 0.9 // Dejamos los colores un poquito más vivos
        }
    }

    // CAPA C: El tinte oscuro
    Rectangle {
        anchors.fill: parent
        color: root.tema.barraFondo
        // 📉 Mucho más transparente para que pase la luz y el fondo (antes 0.6)
        opacity: 0.35
    }

    // ==========================================
    // 2. EL DASHBOARD CENTRAL
    // ==========================================
    Rectangle {
        id: mainPanel
        anchors.centerIn: parent
        width: 1250
        height: 750
        // ✅ El panel principal absorbe el color base de Matugen
        color: Qt.alpha(root.tema.fondoSuperficie, 0.85)
        radius: 20

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.alpha("#000000", 0.5)
            blurMax: 30
            shadowVerticalOffset: 10
        }

        // ==========================================
        // 3. LA CUADRÍCULA DE 3 COLUMNAS
        // ==========================================
        GridLayout {
            anchors.fill: parent
            anchors.margins: 40
            columns: 3
            columnSpacing: 40

            // ------------------------------------------
            // 3.1 COLUMNA IZQUIERDA
            // ------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 350
                spacing: 0

                // --- 1. WIDGET DEL CLIMA ---
                Rectangle {
                    id: weatherWidget
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 15

                    // EFECTO GLASS CON BORDES DE MATUGEN
                    color: Qt.alpha(root.tema.fondoVariante, 0.3)
                    border.color: Qt.alpha(root.tema.primario, 0.3)
                    border.width: 1

                    property string temp: "--°C"
                    property string desc: "Buscando cielo..."
                    property string icon: "󰖐"
                    property color iconColor: root.tema.textoPrimario

                    Timer {
                        interval: 1800000; running: true; repeat: true; triggeredOnStart: true
                        onTriggered: {
                            let xhr = new XMLHttpRequest();
                            xhr.open("GET", "https://wttr.in/Oaxaca?format=j1&lang=es", true);
                            xhr.onreadystatechange = function() {
                                if (xhr.readyState === 4 && xhr.status === 200) {
                                    try {
                                        let data = JSON.parse(xhr.responseText);
                                        let current = data.current_condition[0];
                                        weatherWidget.temp = current.temp_C + "°C";
                                        let rawDesc = (current.lang_es && current.lang_es[0]) ? current.lang_es[0].value : current.weatherDesc[0].value;
                                        weatherWidget.desc = rawDesc.charAt(0).toUpperCase() + rawDesc.slice(1);
                                        let code = current.weatherCode;

                                        // ✅ Íconos teñidos con tu paleta actual
                                        if (code === "113") { weatherWidget.icon = "󰖙"; weatherWidget.iconColor = root.tema.primario; }
                                        else if (code === "116") { weatherWidget.icon = "󰖕"; weatherWidget.iconColor = root.tema.secundario; }
                                        else if (code === "119" || code === "122") { weatherWidget.icon = "󰖐"; weatherWidget.iconColor = Qt.alpha(root.tema.textoPrimario, 0.7); }
                                        else if (code === "353" || code === "356" || code === "359" || code === "293" || code === "296" || code === "299" || code === "302" || code === "305" || code === "308") { weatherWidget.icon = "󰖗"; weatherWidget.iconColor = root.tema.primario; }
                                        else if (code === "386" || code === "389" || code === "392" || code === "395") { weatherWidget.icon = "󰖓"; weatherWidget.iconColor = root.tema.secundario; }
                                        else { weatherWidget.icon = "󰖐"; weatherWidget.iconColor = root.tema.textoPrimario; }
                                    } catch(e) { console.log("Error parseando JSON del clima"); }
                                }
                            }
                            xhr.send();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20

                        Text {
                            text: weatherWidget.icon
                            color: weatherWidget.iconColor
                            font.pixelSize: 45
                            font.family: "FiraCode Nerd Font"
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 500 } }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            Text {
                                text: weatherWidget.temp
                                color: root.tema.textoPrimario
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                font.family: "FiraCode Nerd Font"
                            }
                            Text {
                                text: weatherWidget.desc
                                color: Qt.alpha(root.tema.textoPrimario, 0.7)
                                font.pixelSize: 13
                                font.family: "FiraCode Nerd Font"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 15 } // Separador

                // --- 2. WIDGET DE INFO DEL SISTEMA ---
                Rectangle {
                    id: sysInfoWidget
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 15

                    // EFECTO GLASS CON BORDES DE MATUGEN
                    color: Qt.alpha(root.tema.fondoVariante, 0.3)
                    border.color: Qt.alpha(root.tema.primario, 0.3)
                    border.width: 1

                    property string batIcon: "󰂎"
                    property string batPct: "0%"
                    property string uptimeText: "Calculando..."

                    Timer {
                        interval: 2000; running: true; repeat: true; triggeredOnStart: true
                        onTriggered: {
                            let xhr = new XMLHttpRequest();
                            xhr.open("GET", "file:///tmp/qs_status.txt?nocache=" + new Date().getTime(), false);
                            xhr.send(null);
                            if (xhr.status === 200 || xhr.status === 0) {
                                let partes = xhr.responseText.trim().split("|");
                                if (partes.length >= 4) {
                                    sysInfoWidget.batIcon = partes[2];
                                    sysInfoWidget.batPct = partes[3] + "%";
                                }
                            }
                        }
                    }

                    Timer {
                        interval: 60000; running: true; repeat: true; triggeredOnStart: true
                        onTriggered: {
                            let xhr = new XMLHttpRequest();
                            xhr.open("GET", "file:///proc/uptime", false);
                            xhr.send(null);
                            if (xhr.status === 200 || xhr.status === 0) {
                                let segundosTotales = parseFloat(xhr.responseText.split(" ")[0]);
                                let dias = Math.floor(segundosTotales / 86400);
                                let horas = Math.floor((segundosTotales % 86400) / 3600);
                                let minutos = Math.floor((segundosTotales % 3600) / 60);
                                let texto = "";
                                if (dias > 0) texto += dias + (dias === 1 ? " day, " : " days, ");
                                if (horas > 0) texto += horas + (horas === 1 ? " hour, " : " hours, ");
                                texto += minutos + " mins";
                                sysInfoWidget.uptimeText = texto;
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 25
                        spacing: 15

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 25

                            Rectangle {
                                width: 95; height: 95
                                radius: 12
                                clip: true
                                Image {
                                    anchors.fill: parent
                                    source: "file:///home/elton/dev/config/dotfiles/imagenes_usuarios/wallpaperbetter.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text { text: "WM   : Hyprland"; color: root.tema.textoPrimario; font.pixelSize: 14; font.family: "FiraCode Nerd Font"; font.weight: Font.Bold }
                                Text { text: "USER : elton"; color: root.tema.textoPrimario; font.pixelSize: 14; font.family: "FiraCode Nerd Font"; font.weight: Font.Bold }
                                Text {
                                    text: "UP   : " + sysInfoWidget.uptimeText
                                    color: Qt.alpha(root.tema.textoPrimario, 0.7)
                                    font.pixelSize: 14
                                    font.family: "FiraCode Nerd Font"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "BATT : " + sysInfoWidget.batIcon + " " + sysInfoWidget.batPct
                                    color: Qt.alpha(root.tema.textoPrimario, 0.7)
                                    font.pixelSize: 14
                                    font.family: "FiraCode Nerd Font"
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 20

                            Repeater {
                                // ✅ Paleta dinámica de Matugen combinada con colores semánticos
                                model: [root.tema.primario, root.tema.secundario, "#F38BA8", "#FAB387", "#A6E3A1", "#CBA6F7"]
                                delegate: Rectangle {
                                    width: 30; height: 30
                                    radius: 6
                                    color: modelData
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                Item { Layout.preferredHeight: 15 } // Separador

                // --- 3. WIDGET DE MÚSICA ---
                Rectangle {
                    id: mediaWidget
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    radius: 15
                    clip: true

                    // EFECTO GLASS
                    color: Qt.alpha(root.tema.fondoVariante, 0.3)
                    border.color: Qt.alpha(root.tema.primario, 0.3)
                    border.width: 1

                    property var reproductorActivo: null
                    property bool estaSonando: reproductorActivo ? reproductorActivo.playbackState === MprisPlaybackState.Playing : false
                    property string urlPortada: reproductorActivo && reproductorActivo.trackArtUrl ? reproductorActivo.trackArtUrl : ""
                    property string titulo: reproductorActivo && reproductorActivo.trackTitle ? reproductorActivo.trackTitle : ""
                    property string artista: reproductorActivo && reproductorActivo.trackArtist ? reproductorActivo.trackArtist : ""
                    property string fuenteNombre: reproductorActivo ? (reproductorActivo.identity || "Desconocido") : ""

                    Timer {
                        interval: 500; running: true; repeat: true; triggeredOnStart: true
                        onTriggered: {
                            let lista = Mpris.players.values || Mpris.players;
                            if (!lista || lista.length === 0) {
                                mediaWidget.reproductorActivo = null;
                                return;
                            }
                            let validos = [];
                            for(let i = 0; i < lista.length; i++) {
                                if(lista[i].identity !== "plasma-browser-integration") {
                                    validos.push(lista[i]);
                                }
                            }
                            if (validos.length === 0) {
                                mediaWidget.reproductorActivo = null;
                                return;
                            }
                            let mpdSonando = validos.find(p => p.identity === "mpd" && p.playbackState === MprisPlaybackState.Playing);
                            let cualquieraSonando = validos.find(p => p.playbackState === MprisPlaybackState.Playing);
                            let mpdPausado = validos.find(p => p.identity === "mpd");
                            mediaWidget.reproductorActivo = mpdSonando || cualquieraSonando || mpdPausado || validos[0];
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "No hay música reproduciendo"
                        color: Qt.alpha(root.tema.textoPrimario, 0.5)
                        font.pixelSize: 16
                        font.family: "FiraCode Nerd Font"
                        font.weight: Font.DemiBold
                        visible: mediaWidget.reproductorActivo === null
                    }

                    Image {
                        anchors.fill: parent
                        source: mediaWidget.urlPortada
                        fillMode: Image.PreserveAspectCrop
                        visible: mediaWidget.urlPortada !== ""
                        layer.enabled: true
                        layer.effect: MultiEffect { saturation: 0.5; blurEnabled: true; blur: 0.5 }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#11111B"
                        opacity: mediaWidget.urlPortada !== "" ? 0.6 : 0.0
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 8
                        visible: mediaWidget.reproductorActivo !== null

                        Text {
                            Layout.fillWidth: true
                            text: mediaWidget.titulo || "Sin título"
                            color: root.tema.textoPrimario // ✅ Texto que resalta sobre la portada
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            font.family: "FiraCode Nerd Font"
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (mediaWidget.artista || "Artista desconocido") + " • " + mediaWidget.fuenteNombre
                            color: Qt.alpha(root.tema.textoPrimario, 0.8)
                            font.pixelSize: 14
                            font.family: "FiraCode Nerd Font"
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            spacing: 40

                            Text {
                                text: "󰒮"
                                color: root.tema.textoPrimario
                                font.pixelSize: 28
                                font.family: "FiraCode Nerd Font"
                                MouseArea {
                                    anchors.fill: parent;
                                    onClicked: if(mediaWidget.reproductorActivo) mediaWidget.reproductorActivo.previous()
                                }
                            }

                            Text {
                                text: mediaWidget.estaSonando ? "󰏤" : "󰐊"
                                // ✅ Botón de Play con tu color de Acento Primario
                                color: root.tema.primario
                                font.pixelSize: 38
                                font.family: "FiraCode Nerd Font"
                                MouseArea {
                                    anchors.fill: parent;
                                    onClicked: if(mediaWidget.reproductorActivo) mediaWidget.reproductorActivo.togglePlaying()
                                }
                            }

                            Text {
                                text: "󰒭"
                                color: root.tema.textoPrimario
                                font.pixelSize: 28
                                font.family: "FiraCode Nerd Font"
                                MouseArea {
                                    anchors.fill: parent;
                                    onClicked: if(mediaWidget.reproductorActivo) mediaWidget.reproductorActivo.next()
                                }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // 3.2 COLUMNA CENTRAL (Reloj, Foto y Contraseña)
            // ------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 15

                Item { Layout.fillHeight: true }

                Text {
                    id: clockText
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 100
                    font.weight: Font.Bold
                    font.family: "FiraCode Nerd Font"
                    // ✅ Reloj del color principal de tu wallpaper
                    color: root.tema.primario

                    Timer {
                        interval: 1000; running: true; repeat: true
                        onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
                    }
                    Component.onCompleted: clockText.text = Qt.formatTime(new Date(), "hh:mm")
                }

                Text {
                    id: dateText
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    font.family: "FiraCode Nerd Font"
                    color: root.tema.textoPrimario

                    function actualizarFecha() {
                        let locale = Qt.locale("es_MX");
                        let fecha = new Date().toLocaleDateString(locale, "dddd, d 'de' MMMM 'de' yyyy");
                        dateText.text = fecha.charAt(0).toUpperCase() + fecha.slice(1);
                    }

                    Timer {
                        interval: 60000; running: true; repeat: true
                        onTriggered: dateText.actualizarFecha()
                    }
                    Component.onCompleted: dateText.actualizarFecha()
                }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 30
                    Layout.bottomMargin: 30
                    width: 150
                    height: 150

                    Image {
                        id: pfpImage
                        source: root.fotoPerfilActual
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                    }

                    Rectangle {
                        id: mask
                        anchors.fill: parent
                        radius: width / 2
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: pfpImage
                        maskSource: mask
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: width / 2
                        // ✅ El aro de tu foto de perfil usa el color primario
                        border.color: root.tema.primario
                        border.width: 3
                    }
                }

                // --- CAJA DE CONTRASEÑA ---
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 320
                    height: 50
                    radius: 25

                    // ✅ Fondo reactivo a Matugen
                    color: Qt.alpha(root.tema.fondoVariante, 0.8)
                    // ✅ Bordes: Rojo en caso de error, primario cuando estás escribiendo, variante transparente en reposo
                    border.color: rootLock.context.showFailure ? "#F38BA8" : (pwdInput.activeFocus ? root.tema.primario : "transparent")
                    border.width: 2

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Text {
                            text: rootLock.context.showFailure ? "󰌾" : "󰌿"
                            color: rootLock.context.showFailure ? "#F38BA8" : root.tema.primario
                            font.pixelSize: 18
                            font.family: "FiraCode Nerd Font"
                        }

                        TextInput {
                            id: pwdInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter

                            color: root.tema.textoPrimario
                            font.pixelSize: 18
                            echoMode: TextInput.Password
                            clip: true
                            focus: true
                            enabled: !rootLock.context.unlockInProgress

                            onTextChanged: rootLock.context.showFailure = false
                            onAccepted: {
                                rootLock.context.tryUnlock(text)
                                text = ""
                            }

                            Text {
                                text: rootLock.context.showFailure ? "Contraseña incorrecta" : "Ingresa tu contraseña"
                                color: rootLock.context.showFailure ? "#F38BA8" : Qt.alpha(root.tema.textoPrimario, 0.5)
                                font.pixelSize: 16
                                visible: !pwdInput.text && !pwdInput.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }

            // ------------------------------------------
            // 3.3 COLUMNA DERECHA (Recursos y Notificaciones del Daemon)
            // ------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 350
                spacing: 20

                // --- 1. WIDGET DE RECURSOS ---
                Rectangle {
                    id: sysResWidget
                    Layout.fillWidth: true
                    Layout.preferredHeight: 340
                    radius: 15

                    // EFECTO GLASS CON BORDES DE MATUGEN
                    color: Qt.alpha(root.tema.fondoVariante, 0.3)
                    border.color: Qt.alpha(root.tema.primario, 0.3)
                    border.width: 1

                    // ✅ Los anillos mantienen sus colores de diagnóstico (para saber qué es CPU vs Temp al instante)
                    ListModel {
                        id: resModel
                        ListElement { title: "CPU"; value: 0; max: 100; suffix: "%"; ringColor: "#F38BA8" }
                        ListElement { title: "RAM"; value: 0; max: 100; suffix: "%"; ringColor: "#A6E3A1" }
                        ListElement { title: "DISK"; value: 0; max: 100; suffix: "%"; ringColor: "#FAB387" }
                        ListElement { title: "TEMP"; value: 0; max: 100; suffix: "°C"; ringColor: "#F9E2AF" }
                    }

                    Timer {
                        interval: 1000; running: true; repeat: true; triggeredOnStart: true
                        onTriggered: {
                            let xhr = new XMLHttpRequest();
                            xhr.open("GET", "file:///tmp/qs_sys.txt?nocache=" + new Date().getTime(), false);
                            xhr.send(null);
                            if (xhr.status === 200 || xhr.status === 0) {
                                let partes = xhr.responseText.trim().split("|");
                                if (partes.length >= 4) {
                                    resModel.setProperty(0, "value", parseFloat(partes[0]) || 0);
                                    resModel.setProperty(1, "value", parseFloat(partes[1]) || 0);
                                    resModel.setProperty(2, "value", parseFloat(partes[2]) || 0);
                                    resModel.setProperty(3, "value", parseFloat(partes[3]) || 0);
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "󰻠 Monitores del Sistema"
                            color: root.tema.textoPrimario
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            font.family: "FiraCode Nerd Font"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        GridLayout {
                            Layout.alignment: Qt.AlignHCenter
                            columns: 2
                            rowSpacing: 30
                            columnSpacing: 40

                            Repeater {
                                model: resModel
                                delegate: Item {
                                    id: gaugeItem
                                    width: 110; height: 110

                                    property real animValue: model.value
                                    Behavior on animValue { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

                                    Shape {
                                        anchors.fill: parent
                                        layer.enabled: true
                                        layer.samples: 4

                                        ShapePath {
                                            // ✅ Aro de fondo con color variante
                                            strokeColor: Qt.alpha(root.tema.textoPrimario, 0.1)
                                            fillColor: "transparent"
                                            strokeWidth: 10
                                            capStyle: ShapePath.RoundCap
                                            PathAngleArc {
                                                centerX: 55; centerY: 55
                                                radiusX: 45; radiusY: 45
                                                startAngle: 135; sweepAngle: 270
                                            }
                                        }

                                        ShapePath {
                                            strokeColor: model.ringColor
                                            fillColor: "transparent"
                                            strokeWidth: 10
                                            capStyle: ShapePath.RoundCap
                                            PathAngleArc {
                                                centerX: 55; centerY: 55
                                                radiusX: 45; radiusY: 45
                                                startAngle: 135
                                                sweepAngle: Math.min((gaugeItem.animValue / model.max) * 270, 270)
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 0
                                        Text {
                                            text: model.title
                                            color: Qt.alpha(root.tema.textoPrimario, 0.7)
                                            font.pixelSize: 13
                                            font.weight: Font.Bold
                                            font.family: "FiraCode Nerd Font"
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Text {
                                            text: Math.round(gaugeItem.animValue) + model.suffix
                                            color: root.tema.textoPrimario
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                            font.family: "FiraCode Nerd Font"
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // --- 2. CENTRO DE NOTIFICACIONES (Conectado a root de shell.qml) ---
                // ==========================================
                Rectangle {
                    id: notifWidget
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 15

                    // EFECTO GLASS CON BORDES DE MATUGEN
                    color: Qt.alpha(root.tema.fondoVariante, 0.3)
                    border.color: Qt.alpha(root.tema.primario, 0.3)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        Text {
                            text: "󰂚 Notificaciones Recientes"
                            color: root.tema.textoPrimario
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            font.family: "FiraCode Nerd Font"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 10

                            // Magia: Lee del motor global de Quickshell
                            model: (typeof root !== "undefined" && root.motorNotificaciones) ? root.motorNotificaciones.historial : []

                            Text {
                                text: "Nada nuevo por aquí"
                                color: Qt.alpha(root.tema.textoPrimario, 0.5)
                                font.pixelSize: 14
                                font.family: "FiraCode Nerd Font"
                                anchors.centerIn: parent
                                visible: parent.count === 0
                            }

                            delegate: Rectangle {
                                width: ListView.view.width
                                implicitHeight: contentCol.implicitHeight + 20
                                radius: 10
                                color: Qt.alpha(root.tema.fondoVariante, 0.5)
                                // ✅ Notificaciones normales toman el color primario, las críticas el rojo de alerta
                                border.color: urgencia === 2 ? "#F38BA8" : Qt.alpha(root.tema.primario, 0.5)
                                border.width: 1

                                property var notif: modelData
                                property int urgencia: notif ? notif.urgency : 1

                                ColumnLayout {
                                    id: contentCol
                                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true; spacing: 8
                                        Text { text: "󰂚"; color: urgencia === 2 ? "#F38BA8" : root.tema.primario; font.pixelSize: 14 }
                                        Text {
                                            text: (notif && notif.appName !== "") ? notif.appName : "Sistema"
                                            color: urgencia === 2 ? "#F38BA8" : Qt.alpha(root.tema.textoPrimario, 0.7)
                                            font.pixelSize: 12; font.weight: Font.Bold; Layout.fillWidth: true
                                        }

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            color: closeMa.containsMouse ? "#F38BA8" : "transparent"
                                            Text { anchors.centerIn: parent; text: "󰅖"; color: closeMa.containsMouse ? "#1E1E2E" : Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 14 }
                                            MouseArea {
                                                id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor;
                                                onClicked: if(root.motorNotificaciones) root.motorNotificaciones.eliminarDelHistorial(notif.id)
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true; spacing: 12; Layout.alignment: Qt.AlignTop
                                        Rectangle {
                                            property string rutaIcono: (root.motorNotificaciones && root.motorNotificaciones.obtenerIcono) ? root.motorNotificaciones.obtenerIcono(notif) : ""
                                            visible: rutaIcono !== ""
                                            width: 40; height: 40; radius: 8; color: "transparent"; clip: true
                                            Image { anchors.fill: parent; source: parent.rutaIcono; fillMode: Image.PreserveAspectCrop }
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 4
                                            Text { text: notif ? notif.summary : ""; color: root.tema.textoPrimario; font.pixelSize: 14; font.weight: Font.Bold; Layout.fillWidth: true; wrapMode: Text.Wrap }
                                            Text {
                                                property string txt: notif ? notif.body : ""
                                                text: txt.length > 100 ? txt.substr(0, 97) + "..." : txt
                                                color: Qt.alpha(root.tema.textoPrimario, 0.8); font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.Wrap; visible: txt !== ""
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
