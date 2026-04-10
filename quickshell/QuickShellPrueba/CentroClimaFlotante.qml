import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

Rectangle {
    id: climaFlotante
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    width: 640; height: 420
    radius: 24

    // --- ESTILO FROST DINÁMICO ---
    color: "transparent"
    // Borde con un 30% de opacidad usando el color primario de Matugen
    border.color: Qt.alpha(root.tema.primario, 0.3)
    border.width: 1

    visible: opacity > 0
    opacity: menuActivo === "clima" ? 1 : 0
    x: parent.width / 2 - width / 2
    y: menuActivo === "clima" ? 120 : 70
    Behavior on opacity { NumberAnimation { duration: 250 } }
    Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }

    MouseArea { anchors.fill: parent }

    // ¡Los íconos ahora usan la paleta de colores de tu Wallpaper!
    function getIcon(code) {
        if (code === "113") return ["󰖙", root.tema.primario];
        if (code === "116") return ["󰖕", root.tema.secundario];
        if (code === "119" || code === "122") return ["󰖐", Qt.alpha(root.tema.textoPrimario, 0.7)];
        if (code === "353" || code === "356" || code === "359" || code === "293" || code === "296" || code === "299" || code === "302" || code === "305" || code === "308") return ["󰖗", root.tema.primario];
        if (code === "386" || code === "389" || code === "392" || code === "395") return ["󰖓", root.tema.secundario];
        return ["󰖐", root.tema.textoPrimario];
    }

    // ==========================================
    // CAPA 1: FONDO FROST (Desenfoque al tono del wallpaper)
    // ==========================================
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        // Fondo súper transparente tintado con el color base de Matugen
        color: Qt.alpha(root.tema.fondoSuperficie, 0.15)
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.4
        }
    }

    // ==========================================
    // CAPA 2: CONTENIDO SÓLIDO (100% Nítido)
    // ==========================================
    Item {
        id: contentLayer
        anchors.fill: parent

        property var hourlyData: []

        Timer {
            interval: 1800000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: {
                let xhr = new XMLHttpRequest();
                xhr.open("GET", "https://wttr.in/Oaxaca?format=j1", true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            let data = JSON.parse(xhr.responseText);
                            contentLayer.hourlyData = data.weather[0].hourly;
                        } catch(e) {}
                    }
                }
                xhr.send();
            }
        }

        // --- RELOJ Y FECHA ---
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            z: 10

            Text {
                id: clockMain
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 85
                font.weight: Font.Black
                font.family: "SF Pro Display Heavy"
                color: root.tema.textoPrimario
                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockMain.text = Qt.formatTime(new Date(), "hh:mm") }
                Component.onCompleted: text = Qt.formatTime(new Date(), "hh:mm")
            }

            Text {
                id: dateMain
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 18
                font.family: "FiraCode Nerd Font"
                color: root.tema.primario
                Timer {
                    interval: 60000; running: true; repeat: true;
                    onTriggered: dateMain.text = new Date().toLocaleDateString(Qt.locale("en_US"), "dddd, MMMM d")
                }
                Component.onCompleted: text = new Date().toLocaleDateString(Qt.locale("en_US"), "dddd, MMMM d")
            }
        }

        // --- LA ÓRBITA SÓLIDA ---
        Item {
            id: orbitCenter
            width: 10; height: 10
            anchors.centerIn: parent

            property real angleOffset: 0
            NumberAnimation on angleOffset {
                from: 0; to: Math.PI * 2
                duration: 90000
                loops: Animation.Infinite
                running: climaFlotante.visible
            }

            Repeater {
                model: contentLayer.hourlyData.length > 0 ? contentLayer.hourlyData : []

                delegate: Rectangle {
                    id: orbitCard
                    width: 50; height: 80
                    radius: 25

                    // Fondo de tarjeta tintado y semitransparente
                    color: Qt.alpha(root.tema.fondoVariante, 0.8)
                    // Borde de la tarjeta con el color principal
                    border.color: Qt.alpha(root.tema.primario, 0.5); border.width: 1

                    property real angulo: ((index / 8) * Math.PI * 2) + orbitCenter.angleOffset

                    x: (Math.cos(angulo) * 250) - (width / 2)
                    y: (Math.sin(angulo) * 140) - (height / 2)
                    rotation: 0

                    property string horaFormateada: {
                        let h = modelData.time;
                        if (h === "0") return "00:00";
                        if (h.length === 3) return "0" + h.charAt(0) + ":00";
                        if (h.length === 4) return h.substring(0, 2) + ":00";
                        return h;
                    }

                    property var iconData: climaFlotante.getIcon(modelData.weatherCode)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2

                        Text { text: orbitCard.horaFormateada; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 10; font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
                        Item { Layout.fillHeight: true }
                        Text { text: orbitCard.iconData[0]; color: orbitCard.iconData[1]; font.pixelSize: 20; font.family: "FiraCode Nerd Font"; Layout.alignment: Qt.AlignHCenter }
                        Item { Layout.fillHeight: true }
                        Text { text: modelData.tempC + "°"; color: root.tema.textoPrimario; font.pixelSize: 12; font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }
        }
    }
}
