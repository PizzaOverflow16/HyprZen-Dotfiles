import QtQuick
import Quickshell
import Qt.labs.folderlistmodel

PanelWindow {
    id: galleryWindow
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#CC000000"

    readonly property real skewFactor: -0.35
    readonly property int itemWidth: 280
    readonly property int itemHeight: 450

    // --- FIX 1: Botón invisible para robarle el foco a la terminal ---
    MouseArea {
        anchors.fill: parent
        onClicked: view.forceActiveFocus()
    }

    FolderListModel {
        id: wallModel
        folder: "file:///home/elton/dev/config/dotfiles/Wallpapers"
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
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
        Component.onCompleted: forceActiveFocus()

        // --- FIX 2: Mapeo explícito de flechas ---
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()

        Keys.onReturnPressed: galleryWindow.applyWallpaper(currentItem.fileData)
        Keys.onEnterPressed: galleryWindow.applyWallpaper(currentItem.fileData)
        Keys.onEscapePressed: Qt.quit()

        delegate: Item {
            width: galleryWindow.itemWidth
            height: galleryWindow.itemHeight

            property string fileData: fileUrl

            Item {
                anchors.fill: parent

                transform: Matrix4x4 {
                    property real s: galleryWindow.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#202020"
                    border.color: view.currentIndex === index ? "#FFFFFF" : "transparent"
                    border.width: view.currentIndex === index ? 4 : 0
                    clip: true

                    Image {
                        anchors.centerIn: parent
                        // --- FIX 3: El doble de ancho para aniquilar el gris por completo ---
                        width: parent.width * 2.0
                        height: parent.height * 1.5

                        source: fileUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(600, 700)

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

        // Ejecutamos tu script maestro pasándole la ruta del archivo
        let cmd = "bash /home/elton/dev/config/dotfiles/scripts/wall-switcher.sh '" + cleanPath + "'";

        Quickshell.execDetached(["bash", "-c", cmd]);
        Qt.quit();
    }
}
