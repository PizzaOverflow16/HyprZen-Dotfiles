import QtQuick
import QtQuick.Layouts

Rectangle {
    id: polycatWidget
    width: 40; height: 30; radius: 15
    color: "transparent"

    property string frameActual: "" // Frame por defecto

    // Timer de alta velocidad (30ms para que la animación sea fluida)
    Timer {
        interval: 33
        running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_polycat.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200 || xhr.status === 0) {
                polycatWidget.frameActual = xhr.responseText.trim();
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: polycatWidget.frameActual

        // ✅ OPCIÓN RECOMENDADA: Color Primario de Matugen
        // Resalta sobre fondos oscuros y mantiene la armonía con tu barra
        color: root.tema.primario

        // Si prefieres que resalte aún más, podrías usar root.tema.textoPrimario
        // pero el primario le da ese toque "neon" muy cool.

        font.pixelSize: 30
        font.family: "polycat"

        Behavior on color { ColorAnimation { duration: 300 } }
    }
}
