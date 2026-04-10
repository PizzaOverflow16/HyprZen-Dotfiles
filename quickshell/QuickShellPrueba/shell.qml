import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    // ¡EL CEREBRO DE COLORES!
    property var tema: Tema {}
    // 👇 NUEVA MEMORIA PARA EL WALLPAPER (Ponle aquí el que quieres que arranque por defecto)
    property string wallpaperActual: "file:///home/elton/dev/config/dotfiles/Wallpapers/Wallpaper1.jpg"
    // En tu shell.qml, debajo de tu tema y wallpaper:
    property string fotoPerfilActual: "file:///home/elton/dev/config/dotfiles/imagenes_usuarios/WhatsApp Image 2026-01-31 at 9.57.53 AM.jpeg"
    // Variable global: "" (nada), "sistema", "calendario", "media", "control", "redes"
    property string menuAbierto: ""

    // 1. La barra superior
    property var barra: BarraPrueba {
        menuActivo: root.menuAbierto
        onToggle: function(menu) {
            // Si le das clic al que ya está abierto, se cierra. Si no, se abre.
            if (root.menuAbierto === menu) root.menuAbierto = "";
            else root.menuAbierto = menu;
        }

        onAbrirGaleria: function() {
            // Cerramos cualquier panel abierto para limpiar la vista
            root.menuAbierto = "";
            // Alternamos la visibilidad de la galería
            galeriaMaster.activa = !galeriaMaster.activa;
        }
    }

    // 2. La capa invisible que contiene las ventanas desplegables
    property var capaFlotante: OverlayPrueba {
        visible: root.menuAbierto !== "" // Solo existe si hay un menú abierto
        menuActivo: root.menuAbierto
        onCerrar: root.menuAbierto = ""  // Se cierra si das clic fuera

        // ¡LA CONEXIÓN FINAL!: Escuchamos el "grito" del Overlay para cambiar de menú
        onCambiarMenu: function(nuevoMenu) {
            root.menuAbierto = nuevoMenu;
        }
    }

    property var motorNotificaciones: Notificaciones {}

    property var galeria: GaleriaWallpaper {
        id: galeriaMaster
    }

    // ==========================================
    // 2. LOGICA DE COMUNICACIÓN (IPC)
    // ==========================================

    // Escucha el "mensaje" desde el bind de Hyprland (SUPER+W)
    property var escuchadorGaleria: IpcHandler {
        target: "galeria" // Nombre del objetivo para qs ipc

        function toggle() {
            // Alternamos la visibilidad de la galería instanciada arriba
            galeriaMaster.activa = !galeriaMaster.activa;

            // Opcional: Si abrimos la galería, cerramos cualquier panel del centro de control abierto
            if (galeriaMaster.activa) root.menuAbierto = "";
        }
    }

    // Escucha el "mensaje" desde el bind de Hyprland (SUPER+E) para el Post-it
    property var escuchadorNotas: IpcHandler {
        target: "notas" // Nombre del objetivo para qs ipc

        function toggle() {
            // Alternamos la visibilidad del Post-it instanciado arriba
            notasMaster.activa = !notasMaster.activa;

            // Opcional: Cerramos cualquier panel abierto de la barra superior para mantener el enfoque en la nota
            if (notasMaster.activa) root.menuAbierto = "";
        }
    }

    // El Launcher instanciado
    property var launcher: LauncherFlotante {
        id: launcherMaster
    }

    // El oído IPC para Hyprland
    property var escuchadorLauncher: IpcHandler {
        target: "launcher"
        function toggle() {
            launcherMaster.activa = !launcherMaster.activa;
            if (launcherMaster.activa) root.menuAbierto = "";
        }
    }

    // ==========================================
    // 3. PANTALLA DE BLOQUEO (NUEVO)
    // ==========================================
    property var pantallaBloqueo: LockScreen {}

    property var panelIA: PanelIA {}
    // El nuevo cajón de Red
    property var radarRed: PanelRed {}

    property var notas: NotasRapidas { id: notasMaster }

    property var popupsNotificaciones: NotificacionesDaemon {}
}
