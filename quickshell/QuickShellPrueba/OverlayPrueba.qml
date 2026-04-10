import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: overlay
    anchors { top: true; left: true; right: true; bottom: true }
    margins.top: 40
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property string menuActivo: ""
    signal cerrar()
    signal cambiarMenu(string nuevoMenu)

    MouseArea {
        anchors.fill: parent
        onClicked: overlay.cerrar()
        z: -1
    }

    SistemaFlotante { x: 15; menuActivo: overlay.menuActivo }

    RelojFlotante { anchors.horizontalCenter: parent.horizontalCenter; menuActivo: overlay.menuActivo }

    MediaFlotante { x: parent.width - width - 15; menuActivo: overlay.menuActivo }

    PerfilFlotante { x: 15; menuActivo: overlay.menuActivo }

    // ✅ Estos sí necesitan la señal porque tienen botones para cambiar entre Wifi y Redes
    ControlWifiFlotante {
        x: parent.width - width - 15
        menuActivo: overlay.menuActivo
        onAbrirMenu: (nombreMenu) => { overlay.cambiarMenu(nombreMenu); }
    }

    RedesFlotante {
        x: parent.width - width - 15
        menuActivo: overlay.menuActivo
        onAbrirMenu: (nombreMenu) => { overlay.cambiarMenu(nombreMenu); }
    }

    // ✅ A partir de aquí limpiamos los onAbrirMenu que causaban el Crash
    BluetoothFlotante {
        x: parent.width - width - 15
        menuActivo: overlay.menuActivo
    }

    AudioFlotante {
        x: parent.width - width - 15
        menuActivo: overlay.menuActivo
    }

    BateriaFlotante {
        x: parent.width - width - 15
        menuActivo: overlay.menuActivo
    }

    PowerFlotante {
        menuActivo: overlay.menuActivo
        // Si tu PowerFlotante tiene teclas de escape (ESC) para cerrarse, lo dejamos activo:
        onAbrirMenu: (nombreMenu) => { overlay.cambiarMenu(nombreMenu); }
    }

    CentroNotificacionesFlotante {
        // ¡Cero anchors o X aquí! Dejamos que el propio componente maneje su animación lateral
        menuActivo: overlay.menuActivo
    }

    CentroClimaFlotante {
        anchors.horizontalCenter: parent.horizontalCenter
        menuActivo: overlay.menuActivo
    }

    MinimizadasFlotante {
        menuActivo: overlay.menuActivo
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
    }
}
