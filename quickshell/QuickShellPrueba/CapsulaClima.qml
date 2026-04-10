import QtQuick
import QtQuick.Layouts

Rectangle {
    id: weatherCapsule
    signal toggleMenu()
    property bool menuAbierto: false

    property string temp: "--°"
    property string icon: "󰖐"

    implicitHeight: 30
    implicitWidth: layoutClima.implicitWidth + 24
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: controlMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

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
                        weatherCapsule.temp = current.temp_C + "°";

                        let code = current.weatherCode;
                        if (code === "113") { weatherCapsule.icon = "󰖙"; }
                        else if (code === "116") { weatherCapsule.icon = "󰖕"; }
                        else if (code === "119" || code === "122") { weatherCapsule.icon = "󰖐"; }
                        else if (code === "353" || code === "356" || code === "359" || code === "293" || code === "296" || code === "299" || code === "302" || code === "305" || code === "308") { weatherCapsule.icon = "󰖗"; }
                        else if (code === "386" || code === "389" || code === "392" || code === "395") { weatherCapsule.icon = "󰖓"; }
                        else { weatherCapsule.icon = "󰖐"; }
                    } catch(e) {}
                }
            }
            xhr.send();
        }
    }

    RowLayout {
        id: layoutClima
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: weatherCapsule.icon
            // ✅ Ícono con el color principal de Matugen
            color: root.tema.primario
            font.pixelSize: 18
            font.family: "FiraCode Nerd Font"
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Text {
            text: weatherCapsule.temp
            // ✅ Texto que se adapta para siempre hacer contraste
            color: root.tema.textoPrimario
            font.pixelSize: 13
            font.weight: Font.Bold
            font.family: "FiraCode Nerd Font"
        }
    }

    MouseArea {
        id: controlMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: weatherCapsule.toggleMenu()
    }
}
