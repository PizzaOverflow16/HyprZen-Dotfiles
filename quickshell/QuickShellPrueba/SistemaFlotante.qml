import QtQuick
import QtQuick.Layouts

Rectangle {
    id: sysWidget
    property string menuActivo: ""

    width: 380; height: 430
    radius: 15

    // ✅ Estilo Frost con fondo translúcido y borde reactivo
    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "sistema" ? 1 : 0
    y: menuActivo === "sistema" ? 10 : -20
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    property real cpuPorcentaje: 0
    property real ramPorcentaje: 0
    property real discoPorcentaje: 0
    property real tempGrados: 0

    // ==========================================
    // EL LECTOR JAVASCRIPT
    // ==========================================
    function leerSensores() {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///tmp/qs_sys.txt?nocache=" + new Date().getTime(), false);
        xhr.send(null);

        if (xhr.status === 200 || xhr.status === 0) {
            let info = xhr.responseText.trim().split("|");
            if (info.length >= 4) {
                sysWidget.cpuPorcentaje = parseFloat(info[0]) || 0;
                sysWidget.ramPorcentaje = parseFloat(info[1]) || 0;
                sysWidget.discoPorcentaje = parseFloat(info[2]) || 0;
                sysWidget.tempGrados = parseFloat(info[3]) || 0;
            }
        }
    }

    Timer {
        interval: 1500; running: sysWidget.visible; repeat: true; triggeredOnStart: true
        onTriggered: leerSensores()
    }

    // ==========================================
    // DISEÑO DE LA INTERFAZ
    // ==========================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        RowLayout {
            spacing: 15
            // ✅ Logo de EndeavourOS tintado con el color primario
            Text { text: ""; color: root.tema.primario; font.pixelSize: 48 }
            ColumnLayout {
                spacing: 2
                Text { text: "EndeavourOS"; color: root.tema.textoPrimario; font.pixelSize: 18; font.weight: Font.Bold }
                Text { text: "Ryzen 5 7520U"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 12 }
                Text { text: "Kernel: 6.19.8-arch1-1"; color: Qt.alpha(root.tema.textoPrimario, 0.4); font.pixelSize: 10 }
            }
        }

        // ✅ Separador suave
        Rectangle { Layout.fillWidth: true; height: 2; color: Qt.alpha(root.tema.textoPrimario, 0.1); radius: 1 }

        // --- MÓDULO: CPU ---
        ColumnLayout {
            spacing: 8
            RowLayout {
                Text { text: "CPU"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 14; font.weight: Font.Bold }
                Item { Layout.fillWidth: true }
                Text { text: Math.round(sysWidget.cpuPorcentaje) + "%"; color: root.tema.textoPrimario; font.pixelSize: 14 }
            }
            Rectangle {
                Layout.fillWidth: true; height: 12; radius: 6; color: root.tema.fondoVariante
                Rectangle {
                    width: Math.max(parent.width * (sysWidget.cpuPorcentaje / 100), 12); height: parent.height; radius: 6;
                    // ✅ CPU usa color Primario
                    color: root.tema.primario
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuint } }
                }
            }
        }

        // --- MÓDULO: RAM ---
        ColumnLayout {
            spacing: 8
            RowLayout {
                Text { text: "RAM (16 GiB)"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 14; font.weight: Font.Bold }
                Item { Layout.fillWidth: true }
                Text { text: Math.round(sysWidget.ramPorcentaje) + "%"; color: root.tema.textoPrimario; font.pixelSize: 14 }
            }
            Rectangle {
                Layout.fillWidth: true; height: 12; radius: 6; color: root.tema.fondoVariante
                Rectangle {
                    width: Math.max(parent.width * (sysWidget.ramPorcentaje / 100), 12); height: parent.height; radius: 6;
                    // ✅ RAM usa color Secundario
                    color: root.tema.secundario
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuint } }
                }
            }
        }

        // --- MÓDULO: TEMPERATURA ---
        ColumnLayout {
            spacing: 8
            RowLayout {
                Text { text: "Temperatura"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 14; font.weight: Font.Bold }
                Item { Layout.fillWidth: true }
                Text { text: Math.round(sysWidget.tempGrados) + "°C"; color: root.tema.textoPrimario; font.pixelSize: 14 }
            }
            Rectangle {
                Layout.fillWidth: true; height: 12; radius: 6; color: root.tema.fondoVariante
                Rectangle {
                    width: Math.max(parent.width * (sysWidget.tempGrados / 100), 12); height: parent.height; radius: 6
                    // ✅ Híbrido: Primario si está fresco, alertas si calienta
                    color: sysWidget.tempGrados > 85 ? "#F38BA8" : (sysWidget.tempGrados > 70 ? "#F9E2AF" : root.tema.primario)
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuint } }
                }
            }
        }

        // --- MÓDULO: DISCO ---
        ColumnLayout {
            spacing: 8
            RowLayout {
                Text { text: "Almacenamiento (Raíz)"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 14; font.weight: Font.Bold }
                Item { Layout.fillWidth: true }
                Text { text: Math.round(sysWidget.discoPorcentaje) + "%"; color: root.tema.textoPrimario; font.pixelSize: 14 }
            }
            Rectangle {
                Layout.fillWidth: true; height: 12; radius: 6; color: root.tema.fondoVariante
                Rectangle {
                    width: Math.max(parent.width * (sysWidget.discoPorcentaje / 100), 12); height: parent.height; radius: 6;
                    // ✅ Disco usa color Secundario
                    color: root.tema.secundario
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuint } }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    MouseArea { anchors.fill: parent }
}
