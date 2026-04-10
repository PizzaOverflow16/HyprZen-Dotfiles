import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

Scope {
    // ✅ ¡CAMBIO CRÍTICO DE SEGURIDAD!
    // Cambiamos 'root' a 'lockScope' para no chocar con el Cerebro de Matugen y evitar quedarte bloqueado fuera del PC.
    id: lockScope

    // ==========================================
    // LÓGICA DE AUTENTICACIÓN (PAM)
    // ==========================================
    PamContext {
        id: pam
        configDirectory: "pam"
        config: "password.conf"

        // Cuando PAM pide la contraseña, se la mandamos
        onPamMessage: {
            if (this.responseRequired) {
                this.respond(lockContext.currentPassword);
            }
        }

        // ¿Le atinamos a la contraseña?
        onCompleted: result => {
            if (result === PamResult.Success) {
                lock.locked = false; // ¡Desbloqueado!
                lockContext.currentPassword = "";
                lockContext.showFailure = false;
            } else {
                lockContext.currentPassword = "";
                lockContext.showFailure = true; // Error
            }
            lockContext.unlockInProgress = false;
        }
    }

    // Un objeto para compartir datos entre la lógica y la interfaz
    QtObject {
        id: lockContext
        property string currentPassword: ""
        property bool unlockInProgress: false
        property bool showFailure: false

        function tryUnlock(pwd) {
            if (pwd === "") return;
            currentPassword = pwd;
            unlockInProgress = true;
            pam.start();
        }
    }

    // ==========================================
    // EL BLOQUEO DE WAYLAND
    // ==========================================
    WlSessionLock {
        id: lock
        locked: false // Por defecto inicia desbloqueado para que tú lo llames cuando quieras

        // Esto crea la pantalla visual en todos tus monitores
        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    // Para poder bloquear la pantalla desde la terminal o un atajo de Hyprland
    IpcHandler {
        target: "lockscreen"
        function lock() { lock.locked = true; }
        function unlock() { lock.locked = false; }
    }
}
