import QtQuick
import Quickshell
import Qt.labs.folderlistmodel

PanelWindow {
    id: galleryWindow
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#CC000000"

    // --- FIX 1: Permiso explícito de Wayland para secuestrar el teclado ---
    focusable: true

    readonly property real skewFactor: -0.35
    readonly property int itemWidth: 280
    readonly property int itemHeight: 450

    Shortcut { sequence: "Left"; onActivated: view.decrementCurrentIndex() }
    Shortcut { sequence: "Right"; onActivated: view.incrementCurrentIndex() }
    Shortcut { sequence: "Return"; onActivated: galleryWindow.applyWallpaper(view.currentItem.fileData) }
    Shortcut { sequence: "Enter"; onActivated: galleryWindow.applyWallpaper(view.currentItem.fileData) }
    Shortcut { sequence: "Escape"; onActivated: Qt.quit() } // Se cierra sola si te arrepientes

    FolderListModel {
        id: wallModel
        folder: "file:///home/elton/dev/config/dotfiles/Wallpapers"
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false

        // --- EL BUSCADOR AUTOMÁTICO ---
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                let fondoActual = Quickshell.env("FONDO");
                if (fondoActual) {
                    // Recorre la lista buscando la ruta exacta
                    for (let i = 0; i < count; i++) {
                        let ruta = get(i, "fileUrl").toString().replace("file://", "");
                        if (ruta === fondoActual) {
                            view.currentIndex = i; // Selecciona el marco blanco
                            view.positionViewAtIndex(i, ListView.Center); // Salta directo a esa posición
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

        // --- EL SECRETO DE LA FLUIDEZ ---
        // Le dice al motor que dibuje 2500 píxeles a la izquierda y derecha
        // ANTES de que los veas. Así el procesador no trabaja bajo presión.
        cacheBuffer: 2500

        // --- MOVIMIENTO CINEMÁTICO ---
        highlightMoveDuration: 250
        highlightMoveVelocity: -1

        // Freno suave
        Behavior on contentX {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

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
                    color: "transparent"
                    border.color: view.currentIndex === index ? "#FFFFFF" : "transparent"
                    border.width: view.currentIndex === index ? 4 : 0
                    clip: true

                    Image {
                        anchors.centerIn: parent

                        // --- FIX 2: Corrección matemática del centro de masa ---
                        anchors.horizontalCenterOffset: -78
                        width: 600
                        height: 500

                        source: fileUrl
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
