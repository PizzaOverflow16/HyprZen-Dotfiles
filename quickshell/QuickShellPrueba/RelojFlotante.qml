import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

Rectangle {
    id: cajonReloj

    property string menuActivo: ""

    // ✅ ALTURA DINÁMICA: Crece si hay un día seleccionado
    width: 380
    height: 530 + (diaSeleccionado !== "" ? 220 : 0)
    radius: 15

    color: root.tema.flotanteFondo
    border.color: root.tema.flotanteBorde
    border.width: 2

    visible: opacity > 0
    opacity: menuActivo === "calendario" ? 1 : 0
    y: menuActivo === "calendario" ? 10 : -20

    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
    Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    MouseArea { anchors.fill: parent }

    // ==========================================
    // 🧠 MEMORIA PERMANENTE DE LA AGENDA
    // ==========================================
    property var baseDatosEventos: ({})
    property string diaSeleccionado: ""
    property string textoDiaSeleccionado: ""

    ListModel { id: eventosDelDiaModel }

    // 1. Cargar datos al iniciar
    function cargarAgenda() {
        let xhr = new XMLHttpRequest();
        // ✅ RUTA ACTUALIZADA AQUÍ
        xhr.open("GET", "file:///home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/agenda.json?nocache=" + new Date().getTime(), false);
        xhr.send(null);
        if (xhr.status === 200 || xhr.status === 0) {
            try {
                let txt = xhr.responseText.trim();
                if (txt !== "") baseDatosEventos = JSON.parse(txt);
            } catch(e) { console.log("Archivo de agenda nuevo o vacío."); }
        }
        actualizarCalendario(); // Dibuja los puntitos de las tareas guardadas
    }

    // 2. Guardar datos silenciosamente en Bash
    function guardarAgenda() {
        let jsonStr = JSON.stringify(baseDatosEventos);
        // Truco para que Bash no se confunda con las comillas
        let safeJson = jsonStr.replace(/'/g, "'\\''");

        // ✅ RUTA ACTUALIZADA AQUÍ (mkdir y echo)
        Quickshell.execDetached(["bash", "-c", "mkdir -p /home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts && echo '" + safeJson + "' > /home/elton/dev/config/dotfiles/quickshell/QuickShellPrueba/scripts/agenda.json"]);
    }

    function seleccionarDia(idFecha, numeroDia) {
        if (diaSeleccionado === idFecha) {
            diaSeleccionado = "";
        } else {
            diaSeleccionado = idFecha;
            textoDiaSeleccionado = numeroDia + " de " + nombresMeses[mesVista] + " " + anioVista;
            cargarEventosEnLista(idFecha);
        }
    }

    function cargarEventosEnLista(idFecha) {
        eventosDelDiaModel.clear();
        if (baseDatosEventos[idFecha]) {
            for (let i = 0; i < baseDatosEventos[idFecha].length; i++) {
                eventosDelDiaModel.append({ "tarea": baseDatosEventos[idFecha][i] });
            }
        }
    }

    function agregarEvento(texto) {
        if (texto.trim() === "" || diaSeleccionado === "") return;

        if (!baseDatosEventos[diaSeleccionado]) {
            baseDatosEventos[diaSeleccionado] = [];
        }
        baseDatosEventos[diaSeleccionado].push(texto);

        cargarEventosEnLista(diaSeleccionado);

        let temp = diasDelMes; diasDelMes = []; diasDelMes = temp;

        // ✅ GUARDAR EN DISCO
        guardarAgenda();
    }

    function eliminarEvento(index) {
        if (baseDatosEventos[diaSeleccionado]) {
            baseDatosEventos[diaSeleccionado].splice(index, 1);
            if (baseDatosEventos[diaSeleccionado].length === 0) {
                delete baseDatosEventos[diaSeleccionado];
            }
            cargarEventosEnLista(diaSeleccionado);
            let temp = diasDelMes; diasDelMes = []; diasDelMes = temp;

            // ✅ GUARDAR EN DISCO
            guardarAgenda();
        }
    }

    // ==========================================
    // LÓGICA DEL RELOJ Y CALENDARIO BASE
    // ==========================================
    property int horas: 0; property int minutos: 0; property int segundos: 0
    property string diaSemana: ""; property string fechaCompleta: ""
    property int mesVista: new Date().getMonth()
    property int anioVista: new Date().getFullYear()
    property var diasDelMes: []
    property var nombresMeses: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]

    function actualizarCalendario() {
        let dias = [];
        let primerDia = new Date(anioVista, mesVista, 1).getDay();
        let totalDias = new Date(anioVista, mesVista + 1, 0).getDate();
        let hoy = new Date();

        for (let i = 0; i < primerDia; i++) {
            dias.push({ texto: "", esHoy: false });
        }
        for (let i = 1; i <= totalDias; i++) {
            let esHoy = (i === hoy.getDate() && mesVista === hoy.getMonth() && anioVista === hoy.getFullYear());
            dias.push({ texto: i.toString(), esHoy: esHoy });
        }
        diasDelMes = dias;
    }

    onMesVistaChanged: actualizarCalendario()
    onAnioVistaChanged: actualizarCalendario()

    // ✅ CARGAMOS LA AGENDA AL INICIAR QUICKSHELL
    Component.onCompleted: cargarAgenda()

    Timer {
        interval: 1000; running: cajonReloj.visible; repeat: true; triggeredOnStart: true
        onTriggered: {
            let ahora = new Date();
            cajonReloj.horas = ahora.getHours(); cajonReloj.minutos = ahora.getMinutes(); cajonReloj.segundos = ahora.getSeconds();
            const dias = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
            cajonReloj.diaSemana = dias[ahora.getDay()];
            cajonReloj.fechaCompleta = ahora.getDate() + " de " + nombresMeses[ahora.getMonth()];
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // --- SECCIÓN 1: EL RELOJ ---
        Row {
            width: parent.width; height: 160; spacing: 20
            Column {
                width: 160; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                Text { text: cajonReloj.diaSemana; color: root.tema.primario; font.pixelSize: 24; font.weight: Font.Bold; font.family: "FiraCode Nerd Font" }
                Text { text: cajonReloj.fechaCompleta; color: root.tema.textoPrimario; font.pixelSize: 16; font.family: "FiraCode Nerd Font" }
                Text {
                    text: (cajonReloj.horas < 10 ? "0" : "") + cajonReloj.horas + ":" + (cajonReloj.minutos < 10 ? "0" : "") + cajonReloj.minutos
                    color: Qt.alpha(root.tema.textoPrimario, 0.6); font.pixelSize: 32; font.weight: Font.Light; font.family: "FiraCode Nerd Font"
                }
            }

            Item {
                width: 160; height: 160; anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent; radius: width / 2; color: root.tema.fondoVariante
                    Repeater { model: 12; Item { width: parent.width; height: parent.height; anchors.centerIn: parent; rotation: index * 30; Rectangle { width: 3; height: 10; color: Qt.alpha(root.tema.textoPrimario, 0.4); anchors.horizontalCenter: parent.horizontalCenter; y: 5; radius: 2 } } }
                    Rectangle { width: 6; height: 45; color: root.tema.secundario; radius: 3; x: parent.width/2 - width/2; y: parent.height/2 - height + 5; transformOrigin: Item.Bottom; rotation: (cajonReloj.horas % 12 + cajonReloj.minutos / 60) * 30; Behavior on rotation { NumberAnimation { duration: 100 } } }
                    Rectangle { width: 4; height: 65; color: root.tema.secundario; radius: 2; x: parent.width/2 - width/2; y: parent.height/2 - height + 5; transformOrigin: Item.Bottom; rotation: cajonReloj.minutos * 6; Behavior on rotation { NumberAnimation { duration: 100 } } }
                    Rectangle { width: 2; height: 70; color: root.tema.primario; radius: 1; x: parent.width/2 - width/2; y: parent.height/2 - height + 5; transformOrigin: Item.Bottom; rotation: cajonReloj.segundos * 6; Behavior on rotation { SpringAnimation { spring: 3; damping: 0.5; duration: 200 } } }
                    Rectangle { width: 12; height: 12; radius: 6; color: root.tema.primario; anchors.centerIn: parent; Rectangle { width: 4; height: 4; radius: 2; color: root.tema.fondoVariante; anchors.centerIn: parent } }
                }
            }
        }

        // --- SECCIÓN 2: LÍNEA DIVISORIA ---
        Rectangle { width: parent.width; height: 2; color: Qt.alpha(root.tema.textoPrimario, 0.1); radius: 1 }

        // --- SECCIÓN 3: EL CALENDARIO INTERACTIVO ---
        Column {
            width: parent.width; spacing: 15

            RowLayout {
                width: parent.width
                Text {
                    text: "◀"; color: Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 18
                    MouseArea { anchors.fill: parent; anchors.margins: -10; cursorShape: Qt.PointingHandCursor; onClicked: { if (mesVista === 0) { mesVista = 11; anioVista--; } else { mesVista--; } } }
                }
                Text {
                    text: cajonReloj.nombresMeses[mesVista] + " " + anioVista
                    color: root.tema.textoPrimario; font.pixelSize: 16; font.weight: Font.Bold; font.family: "FiraCode Nerd Font"
                    horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true
                }
                Text {
                    text: "▶"; color: Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 18
                    MouseArea { anchors.fill: parent; anchors.margins: -10; cursorShape: Qt.PointingHandCursor; onClicked: { if (mesVista === 11) { mesVista = 0; anioVista++; } else { mesVista++; } } }
                }
            }

            Row {
                spacing: 8
                Repeater {
                    model: ["Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sá"]
                    Text { width: 40; text: modelData; color: root.tema.secundario; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; font.family: "FiraCode Nerd Font" }
                }
            }

            Grid {
                columns: 7; spacing: 8
                Repeater {
                    model: cajonReloj.diasDelMes
                    Rectangle {
                        width: 40; height: 40; radius: 20

                        property string miIdFecha: cajonReloj.anioVista + "-" + cajonReloj.mesVista + "-" + modelData.texto
                        property bool estaSeleccionado: cajonReloj.diaSeleccionado === miIdFecha
                        property bool tieneTareas: cajonReloj.baseDatosEventos[miIdFecha] !== undefined

                        color: estaSeleccionado ? Qt.alpha(root.tema.primario, 0.3) : (modelData.esHoy ? root.tema.primario : (hoverDia.containsMouse && modelData.texto !== "" ? root.tema.capsulaHover : "transparent"))
                        border.color: estaSeleccionado ? root.tema.primario : "transparent"
                        border.width: estaSeleccionado ? 2 : 0
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent; text: modelData.texto
                            color: modelData.esHoy ? "#11111B" : root.tema.textoPrimario
                            font.weight: modelData.esHoy || estaSeleccionado ? Font.Bold : Font.Normal
                            font.family: "FiraCode Nerd Font"
                        }

                        Rectangle {
                            width: 4; height: 4; radius: 2; color: modelData.esHoy ? "#11111B" : root.tema.secundario
                            anchors { bottom: parent.bottom; bottomMargin: 6; horizontalCenter: parent.horizontalCenter }
                            visible: tieneTareas && modelData.texto !== ""
                        }

                        MouseArea {
                            id: hoverDia
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: modelData.texto !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (modelData.texto !== "") {
                                    cajonReloj.seleccionarDia(miIdFecha, modelData.texto);
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- SECCIÓN 4: LA AGENDA EXPANDIBLE ---
        ColumnLayout {
            width: parent.width
            height: 200
            visible: cajonReloj.diaSeleccionado !== ""
            opacity: cajonReloj.diaSeleccionado !== "" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
            spacing: 10

            Rectangle { Layout.fillWidth: true; height: 2; color: Qt.alpha(root.tema.textoPrimario, 0.1); radius: 1 }

            Text {
                text: "📅 " + cajonReloj.textoDiaSeleccionado
                color: root.tema.primario; font.pixelSize: 15; font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: Qt.alpha(root.tema.fondoVariante, 0.5); radius: 10; clip: true

                ListView {
                    anchors.fill: parent; anchors.margins: 10; spacing: 8
                    model: eventosDelDiaModel

                    Text {
                        text: "Sin eventos programados"
                        color: Qt.alpha(root.tema.textoPrimario, 0.4); font.pixelSize: 13
                        anchors.centerIn: parent
                        visible: eventosDelDiaModel.count === 0
                    }

                    delegate: RowLayout {
                        width: ListView.view.width; spacing: 10
                        Rectangle { width: 6; height: 6; radius: 3; color: root.tema.secundario }
                        Text { text: model.tarea; color: root.tema.textoPrimario; font.pixelSize: 14; Layout.fillWidth: true; wrapMode: Text.Wrap }

                        Text {
                            text: "󰅖"; color: hoverBorrar.containsMouse ? "#F38BA8" : Qt.alpha(root.tema.textoPrimario, 0.5); font.pixelSize: 16
                            MouseArea { id: hoverBorrar; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: cajonReloj.eliminarEvento(index) }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Rectangle {
                    Layout.fillWidth: true; height: 35; radius: 8
                    color: root.tema.fondoVariante; border.color: inputNuevaTarea.activeFocus ? root.tema.primario : Qt.alpha(root.tema.textoPrimario, 0.2); border.width: 1
                    TextInput {
                        id: inputNuevaTarea
                        anchors.fill: parent; anchors.margins: 10; verticalAlignment: TextInput.AlignVCenter
                        color: root.tema.textoPrimario; font.pixelSize: 13
                        Text { text: "Agregar tarea/evento..."; color: Qt.alpha(root.tema.textoPrimario, 0.4); font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter; visible: !inputNuevaTarea.text }
                        onAccepted: { cajonReloj.agregarEvento(inputNuevaTarea.text); inputNuevaTarea.text = ""; }
                    }
                }
                Rectangle {
                    width: 35; height: 35; radius: 8; color: root.tema.primario
                    Text { anchors.centerIn: parent; text: ""; color: "#11111B"; font.pixelSize: 16; font.weight: Font.Bold }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { cajonReloj.agregarEvento(inputNuevaTarea.text); inputNuevaTarea.text = ""; } }
                }
            }
        }
    }
}
