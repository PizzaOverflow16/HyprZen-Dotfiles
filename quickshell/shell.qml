import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris

PanelWindow {
    id: mediaControlWindow
    color: "transparent"
    
    // Tamaños exactos de tu Hyprlock
    implicitWidth: 500
    implicitHeight: 140

    anchors {
        top: true
        left: true
    }

    margins {
        top: 10
        left: 10
    }

    property var playerList: Mpris.players.values || []
    property var player: playerList.length > 0 ? playerList[0] : null

    // --- EL MOTOR DE LA BARRA (Equivalente a tu update:1000) ---
    property real currentPos: 0
    Timer {
        interval: 1000
        running: player != null
        repeat: true
        onTriggered: {
            if (player) currentPos = player.position
        }
    }

    // Fondo estilo Hyprlock
    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Qt.rgba(30/255, 30/255, 46/255, 0.9)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Carátula del Álbum
            Rectangle {
                width: 100
                height: 100
                radius: 5
                border.width: 3
                border.color: Qt.rgba(216/255, 222/255, 233/255, 0.70)
                color: "transparent"
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 3 
                    source: player && player.trackArtUrl ? player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    
                    Text {
                        anchors.centerIn: parent
                        visible: parent.status !== Image.Ready
                        text: "🎵"
                        font.pixelSize: 32
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 5

                // Título e Ícono de Artista
                Text {
                    text: player && player.trackTitle ? player.trackTitle : "Sin reproducción"
                    color: Qt.rgba(216/255, 222/255, 233/255, 0.9)
                    font.pixelSize: 16
                    font.family: "SF Pro Display"
                    font.weight: Font.Black
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰠃  " + (player && player.trackArtist ? player.trackArtist : "Artista desconocido")
                    color: Qt.rgba(216/255, 222/255, 233/255, 0.70)
                    font.pixelSize: 12
                    font.family: "SF Pro Display"
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Controles de Reproducción
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    Button {
                        text: "󰒮"
                        onClicked: if(player) player.previous()
                        background: Rectangle { color: "transparent" }
                        contentItem: Text { text: parent.text; color: Qt.rgba(216/255, 222/255, 233/255, 0.9); font.pixelSize: 25; font.family: "SF Pro Display" }
                    }

                    Button {
                        text: player && player.isPlaying ? "⏸" : "▶"
                        onClicked: if(player) player.togglePlaying()
                        background: Rectangle { color: "transparent" }
                        contentItem: Text { text: parent.text; color: Qt.rgba(216/255, 222/255, 233/255, 0.9); font.pixelSize: 25; font.family: "SF Pro Display" }
                    }

                    Button {
                        text: "󰒭"
                        onClicked: if(player) player.next()
                        background: Rectangle { color: "transparent" }
                        contentItem: Text { text: parent.text; color: Qt.rgba(216/255, 222/255, 233/255, 0.9); font.pixelSize: 25; font.family: "SF Pro Display" }
                    }
                }

                // Barra de progreso y tiempos
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: formatTime(currentPos)
                        color: Qt.rgba(216/255, 222/255, 233/255, 0.70)
                        font.pixelSize: 10
                        font.family: "SF Pro Display"
                        font.weight: Font.Medium
                    }

                    Slider {
                        id: progressSlider
                        Layout.fillWidth: true
                        from: 0
                        to: player && player.length ? player.length : 1
                        value: currentPos
                        
                        // Si quieres que la barra funcione para adelantar la canción, descomenta la línea de abajo:
                        // onMoved: if(player) player.position = value

                        background: Rectangle {
                            x: progressSlider.leftPadding
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            width: progressSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Qt.rgba(216/255, 222/255, 233/255, 0.2)

                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: Qt.rgba(216/255, 222/255, 233/255, 0.70)
                                radius: 2
                            }
                        }
                        
                        handle: Rectangle {
                            x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            width: 10
                            height: 10
                            radius: 5
                            color: Qt.rgba(216/255, 222/255, 233/255, 0.9)
                        }
                    }

                    Text {
                        text: formatTime(player && player.length ? player.length : 0)
                        color: Qt.rgba(216/255, 222/255, 233/255, 0.70)
                        font.pixelSize: 10
                        font.family: "SF Pro Display"
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
