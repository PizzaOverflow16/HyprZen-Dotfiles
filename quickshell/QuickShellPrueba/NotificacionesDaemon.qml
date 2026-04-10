import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: notifWindow
    anchors { top: true; right: true }
    margins { top: 60; right: 20 }
    implicitWidth: 360; implicitHeight: 1000
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-notifications-popups"
    mask: Region { item: mainLayout }

    ColumnLayout {
        id: mainLayout
        width: 360
        spacing: 15

        Repeater {
            // LEE DEL MOTOR
            model: root.motorNotificaciones ? root.motorNotificaciones.popups : []

            delegate: Rectangle {
                id: notifCard
                Layout.fillWidth: true
                implicitHeight: contentCol.implicitHeight + 30
                radius: 15

                property int urgencia: modelData ? modelData.urgency : 1

                color: urgencia === 2 ? "#311B22" : Qt.alpha(root.tema.barraFondo, 0.85)
                border.color: urgencia === 2 ? "#F38BA8" : Qt.alpha(root.tema.primario, 0.5)
                border.width: 2; clip: true

                opacity: 0; scale: 0.8
                Component.onCompleted: { entranceAnim.start(); autoCloseTimer.start() }

                ParallelAnimation {
                    id: entranceAnim
                    NumberAnimation { target: notifCard; property: "opacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
                    NumberAnimation { target: notifCard; property: "scale"; to: 1; duration: 300; easing.type: Easing.OutBack }
                }

                ParallelAnimation {
                    id: exitAnim
                    NumberAnimation { target: notifCard; property: "opacity"; to: 0; duration: 250; easing.type: Easing.InCubic }
                    NumberAnimation { target: notifCard; property: "x"; to: 400; duration: 250; easing.type: Easing.InBack }
                    // 👇 IMPORTANTE: Pasamos el .id aquí
                    onFinished: root.motorNotificaciones.eliminarPopup(modelData.id)
                }

                Timer {
                    id: autoCloseTimer
                    interval: urgencia === 2 ? 15000 : 5000
                    onTriggered: exitAnim.start()
                }

                // 👇 MOUSEAREA PARA ABRIR LA APP
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: autoCloseTimer.stop()
                    onExited: autoCloseTimer.start()

                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData) {
                            // 1. Intentamos el método oficial de D-Bus por si acaso
                            try {
                                if (typeof modelData.invokeDefaultAction === "function") modelData.invokeDefaultAction();
                                else if (typeof modelData.invoke === "function") modelData.invoke("default");
                            } catch(e) {}

                            // 2. 🚀 EL PLAN B: ABRIR A LA FUERZA SEGÚN LA APP
                            let app = modelData.appName ? modelData.appName.toLowerCase() : "";

                            if (app === "zapzap" || app === "whatsapp") {
                                Quickshell.execDetached(["sh", "-c", "zapzap"]);
                            }
                            else if (app === "hyprshot") {
                                // 1. Obtenemos todo lo que Hyprshot nos mandó
                                let cuerpo = modelData.body ? modelData.body : "";
                                let img = modelData.image ? modelData.image.toString().replace("file://", "") : "";
                                let icono = modelData.appIcon ? modelData.appIcon.toString().replace("file://", "") : "";

                                // 2. Usamos una "RegEx" para atrapar la ruta exacta de tu captura
                                let regex = /(\/home\/elton\/Imágenes\/[^\s"']+\.png)/;
                                let match = cuerpo.match(regex);

                                let rutaExacta = "";
                                if (match) rutaExacta = match[1];
                                else if (img.includes("/home/elton/Imágenes/")) rutaExacta = img;
                                else if (icono.includes("/home/elton/Imágenes/")) rutaExacta = icono;

                                // 3. Abrimos la imagen o la carpeta
                                if (rutaExacta !== "") {
                                    Quickshell.execDetached(["sh", "-c", 'xdg-open "' + rutaExacta + '"']);
                                } else {
                                    Quickshell.execDetached(["sh", "-c", "xdg-open /home/elton/Imágenes"]);
                                }
                            }
                            else if (app === "discord") {
                                Quickshell.execDetached(["sh", "-c", "discord"]);
                            }
                            else if (app === "telegram") {
                                Quickshell.execDetached(["sh", "-c", "telegram-desktop"]);
                            }
                            // ¡Puedes ir agregando más apps a esta lista según las necesites!

                            // 3. Escondemos la tarjeta gráficamente
                            if (typeof card !== "undefined") card.opacity = 0;
                            if (typeof notifCard !== "undefined") notifCard.opacity = 0;

                            // 4. Borramos la notificación usando tu motor
                            Qt.callLater(() => { root.motorNotificaciones.eliminarDelHistorial(modelData.id) });

                            // 5. Cerramos el menú lateral para que veas la app (solo en el centro flotante)
                            if (typeof centroFlotante !== "undefined") centroFlotante.abrirMenu("");
                        }
                    }
                }

                ColumnLayout {
                    id: contentCol
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 15 }
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "󰂚"; color: urgencia === 2 ? "#F38BA8" : root.tema.primario; font.pixelSize: 14 }
                        Text {
                            text: (modelData && modelData.appName !== "") ? modelData.appName : "Sistema";
                            color: urgencia === 2 ? "#F38BA8" : Qt.alpha(root.tema.textoPrimario, 0.8);
                            font.pixelSize: 12; font.weight: Font.Bold; Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 20; height: 20; radius: 10
                            color: closeMa.containsMouse ? (urgencia === 2 ? "#F38BA8" : root.tema.capsulaHover) : "transparent"
                            Text {
                                anchors.centerIn: parent; text: "󰅖";
                                color: closeMa.containsMouse && urgencia === 2 ? "#1E1E2E" : Qt.alpha(root.tema.textoPrimario, 0.6);
                                font.pixelSize: 14
                            }
                            MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: exitAnim.start() }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12; Layout.alignment: Qt.AlignTop
                        Rectangle {
                            property string rutaIcono: root.motorNotificaciones.obtenerIcono(modelData)
                            visible: rutaIcono !== ""
                            width: 50; height: 50; radius: 10; color: "transparent"; clip: true
                            Image { anchors.fill: parent; source: parent.rutaIcono; fillMode: Image.PreserveAspectCrop }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 4
                            Text {
                                text: modelData ? modelData.summary : "";
                                color: urgencia === 2 ? "#F38BA8" : root.tema.textoPrimario;
                                font.pixelSize: 15; font.weight: Font.Bold; Layout.fillWidth: true; wrapMode: Text.Wrap
                            }
                            Text {
                                property string txt: modelData ? modelData.body : ""
                                text: txt.length > 120 ? txt.substr(0, 117) + "..." : txt
                                color: urgencia === 2 ? "#eba0ac" : Qt.alpha(root.tema.textoPrimario, 0.9);
                                font.pixelSize: 13; Layout.fillWidth: true; wrapMode: Text.Wrap; visible: txt !== ""
                            }
                        }
                    }
                }
            }
        }
    }
}
