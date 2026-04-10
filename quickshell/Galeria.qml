import QtQuick
import Quickshell
import Qt.labs.folderlistmodel

PanelWindow {
    id: galleryWindow
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#CC000000"

    // Permiso explícito de Wayland para secuestrar el teclado
    focusable: true

    readonly property real skewFactor: -0.35
    readonly property int itemWidth: 280
    readonly property int itemHeight: 450

    Shortcut { sequence: "Left"; onActivated: view.decrementCurrentIndex() }
    Shortcut { sequence: "Right"; onActivated: view.incrementCurrentIndex() }
    Shortcut { sequence: "Return"; onActivated: galleryWindow.applyWallpaper(view.currentItem.fileData) }
    Shortcut { sequence: "Enter"; onActivated: galleryWindow.applyWallpaper(view.currentItem.fileData) }
    Shortcut { sequence: "Escape"; onActivated: Qt.quit() }

    FolderListModel {
        id: wallModel
        folder: "file:///home/elton/dev/config/dotfiles/Wallpapers"
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.mp4", "*.webm", "*.mkv"]
        showDirs: false

        // Buscador automático del fondo actual
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                let fondoActual = Quickshell.env("FONDO");
                if (fondoActual) {
                    for (let i = 0; i < count; i++) {
                        let ruta = get(i, "fileUrl").toString().replace("file://", "");
                        if (ruta === fondoActual) {
                            view.currentIndex = i;
                            view.positionViewAtIndex(i, ListView.Center);
                            break;
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: view
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: galleryWindow.itemHeight + 60

        anchors.margins: 50
        orientation: ListView.Horizontal
        spacing: 30
        model: wallModel
        clip: false
        focus: true

        // Fluidez y rendimiento de CPU/RAM
        cacheBuffer: 2500
        highlightMoveDuration: 250
        highlightMoveVelocity: -1

        Behavior on contentX {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        delegate: Item {
            width: galleryWindow.itemWidth
            height: galleryWindow.itemHeight

            property string fileData: fileUrl

            // Lógica declarativa pura para el enrutamiento de miniaturas de video
            property string fileStr: fileUrl.toString()
            property bool isVideo: fileStr.match(/\.(mp4|webm|mkv)$/i) !== null

            property string fileName: fileStr.substring(fileStr.lastIndexOf("/") + 1)
            property string baseName: fileName.substring(0, fileName.lastIndexOf("."))
            property string folderPath: fileStr.substring(0, fileStr.lastIndexOf("/"))

            // Operador ternario legal en QML
            property string thumbUrl: isVideo ? (folderPath + "/.thumbnails/" + baseName + ".jpg") : fileStr

            Item {
                anchors.fill: parent

                transform: Matrix4x4 {
                    property real s: galleryWindow.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: view.currentIndex === index ? "#FFFFFF" : "transparent"
                    border.width: view.currentIndex === index ? 4 : 0
                    clip: true

                    Image {
                        anchors.centerIn: parent
                        // Corrección matemática para que cubra la esquina izquierda
                        anchors.horizontalCenterOffset: -78
                        width: 600
                        height: 500
                        scale: 1.3

                        source: thumbUrl

                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(600, 500)

                        transform: Matrix4x4 {
                            property real s: -galleryWindow.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
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
        let cmd = "bash /home/elton/dev/config/dotfiles/scripts/wall-switcher.sh '" + cleanPath + "'";

        Quickshell.execDetached(["bash", "-c", cmd]);
        Qt.quit();
    }
}
