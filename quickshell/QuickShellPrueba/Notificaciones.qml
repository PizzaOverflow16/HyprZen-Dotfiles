import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: motor

    property var popups: []
    property var historial: []
    property bool hayCriticas: historial.some(n => n.urgency === 2)
    property bool modoSilencioso: false

    property var servidor: NotificationServer {
        onNotification: notif => {
            let titulo = notif.summary ? notif.summary.trim() : "";
            let nombreApp = notif.appName ? notif.appName.toLowerCase() : "";

            // 🛑 GUILLOTINAS
            if (titulo === "") {
                try { notif.dismiss(); } catch(e) {}
                return;
            }
            if (nombreApp === "kwybars") {
                try { notif.dismiss(); } catch(e) {}
                return;
            }

            notif.tracked = true;

            // ✅ SEÑAL DE CIERRE (Cuando ZapZap u otra app la cierra remotamente)
            notif.closed.connect(function() {
                motor.eliminarDelHistorial(notif.id);
            });

            // ✅ AGREGAR AL HISTORIAL (Actualizando la UI correctamente)
            let tempH = motor.historial.slice();
            tempH.unshift(notif);
            motor.historial = tempH;

            // ✅ AGREGAR AL POPUP (Si no está en silencio)
            if (!motor.modoSilencioso) {
                let tempP = motor.popups.slice();
                tempP.unshift(notif);
                motor.popups = tempP;
            }
        }
    }

    // ✅ FUNCIÓN CORREGIDA: Borrar Popup
    function eliminarPopup(idABorrar) {
        let tempP = motor.popups.slice();
        let indexP = tempP.findIndex(n => n.id === idABorrar);

        if (indexP !== -1) {
            tempP.splice(indexP, 1);
            motor.popups = tempP;
        }
    }

    // ✅ FUNCIÓN CORREGIDA: Borrar Historial (y Popup si sigue vivo)
    function eliminarDelHistorial(idABorrar) {
        eliminarPopup(idABorrar);

        let tempH = motor.historial.slice();
        let indexH = tempH.findIndex(n => n.id === idABorrar);

        if (indexH !== -1) {
            let obj = tempH[indexH];
            tempH.splice(indexH, 1);
            motor.historial = tempH; // Actualiza la UI y la campanita al instante

            try { obj.dismiss(); } catch(e) {} // Le avisa al SO que ya la borramos
        }
    }

    // ✅ FUNCIÓN CORREGIDA: Limpiar Todo
    function limpiarTodo() {
        // Hacemos una copia para borrar una por una
        let viejasNotifs = motor.historial.slice();

        // 1. Vaciamos las listas para que la UI se limpie instantáneamente
        motor.historial = [];
        motor.popups = [];

        // 2. Le avisamos al SO en segundo plano
        for (let i = 0; i < viejasNotifs.length; i++) {
            try { viejasNotifs[i].dismiss(); } catch(e) {}
        }
    }

    // Manejo de Íconos (queda intacto, está perfecto)
    function obtenerIcono(notif) {
        if (!notif) return "";
        let nombreApp = notif.appName ? notif.appName.toLowerCase() : "";
        if (nombreApp === "zapzap" || nombreApp === "whatsapp") return "file:///home/elton/Scripts/whatsapp.png";

            let img = notif.image ? notif.image.toString() : "";
        let appImg = notif.appIcon ? notif.appIcon.toString() : "";

        function procesarRuta(ruta) {
            if (!ruta || ruta === "") return "";
            if (ruta.toLowerCase() === "whatsapp") return "file:///home/elton/Scripts/whatsapp.png";
                if (ruta.startsWith("image://") || ruta.startsWith("file://") || ruta.startsWith("http")) return ruta;
                    if (ruta.startsWith("/")) return "file://" + ruta;
                        return "image://icon/" + ruta;
        }
        let iconoFinal = procesarRuta(img);
        if (iconoFinal === "") iconoFinal = procesarRuta(appImg);
        return iconoFinal;
    }
}
