import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import QtQuick.Effects

Rectangle {
    id: centroFlotante
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    width: 400; height: 850
    radius: 24

    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde;
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "notificaciones" ? 1 : 0
    x: menuActivo === "notificaciones" ? parent.width - width - 20 : parent.width + 50
    y: 80
    Behavior on opacity { NumberAnimation { duration: 250 } }
    Behavior on x { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }

    property int mesActual: new Date().getMonth()
    property int anioActual: new Date().getFullYear()

    function cambiarMes(delta) {
        let nuevoMes = mesActual + delta;
        if (nuevoMes > 11) {
            mesActual = 0; anioActual++;
        } else if (nuevoMes < 0) {
            mesActual = 11; anioActual--;
        } else {
            mesActual = nuevoMes;
        }
    }

    MouseArea { anchors.fill: parent }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 5

            Text {
                text: "Notificaciones"
                color: root.tema.textoPrimario; font.pixelSize: 18; font.weight: Font.Bold; Layout.fillWidth: true
            }

            Rectangle {
                id: rectSnooze
                width: 32; height: 32; radius: 8
                property bool silenciado: root.motorNotificaciones ? root.motorNotificaciones.modoSilencioso : false
                color: silenciado ? "#F38BA8" : (btnSnooze.containsMouse ? root.tema.capsulaHover : root.tema.fondoVariante)
                Behavior on color { ColorAnimation { duration: 200 } }

                Text {
                    anchors.centerIn: parent
                    text: rectSnooze.silenciado ? "󰂛" : "󰂚"
                    color: rectSnooze.silenciado ? "#11111B" : root.tema.textoPrimario
                    font.pixelSize: 16
                }
                MouseArea {
                    id: btnSnooze
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.motorNotificaciones) {
                            root.motorNotificaciones.modoSilencioso = !root.motorNotificaciones.modoSilencioso;
                        }
                    }
                }
            }

            Rectangle {
                width: 100; height: 32; radius: 8;
                color: btnClear.containsMouse ? "#F38BA8" : root.tema.fondoVariante
                Behavior on color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.centerIn: parent; spacing: 5
                    Text { text: "󰎟"; color: btnClear.containsMouse ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 14 }
                    Text { text: "Limpiar"; color: btnClear.containsMouse ? "#1E1E2E" : root.tema.textoPrimario; font.pixelSize: 12; font.weight: Font.Bold }
                }
                MouseArea {
                    id: btnClear; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: root.motorNotificaciones.limpiarTodo()
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12

            model: root.motorNotificaciones ? root.motorNotificaciones.historial : []

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15
                visible: parent.count === 0

                Image {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 100
                    source: "file:///home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/Fondo.png"
                    fillMode: Image.PreserveAspectFit
                    opacity: 0.8
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0; colorizationColor: root.tema.primario; contrast: 0.5; brightness: 0.8
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Sin Notificaciones"
                    color: Qt.alpha(root.tema.textoPrimario, 0.6)
                    font.pixelSize: 18; font.weight: Font.Bold
                }
            }

            delegate: Rectangle {
                id: card
                width: ListView.view.width
                implicitHeight: cardContent.implicitHeight + 24
                radius: 16

                property int urgencia: modelData ? modelData.urgency : 1

                color: urgencia === 2 ? "#311B22" : Qt.alpha(root.tema.barraFondo, 0.8)
                border.color: urgencia === 2 ? "#F38BA8" : Qt.alpha(root.tema.primario, 0.3)
                border.width: 1
                Behavior on opacity { NumberAnimation { duration: 200 } }

                // 👇 MOUSEAREA PARA ABRIR LA APP
                MouseArea {
                    anchors.fill: parent
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
                    id: cardContent
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "󰂚"; color: urgencia === 2 ? "#F38BA8" : root.tema.primario; font.pixelSize: 12 }
                        Text { text: modelData.appName !== "" ? modelData.appName : "Sistema"; color: Qt.alpha(root.tema.textoPrimario, 0.7); font.pixelSize: 12; font.weight: Font.Bold; Layout.fillWidth: true }
                        Text { text: "Ahora"; color: Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 11; Layout.rightMargin: 5 }

                        Rectangle {
                            width: 24; height: 24; radius: 12;
                            color: btnCerrarCard.containsMouse ? root.tema.capsulaHover : "transparent"
                            Text { anchors.centerIn: parent; text: "󰅖"; color: Qt.alpha(root.tema.textoPrimario, 0.8); font.pixelSize: 14 }

                            // 👇 BOTÓN 'X' CORREGIDO
                            MouseArea {
                                id: btnCerrarCard; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    card.opacity = 0;
                                    // Corregido el "QQt" y agregado el ".id"
                                    Qt.callLater(() => { root.motorNotificaciones.eliminarDelHistorial(modelData.id) })
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12; Layout.alignment: Qt.AlignTop
                        Rectangle {
                            property string rutaIcono: root.motorNotificaciones.obtenerIcono(modelData)
                            visible: rutaIcono !== ""
                            width: 48; height: 48; radius: 12; color: "transparent"; clip: true
                            Image { anchors.fill: parent; source: parent.rutaIcono; fillMode: Image.PreserveAspectCrop }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 2
                            Text {
                                text: modelData.summary; color: root.tema.textoPrimario; font.pixelSize: 14; font.weight: Font.Bold
                                Layout.fillWidth: true; wrapMode: Text.Wrap
                            }
                            Text {
                                text: modelData.body; color: Qt.alpha(root.tema.textoPrimario, 0.8); font.pixelSize: 13
                                Layout.fillWidth: true; wrapMode: Text.Wrap; visible: modelData.body !== ""
                                maximumLineCount: 3; elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // 3. CALENDARIO INTERACTIVO
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 310
            radius: 18
            color: root.tema.fondoVariante
            border.color: Qt.alpha(root.tema.primario, 0.2); border.width: 1

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 15; spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        width: 30; height: 30; radius: 15;
                        color: btnPrev.containsMouse ? root.tema.capsulaHover : "transparent"
                        Text { anchors.centerIn: parent; text: "󰅁"; color: root.tema.primario; font.pixelSize: 16 }
                        MouseArea { id: btnPrev; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: centroFlotante.cambiarMes(-1) }
                    }
                    Text {
                        text: {
                            let d = new Date(centroFlotante.anioActual, centroFlotante.mesActual, 1);
                            return Qt.formatDateTime(d, "MMMM yyyy").toUpperCase()
                        }
                        color: root.tema.textoPrimario; font.pixelSize: 16; font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true
                    }
                    Rectangle {
                        width: 30; height: 30; radius: 15;
                        color: btnNext.containsMouse ? root.tema.capsulaHover : "transparent"
                        Text { anchors.centerIn: parent; text: "󰅂"; color: root.tema.primario; font.pixelSize: 16 }
                        MouseArea { id: btnNext; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: centroFlotante.cambiarMes(1) }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(root.tema.textoPrimario, 0.2) }

                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa"]
                        delegate: Text {
                            text: modelData; color: Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 14; font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    columns: 7; rowSpacing: 8; columnSpacing: 8

                    Repeater {
                        model: {
                            let m = centroFlotante.mesActual;
                            let y = centroFlotante.anioActual;
                            let primerDia = new Date(y, m, 1).getDay();
                            let diasMes = new Date(y, m + 1, 0).getDate();
                            let totalCeldas = 42;
                            let array = [];
                            for(let i = 0; i < totalCeldas; i++) {
                                if(i < primerDia || i >= primerDia + diasMes) array.push("");
                                else array.push((i - primerDia + 1).toString());
                            }
                            return array;
                        }
                        delegate: Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            radius: 10
                            property bool esHoy: {
                                let hoy = new Date();
                                return modelData !== "" && parseInt(modelData) === hoy.getDate() &&
                                centroFlotante.mesActual === hoy.getMonth() && centroFlotante.anioActual === hoy.getFullYear();
                            }
                            color: esHoy ? root.tema.primario : "transparent"
                            Text {
                                anchors.centerIn: parent; text: modelData
                                color: esHoy ? "#1E1E2E" : root.tema.textoPrimario
                                font.pixelSize: 14; font.weight: esHoy ? Font.Bold : Font.Normal
                            }
                        }
                    }
                }
            }
        }
    }
}
