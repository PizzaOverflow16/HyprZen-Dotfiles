import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀
// BARRA PRINCIPAL SUPERIOR (ESTILO PÍLDORA FLOTANTE)
// ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀

PanelWindow {
    id: topBar
    anchors { top: true; left: true; right: true }

    // ✅ 1. MÁRGENES CORREGIDOS: Van afuera de las llaves de anchors
    margins.top: 10
    margins.left: 15
    margins.right: 15

    // ✅ 2. Aumentamos la zona exclusiva a 50 (40 de la barra + 10 del margen superior)
    exclusiveZone: 50
    implicitHeight: 40

    // ✅ 3. La ventana contenedora ahora es invisible
    color: "transparent"

    property string menuActivo: ""

    signal toggle(string menu)
    signal abrirGaleria()

    onToggle: function(menu) {
        if (menuActivo === menu) {
            menuActivo = "";
        } else {
            menuActivo = menu;
        }
    }

    // ✅ 4. El "Rectangle" que dibuja la píldora negra
    Rectangle {
        anchors.fill: parent

        // El color negro que tenías
        color: "#000000"

        // ✅ 5. EL REDONDEADO (Píldora perfecta)
        radius: 20

        // Margen interno para los componentes (se lo damos a un Item interno)
        Item {
            anchors.fill: parent
            anchors.leftMargin: 15; anchors.rightMargin: 15

            // ==========================================
            // [1] ZONA IZQUIERDA: SISTEMA Y WORKSPACES
            // ==========================================
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20

                PerfilBarra {
                    menuAbierto: topBar.menuActivo === "perfil"
                    onToggleMenu: topBar.toggle("perfil")
                }

                WorkspaceBarra {}

                SistemaBarra {
                    menuAbierto: topBar.menuActivo === "sistema"
                    onToggleMenu: topBar.toggle("sistema")
                }

                CapsulaWallpaper {
                    onClicked: topBar.abrirGaleria()
                }

                CapsulaClima {
                    menuAbierto: topBar.menuActivo === "clima"
                    onToggleMenu: topBar.toggle("clima")
                }

                CapsulaMinimizadas {
                    menuAbierto: topBar.menuActivo === "minimizadas"
                    onToggleMenu: topBar.toggle("minimizadas")
                }
            }

            // ==========================================
            // [2] ZONA CENTRAL: RELOJ (MÓDULO EXTERNO)
            // ==========================================
            RelojBarra {
                id: moduloReloj
                z: 10
                anchors.centerIn: parent
                menuAbierto: topBar.menuActivo === "calendario"
                onToggleMenu: topBar.toggle("calendario")
            }

            VentanaBarra {
                anchors.right: moduloReloj.left
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            PolycatBarra {
                anchors.left: moduloReloj.right
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            // ==========================================
            // [3] ZONA DERECHA: MULTIMEDIA Y BATERÍA
            // ==========================================
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15

                MediaBarra {
                    menuAbierto: topBar.menuActivo === "media"
                    onToggleMenu: topBar.toggle("media")
                }

                WifiBarra {
                    menuAbierto: topBar.menuActivo === "control"
                    onToggleMenu: topBar.toggle("control")
                }
                CapsulaAudio {
                    menuAbierto: topBar.menuActivo === "audio"
                    onToggleMenu: topBar.toggle("audio")
                }
                CapsulaBateria {
                    menuAbierto: topBar.menuActivo === "bateria"
                    onToggleMenu: topBar.toggle("bateria")
                }
                CapsulaNotificaciones {
                    menuAbierto: topBar.menuActivo === "notificaciones"
                    onToggleMenu: topBar.toggle("notificaciones")
                }
                CapsulaPower {
                    menuAbierto: topBar.menuActivo === "power"
                    onToggleMenu: topBar.toggle("power")
                }
            }
        }
    }
}
