import QtQuick
import QtQuick.Layouts

// ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀
// RELOJ QUE SE MUESTRA SOBRE LA BARRA PRINCIPAL (MATUGEN READY)
// ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀

Rectangle {
    id: clockWidget

    signal toggleMenu()
    property bool menuAbierto: false

    implicitHeight: 30
    implicitWidth: clockText.implicitWidth + 30
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: clockMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    property string textoReloj: "Cargando..."

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let d = new Date();
            let h = d.getHours();
            let m = d.getMinutes();
            let ampm = h >= 12 ? "PM" : "AM";
            let h12 = h % 12;
            if (h12 === 0) h12 = 12;

            let hora = h12 + ":" + (m < 10 ? "0" : "") + m + " " + ampm;

            const dias = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"];
            const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
            let fecha = dias[d.getDay()] + ", " + d.getDate() + " " + meses[d.getMonth()];

            clockWidget.textoReloj = fecha + "  |  " + hora;
        }
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: clockWidget.textoReloj
        // ✅ Texto adaptativo para asegurar contraste
        color: root.tema.textoPrimario
        font.pixelSize: 13 // Un pelín más pequeño para que no se vea tosco con el borde
        font.weight: Font.Bold
        font.family: "FiraCode Nerd Font" // Homologamos con el resto de la barra
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clockWidget.toggleMenu()
    }
}
