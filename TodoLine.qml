import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Rectangle {
    id: root
    property alias todo_text: todo_text

    required property string value
    required property int is_achieved

    property variant on_read: () => null
    property variant on_draft: () => null
    property variant on_delete: () => null

    height: 50

    state: is_achieved ? "done" : "pending"
    states: [
        State {
            name: "pending"
            PropertyChanges {
                target: todo_text
                font.strikeout: false
                color: "#5c5858"
            }
            PropertyChanges {
                target: checkbox
                border.width: 1
            }
        },
        State {
            name: "done"
            PropertyChanges {
                target: todo_text
                font.strikeout: true
                opacity: 0.3
            }
            PropertyChanges {
                target: checkbox
                //                color: "green"
                border.width: 0
            }
        }
    ]

    SwipeView {
        currentIndex: 0
        anchors.fill: parent
        spacing: 50

        Item {
            width: root.width
            Text {
                id: todo_text
                text: value
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                id: checkbox
                width: 30
                height: 30
                radius: 30

                border.width: 3
                border.color: "#ccc"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                IconImage {
                    source: "qrc:/img/checkbox.png"
                    anchors.fill: parent
                    color: "green"
                    visible: root.state === "done"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.state === "pending") {
                            root.state = "done"
                            on_read()
                        } else {
                            root.state = "pending"
                            on_draft()
                        }
                    }
                }
            }
        }

        Button {
            text: "Supprimer"
            font.pixelSize: 16
            background: Rectangle {
                color: Material.color(Material.Red, Material.Shade400)
                radius: 18
            }
            palette.buttonText: "white"
            Material.foreground: Material.color(Material.Grey, Material.Shade50)
            onClicked: on_delete()
            icon.source: "qrc:/img/delete-outline.svg"
        }
    }

    HoverHandler {
        cursorShape: Qt.DragLinkCursor
    }
}
