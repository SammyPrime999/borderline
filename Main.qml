import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    width: 1280
    height: 800
    minimumWidth: 980
    minimumHeight: 680

    visible: true
    title: "BORDERLINE"

    color: "#050A0F"

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#0B1620"
            }

            GradientStop {
                position: 0.55
                color: "#08111A"
            }

            GradientStop {
                position: 1.0
                color: "#04080C"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        // =========================================================
        // HEADER
        // =========================================================

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            ColumnLayout {
                spacing: 3

                Text {
                    text: "BORDERLINE"
                    color: "#F7FAFC"
                    font.pixelSize: 30
                    font.bold: true
                    font.letterSpacing: 4
                }

                Text {
                    text: "LAGOS  →  LONDON  →  DALLAS"
                    color: "#7F91A3"
                    font.pixelSize: 13
                    font.letterSpacing: 1.2
                }
            }

            Item {
                Layout.fillWidth: true
            }

            ColumnLayout {
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: "LHR"
                    color: "#61D5FF"
                    font.pixelSize: 17
                    font.bold: true
                    font.letterSpacing: 2
                }

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: "TRANSIT CONTROL"
                    color: "#657789"
                    font.pixelSize: 10
                    font.letterSpacing: 1.3
                }
            }

            Rectangle {
                width: 112
                height: 40
                radius: 8

                color: restartMouse.containsMouse
                       ? "#173043"
                       : "#101C26"

                border.color: restartMouse.containsMouse
                              ? "#55C8F4"
                              : "#253746"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "RESTART"
                    color: "#D3DEE7"
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: restartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: game.restart()
                }
            }
        }

        // =========================================================
        // STATUS BAR
        // =========================================================

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 132

            radius: 14
            color: "#0D1822"
            border.color: "#1B2D3A"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 18

                StatusBlock {
                    title: "CONNECTION"
                    valueText: game.connectionMinutes + " MIN"

                    value: Math.max(
                        0,
                        Math.min(1, game.connectionMinutes / 95)
                    )

                    warning: game.connectionMinutes <= 15
                    danger: game.connectionMinutes <= 5

                    Layout.fillWidth: true
                }

                StatusBlock {
                    title: "STRESS"
                    valueText: game.stress

                    value: Math.max(
                        0,
                        Math.min(1, game.stress / 100)
                    )

                    warning: game.stress >= 50
                    danger: game.stress >= 80

                    Layout.fillWidth: true
                }

                StatusBlock {
                    title: "SUSPICION"
                    valueText: game.suspicion

                    value: Math.max(
                        0,
                        Math.min(1, game.suspicion / 100)
                    )

                    warning: game.suspicion >= 30
                    danger: game.suspicion >= 60

                    Layout.fillWidth: true
                }

                StatusBlock {
                    title: "BATTERY"
                    valueText: game.battery + "%"

                    value: Math.max(
                        0,
                        Math.min(1, game.battery / 100)
                    )

                    warning: game.battery <= 25
                    danger: game.battery <= 10

                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.preferredWidth: 125
                    spacing: 8

                    Text {
                        text: "CASH"
                        color: "#708092"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Text {
                        text: "$" + game.cash
                        color: "#F7FAFC"
                        font.pixelSize: 30
                        font.bold: true
                    }

                    Rectangle {
                        width: 54
                        height: 2
                        color: "#214050"
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }

        // =========================================================
        // MAIN SCENE
        // =========================================================

        Rectangle {
            id: scenePanel

            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 16
            color: "#09131C"
            border.color: "#1B2C39"
            border.width: 1

            opacity: 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 34
                spacing: 30

                // =================================================
                // LEFT: STORY
                // =================================================

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 650
                    spacing: 20

                    RowLayout {
                        Layout.fillWidth: true

                        Rectangle {
                            height: 30
                            width: sceneTagText.implicitWidth + 26
                            radius: 6

                            color: "#102B3A"
                            border.color: "#1F5065"

                            Text {
                                id: sceneTagText
                                anchors.centerIn: parent

                                text: game.sceneTitle

                                color: "#65D4FF"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1.6
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: game.connectionMinutes + " MIN REMAINING"

                            color: game.connectionMinutes <= 15
                                   ? "#FF6B6B"
                                   : "#506476"

                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1.2
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#172936"
                    }

                    Text {
                        Layout.fillWidth: true

                        text: game.story

                        color: "#ECF3F8"

                        wrapMode: Text.WordWrap

                        font.pixelSize: 19
                        font.weight: Font.Medium

                        lineHeight: 1.32
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86

                        radius: 10
                        color: "#0B1720"
                        border.color: "#172A37"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            Rectangle {
                                width: 42
                                height: 42
                                radius: 21
                                color: "#112B3C"

                                Text {
                                    anchors.centerIn: parent
                                    text: "✈"
                                    color: "#5FCFFF"
                                    font.pixelSize: 18
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    text: "CURRENT ROUTE"
                                    color: "#687B8D"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1.3
                                }

                                Text {
                                    text: "Lagos → London → Dallas"
                                    color: "#DDE8F0"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: "STATUS"
                                    color: "#687B8D"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1.3
                                }

                                Text {
                                    Layout.alignment: Qt.AlignRight

                                    text: game.suspicion >= 60
                                          ? "HIGH RISK"
                                          : game.suspicion >= 30
                                            ? "FLAGGED"
                                            : "CLEAR"

                                    color: game.suspicion >= 60
                                           ? "#FF6262"
                                           : game.suspicion >= 30
                                             ? "#FFC15A"
                                             : "#65D7A1"

                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#192A36"
                }

                // =================================================
                // RIGHT: CHOICES
                // =================================================

                ColumnLayout {
                    Layout.preferredWidth: 420
                    Layout.fillHeight: true
                    spacing: 12

                    Text {
                        text: "CHOOSE YOUR ACTION"
                        color: "#708293"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.5
                        Layout.bottomMargin: 4
                    }

                    Repeater {
                        model: game.choices

                        delegate: Rectangle {
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 70

                            radius: 10

                            color: choiceMouse.containsMouse
                                   ? "#173144"
                                   : "#101D28"

                            border.color: choiceMouse.containsMouse
                                          ? "#5ACCF7"
                                          : "#263947"

                            border.width: choiceMouse.containsMouse ? 1.5 : 1

                            scale: choiceMouse.pressed ? 0.985 : 1

                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 70
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 18
                                spacing: 13

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: choiceMouse.containsMouse
                                           ? "#19465E"
                                           : "#122836"

                                    Text {
                                        anchors.centerIn: parent

                                        text: (index + 1).toString().padStart(2, "0")

                                        color: "#63D2FC"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData

                                    color: "#E3EDF5"

                                    wrapMode: Text.WordWrap

                                    font.pixelSize: 15
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: "›"

                                    color: choiceMouse.containsMouse
                                           ? "#FFFFFF"
                                           : "#647989"

                                    font.pixelSize: 28
                                }
                            }

                            MouseArea {
                                id: choiceMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    scenePanel.opacity = 0.82
                                    game.choose(index)
                                    scenePanel.opacity = 1
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52

                        radius: 9
                        color: "#0D1923"
                        border.color: "#1D303E"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14

                            Text {
                                text: "TIP"
                                color: "#5CCDF6"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                Layout.fillWidth: true

                                text: "Every choice can affect time, stress, or suspicion."

                                color: "#758798"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }

    // =============================================================
    // REUSABLE STATUS BLOCK
    // =============================================================

    component StatusBlock: ColumnLayout {
        property string title: ""
        property string valueText: ""
        property real value: 0

        property bool warning: false
        property bool danger: false

        spacing: 8

        Text {
            text: title

            color: "#708092"

            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 1.3
        }

        Text {
            text: valueText

            color: danger
                   ? "#FF5E5E"
                   : warning
                     ? "#FFC05A"
                     : "#F4F8FC"

            font.pixelSize: 25
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6

            radius: 3
            color: "#182935"

            Rectangle {
                height: parent.height

                width: parent.width * value

                radius: 3

                color: danger
                       ? "#FF5E5E"
                       : warning
                         ? "#FFC05A"
                         : "#55C9F3"

                Behavior on width {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}