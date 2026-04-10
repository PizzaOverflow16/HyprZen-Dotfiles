import QtQuick
import Quickshell
import Qt.labs.folderlistmodel

Scope {
    id: galeriaScope // ✅ ¡El gran fix! Ya no choca con el 'root' global
    property bool activa: false

    PanelWindow {
        id: galleryWindow

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Ventana transparente segura
        color: "transparent"
        visible: galeriaScope.activa
        focusable: visible

        // Cristal oscuro que ahora SÍ leerá el color correctamente
        Rectangle {
            anchors.fill: parent
            color: root.tema.barraFondo // Como ya no somos root, ahora sí lee el root global
            opacity: 0.85
        }

        readonly property real skewFactor: -0.35
        readonly property int itemWidth: 280
        readonly property int itemHeight: 450

        // Atajos de teclado (actualizados con galeriaScope)
        Shortcut { enabled: galleryWindow.visible; sequence: "Left"; onActivated: view.decrementCurrentIndex() }
        Shortcut { enabled: galleryWindow.visible; sequence: "Right"; onActivated: view.incrementCurrentIndex() }
        Shortcut { enabled: galleryWindow.visible; sequence: "Return"; onActivated: galleryWindow.applyWallpaper(view.currentItem.fileData) }
        Shortcut { enabled: galleryWindow.visible; sequence: "Escape"; onActivated: galeriaScope.activa = false }

        FolderListModel {
            id: wallModel
            folder: "file:///home/elton/dev/config/dotfiles/Wallpapers"
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.mp4", "*.webm", "*.mkv"]
            showDirs: false
        }

        ListView {
            id: view
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 50
            }
            height: galleryWindow.itemHeight + 60
            orientation: ListView.Horizontal
            spacing: 30
            model: wallModel
            clip: false
            focus: true

            snapMode: ListView.SnapToItem
            highlightMoveDuration: 250
            highlightMoveVelocity: -1
            cacheBuffer: 5000

            Behavior on contentX {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                width: galleryWindow.itemWidth
                height: galleryWindow.itemHeight

                property string fileStr: fileUrl.toString()
                property bool isVideo: fileStr.match(/\.(mp4|webm|mkv)$/i) !== null

                property string baseName: {
                    let parts = fileStr.split('/');
                    let name = parts[parts.length - 1];
                    return name.substring(0, name.lastIndexOf('.'));
                }

                property string thumbUrl: isVideo
                ? "file:///home/elton/dev/config/dotfiles/Wallpapers/.thumbnails/" + baseName + ".jpg"
                : fileUrl

                property string fileData: fileUrl

                Item {
                    anchors.fill: parent

                    transform: Matrix4x4 {
                        property real s: galleryWindow.skewFactor
                        matrix: Qt.matrix4x4(1, s, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: root.tema.fondoVariante
                        border.color: view.currentIndex === index ? root.tema.primario : "transparent"
                        border.width: 4
                        clip: true
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        Image {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: -78
                            width: 600; height: 500; scale: 1.3
                            source: thumbUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize: Qt.size(600, 500)

                            transform: Matrix4x4 {
                                property real s: -galleryWindow.skewFactor
                                matrix: Qt.matrix4x4(1, s, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                            }
                        }

                        Text {
                            visible: isVideo
                            text: "󰕧"
                            anchors { bottom: parent.bottom; right: parent.right; margins: 10 }
                            color: root.tema.primario
                            font.pixelSize: 20
                            style: Text.Outline; styleColor: "#11111B"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: view.currentIndex = index
                    onClicked: {
                        view.currentIndex = index;
                        galleryWindow.applyWallpaper(fileUrl);
                    }
                }
            }
        }

        function applyWallpaper(url) {
            if (!url) return;
            let cleanPath = url.toString().replace("file://", "");
            // ✅ 1. LE AVISAMOS AL SISTEMA EL NUEVO FONDO
            root.wallpaperActual = url.toString();
            Quickshell.execDetached(["bash", "/home/elton/dev/config/dotfiles/scripts/wall-switcher.sh", cleanPath]);
            galeriaScope.activa = false; // ✅ Actualizado aquí también
        }
    }
}
