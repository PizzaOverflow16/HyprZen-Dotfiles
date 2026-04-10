import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets // Necesario para recortar la carátula en círculo

Rectangle {
    id: mediaWidget

    property bool menuAbierto: false
    signal toggleMenu()

    // El ancho se adapta a los controles. El height es 30 para coincidir con la batería
    implicitWidth: rowLayout.implicitWidth + 24
    implicitHeight: 30
    radius: 15

    // ✅ Fondo transparente en reposo, color de hover dinámico al activarse
    color: bgMouse.containsMouse || menuAbierto ? root.tema.capsulaHover : "transparent"

    // ✅ Borde iluminado con el color dominante de tu wallpaper
    border.color: root.tema.primario
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }

    property var reproductorActivo: null

    // Buscador del reproductor
    Timer {
        interval: 500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            let lista = Mpris.players.values;
            let tocando = lista.find(p => p.playbackState === MprisPlaybackState.Playing);
            mediaWidget.reproductorActivo = tocando ? tocando : (lista.length > 0 ? lista[0] : null);
        }
    }

    property bool estaSonando: reproductorActivo ? reproductorActivo.playbackState === MprisPlaybackState.Playing : false
    property string urlPortada: reproductorActivo && reproductorActivo.trackArtUrl ? reproductorActivo.trackArtUrl : ""

    // Área para detectar el clic en el fondo y abrir el menú gigante
    MouseArea {
        id: bgMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mediaWidget.toggleMenu()
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 12

        // 1. CARÁTULA EN MINIATURA
        ClippingRectangle {
            width: 22; height: 22
            radius: 11 // Círculo perfecto
            // ✅ Fondo oscuro si no hay portada, usando la variante del tema
            color: root.tema.fondoVariante
            Layout.leftMargin: -2

            Image {
                anchors.fill: parent
                source: mediaWidget.urlPortada
                fillMode: Image.PreserveAspectCrop
                visible: mediaWidget.urlPortada !== ""
            }
            Text {
                anchors.centerIn: parent;
                text: "󰎆";
                // ✅ Ícono genérico al tono del texto si no hay portada
                color: Qt.alpha(root.tema.textoPrimario, 0.5);
                font.pixelSize: 12
                visible: mediaWidget.urlPortada === ""
            }
        }

        // 2. CONTROLES DE AUDIO
        RowLayout {
            spacing: 10

            // Botón Atrás
            Text {
                text: "󰒮"
                // ✅ Texto claro en reposo, color primario al pasar el mouse
                color: prevMouse.containsMouse ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.7)
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 150 } }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent; anchors.margins: -5 // Margen negativo para que sea más fácil hacerle clic
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: if (reproductorActivo) reproductorActivo.previous()
                }
            }

            // Botón Play/Pausa
            Text {
                text: mediaWidget.estaSonando ? "󰏤" : "󰐊"
                // ✅ Botón Play/Pause siempre con el color principal. Al pasar el mouse, usa el secundario para retroalimentación.
                color: playMouse.containsMouse ? root.tema.secundario : root.tema.primario
                font.pixelSize: 18
                Behavior on color { ColorAnimation { duration: 150 } }
                MouseArea {
                    id: playMouse
                    anchors.fill: parent; anchors.margins: -5
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: if (reproductorActivo) reproductorActivo.togglePlaying()
                }
            }

            // Botón Siguiente
            Text {
                text: "󰒭"
                // ✅ Texto claro en reposo, color primario al pasar el mouse
                color: nextMouse.containsMouse ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.7)
                font.pixelSize: 16
                Behavior on color { ColorAnimation { duration: 150 } }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent; anchors.margins: -5
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: if (reproductorActivo) reproductorActivo.next()
                }
            }
        }
    }
}
