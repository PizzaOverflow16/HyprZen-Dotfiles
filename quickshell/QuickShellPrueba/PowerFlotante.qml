import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: powerScreen
    property string menuActivo: ""
    signal abrirMenu(string nombreMenu)

    anchors.fill: parent

    // ✅ Fondo cristalino dinámico (usando el color de fondo de tu tema)
    color: Qt.alpha(root.tema.fondoSuperficie, 0.85)

    visible: opacity > 0
    opacity: menuActivo === "power" ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    // ✅ LÓGICA DE ESCAPE Y FOCO
    focus: visible
    Keys.onEscapePressed: powerScreen.abrirMenu("")

    onVisibleChanged: {
        if (visible) powerScreen.forceActiveFocus();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: powerScreen.abrirMenu("")
    }

    Process { id: shCmd }

    RowLayout {
        anchors.centerIn: parent
        spacing: 30

        Repeater {
            model: ListModel {
                // He reemplazado los colores estáticos por alias que usaremos con el tema
                ListElement { nombre: "Bloquear"; icono: ""; cmd: "qs ipc call lockscreen lock"; tipo: "primario" }
                ListElement { nombre: "Hibernar"; icono: "󰤄"; cmd: "loginctl lock-session && systemctl suspend"; tipo: "secundario" }
                ListElement { nombre: "Sesión"; icono: "󰍃"; cmd: "loginctl kill-session $XDG_SESSION_ID"; tipo: "peligro" }
                ListElement { nombre: "Reiniciar"; icono: "󰑓"; cmd: "systemctl reboot"; tipo: "primario" }
                ListElement { nombre: "Apagar"; icono: ""; cmd: "systemctl poweroff"; tipo: "peligro" }
            }

            delegate: Item {
                width: 140; height: 180

                // Determinamos el color basado en el tipo y el tema de Matugen
                property color colorBoton: {
                    if (model.tipo === "primario") return root.tema.primario;
                    if (model.tipo === "secundario") return root.tema.secundario;
                    return "#F38BA8"; // Rojo constante para Apagar/Sesión por seguridad visual
                }

                Rectangle {
                    id: btnBg
                    anchors.centerIn: parent
                    width: btnMa.containsMouse ? 140 : 120
                    height: btnMa.containsMouse ? 180 : 160
                    radius: 36

                    // Fondo semitransparente al hacer hover
                    color: btnMa.containsMouse ? Qt.alpha(colorBoton, 0.2) : "transparent"
                    border.color: btnMa.containsMouse ? colorBoton : Qt.alpha(root.tema.textoPrimario, 0.1)
                    border.width: 2

                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
                    Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
                    Behavior on color { ColorAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 15

                        Text {
                            text: icono
                            color: btnMa.containsMouse ? colorBoton : root.tema.textoPrimario
                            font.pixelSize: btnMa.containsMouse ? 54 : 42
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "Iosevka Nerd Font"
                            Behavior on font.pixelSize { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            text: nombre
                            color: root.tema.textoPrimario
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            Layout.alignment: Qt.AlignHCenter
                            opacity: btnMa.containsMouse ? 1.0 : 0.7
                        }
                    }
                }

                MouseArea {
                    id: btnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        powerScreen.abrirMenu("");
                        Quickshell.execDetached(["sh", "-c", cmd]);
                    }
                }
            }
        }
    }
}
