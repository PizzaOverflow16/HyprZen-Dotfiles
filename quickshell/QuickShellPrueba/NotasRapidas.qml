import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: notasWindow

    // ¡EL FIX!: Al no poner 'anchors', Hyprland lo centra automáticamente en tu pantalla
    implicitWidth: 350; implicitHeight: 350
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool activa: false
    visible: activa

    Process { id: shCmd }

    // El cuerpo del Post-it
    Rectangle {
        anchors.fill: parent
        // ✅ Papel camuflado con la superficie de tu sistema
        color: root.tema.fondoSuperficie
        // ✅ Borde iluminado con tu color de acento
        border.color: root.tema.primario
        border.width: 2 // Un poco más grueso para que resalte como panel flotante

        // Pequeño pliegue/sombra simulado
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.width; height: 4
            // ✅ Sombra tintada al estilo Matugen
            color: root.tema.primario
            opacity: 0.3
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // La tira superior (como si fuera el pegamento del Post-it)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                // ✅ Banda superior ligeramente diferente para separar el título
                color: root.tema.fondoVariante

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    Text {
                        text: "󰎚 Nota Rápida"
                        color: root.tema.primario // ✅ Ícono de color
                        font.pixelSize: 14; font.weight: Font.Bold
                    }
                    Item { Layout.fillWidth: true } // Espaciador
                    Text {
                        text: "Ctrl + Enter 󰆓"
                        color: Qt.alpha(root.tema.textoPrimario, 0.6)
                        font.pixelSize: 11
                    }
                }
            }

            // El área de papel para escribir
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                TextArea {
                    id: areaTexto
                    placeholderText: "(Esc para cancelar)"
                    // ✅ Tinta clarita adaptable para el placeholder
                    placeholderTextColor: Qt.alpha(root.tema.textoPrimario, 0.4)
                    // ✅ Tinta sólida dinámica para tu texto
                    color: root.tema.textoPrimario
                    font.pixelSize: 16
                    wrapMode: TextEdit.WordWrap

                    // Márgenes internos para que no se pegue al borde del papel
                    leftPadding: 15; rightPadding: 15; topPadding: 15; bottomPadding: 15

                    // Fondo transparente para que se vea el fondoSuperficie
                    background: Item {}

                    Keys.onPressed: (event) => {
                        // Guardar y cerrar con Ctrl + Enter
                        if (event.key === Qt.Key_Return && event.modifiers & Qt.ControlModifier) {
                            if (areaTexto.text.trim() !== "") {
                                // EJECUTA EL SCRIPT
                                shCmd.command = ["bash", "/home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/guardar_nota.sh", areaTexto.text];
                                shCmd.running = true;

                                areaTexto.text = ""; // Limpiamos para la siguiente nota
                                notasWindow.activa = false; // Cerramos el post-it
                            }
                        }
                        // Cancelar y cerrar con Escape
                        if (event.key === Qt.Key_Escape) {
                            notasWindow.activa = false;
                        }
                    }
                }
            }
        }
    }

    // Cuando se abre la ventana, el cursor se pone listo para escribir
    onActivaChanged: {
        if (activa) areaTexto.forceActiveFocus();
    }
}
