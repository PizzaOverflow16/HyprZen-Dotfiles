import QtQuick
import QtQuick.Layouts

Rectangle {
    id: windowWidget

    // ✅ Estética unificada: cápsula translúcida con borde iluminado
    implicitWidth: rowLayout.implicitWidth + 30
    implicitHeight: 30
    radius: 15

    // Fondo transparente para seguir el estilo de la barra
    color: "transparent"

    // ✅ Borde sutil que brilla con tu color primario
    border.color: Qt.alpha(root.tema.primario, 0.4)
    border.width: 1

    property string claseCruda: "Escritorio"

    // Timer para leer el archivo temporal
    Timer {
        interval: 100
        running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///tmp/qs_window.txt?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200 || xhr.status === 0) {
                windowWidget.claseCruda = xhr.responseText.trim();
            }
        }
    }

    // El diccionario inteligente
    function nombreBonito(clase) {
        if (!clase || clase === "Escritorio") return "Escritorio";
        let c = clase.toLowerCase();
        let mapa = {
            "firefox": "Firefox",
            "kitty": "Kitty",
            "alacritty": "Alacritty",
            "code": "VS Code",
            "code-oss": "VS Code",
            "spotify": "Spotify",
            "discord": "Discord",
            "thunar": "Archivos",
            "nemo": "Archivos",
            "dolphin": "Archivos",
            "steam": "Steam",
            "vlc": "VLC",
            "obsidian": "Obsidian",
            "org.kde.dolphin": "Dolphin",
            "org.gnome.nautilus": "Nautilus",
            "org.kde.kate": "Kate",
        };

        if (mapa[c]) return mapa[c];
        return c.charAt(0).toUpperCase() + c.slice(1);
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8

        // ✅ Ícono de Ventana con color secundario para contraste
        Text {
            text: ""
            color: root.tema.secundario
            font.pixelSize: 14

            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Text {
            text: windowWidget.nombreBonito(windowWidget.claseCruda)
            // ✅ Texto con color primario adaptativo
            color: root.tema.textoPrimario
            font.pixelSize: 13
            font.weight: Font.Medium
            font.family: "FiraCode Nerd Font"

            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }
}
