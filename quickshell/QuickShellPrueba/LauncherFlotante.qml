import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Scope {
    // ✅ Fix de nombre para no chocar con el Cerebro
    id: launcherScope
    property bool activa: false

    // ✅ Dejamos el arreglo vacío. Ahora solo se llenará con tus aplicaciones reales.
    property var baseDatos: []

    Component.onCompleted: {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///home/elton/.config/quickshell/apps.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    let appsDelSistema = JSON.parse(xhr.responseText);
                    launcherScope.baseDatos = launcherScope.baseDatos.concat(appsDelSistema);
                } catch(e) {}
            }
        }
        xhr.send();
    }

    PanelWindow {
        id: launcherWindow

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        visible: launcherScope.activa
        focusable: visible

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked: launcherScope.activa = false
        }

        Rectangle {
            id: bgContainer
            width: 600

            height: mainColumn.height + 20

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 24

            // ✅ Fondo y bordes dinámicos de Matugen
            color: root.tema.flotanteFondo
            border.color: root.tema.flotanteBorde
            border.width: 2

            MouseArea { anchors.fill: parent }

            Column {
                id: mainColumn
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                spacing: 5

                ListView {
                    id: listView
                    width: parent.width

                    height: count === 0 ? 0 : Math.min(400, count * 64)

                    clip: true
                    spacing: 0
                    model: ListModel { id: resultModel }

                    verticalLayoutDirection: ListView.BottomToTop
                    Behavior on contentY { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    delegate: Rectangle {
                        width: listView.width
                        height: 64
                        radius: 16

                        // ✅ Hover con el color de tu tema
                        color: ListView.isCurrentItem || ma.containsMouse ? root.tema.capsulaHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 15

                            Item {
                                width: 42; height: 42
                                Image {
                                    id: imgIcon
                                    anchors.fill: parent
                                    source: {
                                        if (model.isTextIcon === true) return "";
                                        if (model.icon === "") return "";
                                        if (model.icon.startsWith("/")) return "file://" + model.icon;
                                            return "image://icon/" + model.icon;
                                    }
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    sourceSize: Qt.size(64, 64)
                                    visible: model.isTextIcon !== true && status === Image.Ready
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: model.isTextIcon === true ? model.icon : "󰀲"
                                    // ✅ Si es texto (como el buscador o la calculadora), usa el color primario
                                    color: root.tema.primario
                                    font.family: "FiraCode Nerd Font"
                                    font.pixelSize: 24
                                    visible: model.isTextIcon === true || imgIcon.status === Image.Error || imgIcon.status === Image.Null
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                Text {
                                    text: model.name
                                    // ✅ Nombre de la app dinámico
                                    color: root.tema.textoPrimario
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: model.comment
                                    // ✅ Comentario de la app dinámico
                                    color: Qt.alpha(root.tema.textoPrimario, 0.7)
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    visible: model.comment !== ""
                                    opacity: 0.8
                                }
                            }
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                listView.currentIndex = index;
                                launcherWindow.ejecutarSeleccion(index);
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width - 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 1
                    // ✅ Separador de línea con la variante del tema
                    color: root.tema.fondoVariante
                    visible: listView.count > 0
                }

                Item {
                    width: parent.width
                    height: 50

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        spacing: 15

                        // ✅ Ícono de lupa con color dinámico
                        Text { text: "󰍉"; color: root.tema.primario; font.pixelSize: 22 }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            // ✅ Texto que escribes reactivo al tema
                            color: root.tema.textoPrimario
                            font.pixelSize: 18
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            focus: launcherScope.activa

                            Text {
                                text: "Buscar aplicaciones..."
                                color: Qt.alpha(root.tema.textoPrimario, 0.5)
                                font.pixelSize: 18
                                visible: !searchInput.text && !searchInput.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Keys.onUpPressed: if (listView.currentIndex < resultModel.count - 1) listView.currentIndex++
                            Keys.onDownPressed: if (listView.currentIndex > 0) listView.currentIndex--
                            Keys.onEscapePressed: launcherScope.activa = false
                            Keys.onReturnPressed: launcherWindow.ejecutarSeleccion(listView.currentIndex)
                            Keys.onEnterPressed: launcherWindow.ejecutarSeleccion(listView.currentIndex)

                            onTextChanged: launcherWindow.filtrar(text)
                        }
                    }
                }
            }
        }

        onVisibleChanged: {
            if (visible) {
                searchInput.text = "";
                searchInput.forceActiveFocus();
                filtrar("");
            }
        }

        function evaluarMatematicas(expr) {
            try {
                let sanitized = expr.replace(/[^-()\d/*+.]/g, '');
                if (sanitized === "") return null;
                return Function('"use strict";return (' + sanitized + ')')();
            } catch (e) { return null; }
        }

        function fuzzyMatch(text, pattern) {
            let ti = 0, pi = 0;
            while (ti < text.length && pi < pattern.length) {
                if (text[ti] === pattern[pi]) pi++;
                ti++;
            }
            return pi === pattern.length;
        }

        function filtrar(query) {
            resultModel.clear();
            let q = query.toLowerCase().trim();

            let mathRes = evaluarMatematicas(q);
            if (mathRes !== null && q !== "") {
                resultModel.append({ name: "= " + mathRes, comment: "Resultado", icon: "󰪚", exec: "", isCalc: true, isTextIcon: true });
            }

            if (q === "") {
                for (let i = 0; i < Math.min(12, launcherScope.baseDatos.length); i++) {
                    resultModel.append(launcherScope.baseDatos[i]);
                }
                listView.currentIndex = 0;
                return;
            }

            let exactos = [], inician = [], contienen = [], fuzzys = [];

            for (let i = 0; i < launcherScope.baseDatos.length; i++) {
                let item = launcherScope.baseDatos[i];
                if (!item.name) continue;

                let n = item.name.toLowerCase();
                let c = item.comment ? item.comment.toLowerCase() : "";

                if (n === q) exactos.push(item);
                else if (n.startsWith(q)) inician.push(item);
                else if (n.includes(q) || c.includes(q)) contienen.push(item);
                else if (fuzzyMatch(n, q)) fuzzys.push(item);
            }

            let combinados = exactos.concat(inician, contienen, fuzzys);

            for (let j = 0; j < Math.min(12, combinados.length); j++) {
                resultModel.append(combinados[j]);
            }

            if (resultModel.count === 0 && q !== "") {
                resultModel.append({
                    name: query,
                    comment: "Buscar en la web...",
                    icon: "󰈹",
                    exec: "xdg-open 'https://duckduckgo.com/?q=" + encodeURIComponent(query) + "'",
                                   isCalc: false,
                                   isTextIcon: true
                });
            }

            listView.currentIndex = 0;
        }

        function ejecutarSeleccion(index) {
            if (index < 0 || index >= resultModel.count) return;
            let item = resultModel.get(index);

            if (!item.isCalc && item.exec !== "") {
                Quickshell.execDetached(["bash", "-c", item.exec]);
            }
            launcherScope.activa = false;
        }
    }
}
