import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.LocalStorage

ApplicationWindow {
    id: root
    maximumWidth: 380
    minimumWidth: maximumWidth
    height: 640
    visible: true
    title: qsTr("Hello World")
    color: "white"

    property color color_primary: "#9ecaf5"
    property var db: LocalStorage.openDatabaseSync("_db001", "0.1",
                                                   "V001", 1000000)

    function fetchAll() {
        db.transaction(function (tx) {
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS Todo(id INTEGER PRIMARY KEY, label TEXT, is_done INTEGER DEFAULT 0)')
            var data = tx.executeSql("SELECt * FROM Todo ORDER BY id DESC ")

            model_todo.clear()
            const len = data.rows.length

            for (var i = 0; i < len; i++) {
                let item = data.rows[i]
                model_todo.append(item)
            }

            //                data.rows.forEach(item => model_todo.append(item))
        })
    }

    Component.onCompleted: {
        fetchAll()
    }

    function append(val) {
        if (val) {
            db.transaction(function (tx) {
                var res = tx.executeSql(
                            `INSERT INTO Todo (label) VALUES ('${val}')`)
                fetchAll()
            })
            add_popup.close()
        }
    }

    function change_achievement(id, last_achievement) {
        db.transaction(function (tx) {
            var res = tx.executeSql(
                        `UPDATE Todo SET is_done = ${last_achievement
                        === 0 ? 1 : 0} WHERE id=${id} `)
            if (res.rowsAffected)
                fetchAll()
        })
    }

    function delete_todo(id) {
        db.transaction(function (tx) {
            var res = tx.executeSql(`DELETE FROM Todo WHERE id=${id}`)
            if (res.rowsAffected)
                fetchAll()
        })
    }

    header: Item {
        id: header
        height: 75
        Rectangle {
            id: sub_header
            width: parent.width * 4
            height: width
            radius: width / 2
            color: root.color_primary
            anchors.horizontalCenter: parent.horizontalCenter
            y: -width / 2 - 670
        }
        IconImage {
            source: "https://raw.githubusercontent.com/OlivierLDff/MaterialDesignSvgo/master/svg/arrow-left.svg"
            color: "white"
            sourceSize.width: 30
            sourceSize.height: 30
            x: 25
            y: 25
        }
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 25
            Text {
                text: (new Date()).toDateString()
                color: "white"
                font {
                    pixelSize: 24
                    weight: Font.DemiBold
                }
            }
            Text {
                text: model_todo.count + " tasks"
                font.pixelSize: 16
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    ListModel {
        id: model_todo
    }

    Item {
        id: no_data
        visible: model_todo.count === 0

        anchors.fill: parent
        Text {
            text: "Aucune tâche !"
            font.pixelSize: 18
            color: "#ccc"
            anchors.centerIn: parent
        }
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 35

        anchors.leftMargin: 40
        anchors.rightMargin: 40

        ListView {
            anchors.fill: parent

            spacing: 10
            model: model_todo
            add: Transition {
                NumberAnimation { properties: "x"; from: 1000; duration: 200 }
            }
            delegate: TodoLine {
                required property string label
                required property int is_done
                required property int id
                required property int index

                value: label
                is_achieved: is_done
                width: 300
                on_read: () => root.change_achievement(id, is_done)
                on_draft: () => root.change_achievement(id, is_done)
                on_delete: () => root.delete_todo(id)
            }
        }
    }

    Rectangle {
        width: 50
        height: 50
        radius: 50
        color: root.color_primary

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15

        anchors.right: parent.right
        anchors.rightMargin: 15

        IconImage {
            source: "qrc:/img/plus.svg"
            anchors.centerIn: parent
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: add_popup.open()
        }
    }

    Popup {
        id: add_popup
        x: 40
        y: root.height / 3

        property string value
        background: Rectangle {
            radius: 18
            //            color: "#d3d8e0"
        }

        width: root.width - 80
        height: root.height / 3
        padding: 20

        dim: true

        onOpened: {
            input.clear()
        }

        Column {
            spacing: 20
            width: parent.width

            Text {
                id: name
                text: qsTr("Nouvelle tâche")
                font.bold: true
                font.weight: Font.Medium
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
            }
            TextField {
                id: input
                placeholderText: qsTr("Tapez quelque chose à faire")
                width: parent.width
                height: 50
                background: Rectangle {
                    radius: 10
                    border {
                        width: 1
                        color: "#ccc"
                    }
                }
                Connections {
                    target: add_popup
                    function onOpened() {
                        input.forceActiveFocus()
                    }
                }

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 18
                onAccepted: root.append(input.text)
            }

            Button {
                id: submit_btn
                text: "Ajouter"
                anchors.right: parent.right
                width: 120
                height: 45
                font.pixelSize: 16
                background: Rectangle {
                    radius: 5
                    color: submit_btn.hovered ? Qt.lighter(
                                                    root.color_primary) : root.color_primary
                }
                HoverHandler {
                    cursorShape: "PointingHandCursor"
                }
                onClicked: input.accepted()
            }
        }
    }
}
