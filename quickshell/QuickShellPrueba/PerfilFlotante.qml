import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt.labs.folderlistmodel

Rectangle {
    id: perfilCajon
    property string menuActivo: ""
    property bool mostrarGaleria: false

    width: 320
    height: 130 + (mostrarGaleria ? (gridContainer.height + 20) : 0)
    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

    radius: 15
    clip: true

    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "perfil" ? 1 : 0
    y: menuActivo === "perfil" ? 10 : -20
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    onOpacityChanged: { if (opacity === 0) mostrarGaleria = false; }

    MouseArea { anchors.fill: parent }

    FolderListModel {
        id: pfpModel
        folder: "file:///home/elton/dev/config/dotfiles/imagenes_usuarios"
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
    }

    property string uptimeTexto: "Calculando..."

    Timer {
        interval: 60000; running: perfilCajon.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "file:///proc/uptime?nocache=" + new Date().getTime(), false);
            xhr.send(null);
            if (xhr.status === 200 || xhr.status === 0) {
                let info = xhr.responseText.trim().split(" ");
                let totalSegundos = parseFloat(info[0]);
                let horas = Math.floor(totalSegundos / 3600);
                let minutos = Math.floor((totalSegundos % 3600) / 60);
                perfilCajon.uptimeTexto = "up " + horas + "h, " + minutos + "m";
            }
        }
    }

    ColumnLayout {
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
        spacing: 20

        // --- 1. CABECERA DEL PERFIL ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            ClippingRectangle {
                width: 90; height: 90
                radius: 45
                color: root.tema.fondoVariante

                Image {
                    anchors.fill: parent
                    // ✅ AHORA SÍ: La foto PRINCIPAL lee la global
                    source: root.fotoPerfilActual
                    fillMode: Image.PreserveAspectCrop
                    smooth: true; mipmap: true
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 45; color: "transparent"
                    border.color: root.tema.primario
                    border.width: btnFoto.containsMouse ? 3 : 0
                    Behavior on border.width { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    id: btnFoto
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: perfilCajon.mostrarGaleria = !perfilCajon.mostrarGaleria
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                RowLayout {
                    spacing: 8
                    Text { text: ""; color: root.tema.primario; font.pixelSize: 16 }
                    Text { text: ": EndeavourOS"; color: root.tema.textoPrimario; font.pixelSize: 16; font.weight: Font.Medium }
                }
                RowLayout {
                    spacing: 8
                    Text { text: ""; color: root.tema.secundario; font.pixelSize: 16 }
                    Text { text: ": Hyprland"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 16; font.weight: Font.Medium }
                }
                RowLayout {
                    spacing: 8
                    Text { text: "󰅐"; color: root.tema.secundario; font.pixelSize: 16 }
                    Text { text: ": " + perfilCajon.uptimeTexto; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 14 }
                }
            }
        }

        // --- 2. GRILLA DE IMÁGENES ---
        Item {
            id: gridContainer
            Layout.fillWidth: true

            property int filasReales: Math.ceil(grid.count / 2.0)
            property int filasVisibles: grid.count === 0 ? 1 : Math.min(filasReales, 3)

            height: filasVisibles * 130

            visible: perfilCajon.mostrarGaleria
            opacity: perfilCajon.mostrarGaleria ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            GridView {
                id: grid
                anchors.fill: parent
                model: pfpModel
                clip: true

                cellWidth: 140
                cellHeight: 130

                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    ClippingRectangle {
                        anchors.centerIn: parent
                        width: 115; height: 115
                        radius: 25
                        color: root.tema.fondoVariante

                        Image {
                            anchors.fill: parent
                            // ✅ FIX: Aquí cada cuadrito lee SU propia foto de la carpeta, NO la global
                            source: fileUrl
                            fillMode: Image.PreserveAspectCrop
                            smooth: true; mipmap: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 25; color: "transparent"
                            border.color: root.tema.primario
                            border.width: root.fotoPerfilActual === fileUrl.toString() ? 4 : 0
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // ✅ Guardamos la elegida en la global
                                root.fotoPerfilActual = fileUrl.toString();
                                perfilCajon.mostrarGaleria = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
