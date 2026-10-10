import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    width: 1360
    height: 860
    minimumWidth: 1080
    minimumHeight: 720

    visible: true
    title: "BORDERLINE"

    color: "#05090D"

    property string scene: game.sceneTitle.toUpperCase()

    property bool phoneOpen: false
    property bool bagOpen: false

    property bool isArrival:
        scene.indexOf("ARRIVAL") >= 0 ||
        scene.indexOf("AIRPORT STAFF") >= 0 ||
        scene.indexOf("BATHROOM") >= 0

    property bool isImmigration:
        scene.indexOf("IMMIGRATION") >= 0 ||
        scene.indexOf("DOCUMENT") >= 0 ||
        scene.indexOf("PRIORITY") >= 0 ||
        scene.indexOf("INTERVIEW") >= 0

    property bool isSecondary:
        scene.indexOf("SECONDARY") >= 0 ||
        scene.indexOf("REFERRED") >= 0 ||
        scene.indexOf("HELD") >= 0 ||
        scene.indexOf("VERIFICATION") >= 0

    property bool isFinal:
        scene.indexOf("CONNECTION") >= 0 ||
        scene.indexOf("FINAL CALL") >= 0 ||
        scene.indexOf("MISSED") >= 0 ||
        scene.indexOf("CLEARED") >= 0

    property color sceneAccent:
        isSecondary ? "#E59B52" :
        isFinal ? "#63D89D" :
        isImmigration ? "#58C9F3" :
        "#78BFF7"

    property color sceneGlow:
        isSecondary ? "#6E351E" :
        isFinal ? "#164832" :
        isImmigration ? "#123B50" :
        "#173D59"

    // ============================================================
    // BACKGROUND
    // ============================================================

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0
                color: isSecondary ? "#17110D" :
                       isFinal ? "#08140F" :
                       "#0B1620"
            }

            GradientStop {
                position: 0.52
                color: isSecondary ? "#0D0B09" :
                       isFinal ? "#07100D" :
                       "#071019"
            }

            GradientStop {
                position: 1
                color: "#030608"
            }
        }
    }

    Rectangle {
        width: parent.width * 0.8
        height: parent.height * 0.72

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -170

        radius: width / 2

        color: sceneGlow
        opacity: 0.14
    }

    // ============================================================
    // MAIN LAYOUT
    // ============================================================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ========================================================
        // HEADER
        // ========================================================

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2

                Text {
                    text: "BORDERLINE"
                    color: "#F4F8FB"
                    font.pixelSize: 30
                    font.bold: true
                    font.letterSpacing: 4
                }

                Text {
                    text: "LAGOS  →  LONDON  →  DALLAS"
                    color: "#7D91A2"
                    font.pixelSize: 13
                    font.letterSpacing: 1.2
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text:
                    isSecondary ? "SECURITY" :
                    isFinal ? "DEPARTURES" :
                    isImmigration ? "PASSPORT CONTROL" :
                    "TRANSIT"

                color: sceneAccent
                font.pixelSize: 15
                font.bold: true
                font.letterSpacing: 1.5
            }

            Rectangle {
                width: 112
                height: 40
                radius: 8

                color: restartMouse.containsMouse
                       ? "#173043"
                       : "#101C26"

                border.color:
                    restartMouse.containsMouse
                    ? sceneAccent
                    : "#253746"

                Text {
                    anchors.centerIn: parent
                    text: "RESTART"
                    color: "#D7E0E7"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: restartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        phoneOpen = false
                        bagOpen = false
                        game.restart()
                    }
                }
            }
        }

        // ========================================================
        // HUD
        // ========================================================

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92

            radius: 14
            color: "#0D1822"
            border.color: "#1B2D3A"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 26

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "CONNECTION"
                        color: "#6E8192"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.3
                    }

                    Text {
                        text: game.connectionMinutes + " MIN"
                        color:
                            game.connectionMinutes <= 15
                            ? "#FF6262"
                            : "#F5F8FA"
                        font.pixelSize: 27
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "GATE"
                        color: "#6E8192"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.3
                    }

                    Text {
                        text: game.gate
                        color: "#F5F8FA"
                        font.pixelSize: 27
                        font.bold: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ToolButtonGame {
                    label: "PHONE"
                    iconText: "▣"
                    valueText: game.battery + "%"

                    onTriggered: {
                        bagOpen = false

                        if (!phoneOpen)
                            game.usePhone()

                        phoneOpen = !phoneOpen
                    }
                }

                ToolButtonGame {
                    label: "CARRY-ON"
                    iconText: "▰"
                    valueText:
                        game.documentRequestActive
                        ? "REQUEST"
                        : "DOCS"

                    urgent: game.documentRequestActive

                    onTriggered: {
                        phoneOpen = false
                        bagOpen = !bagOpen
                    }
                }
            }
        }

        // ========================================================
        // GAME AREA
        // ========================================================

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            // ====================================================
            // SCENE STAGE
            // ====================================================

            Rectangle {
                id: worldPanel

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 860

                radius: 18
                color: "#09131C"
                border.color: sceneGlow
                border.width: 1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 5
                    radius: 3
                    color: sceneAccent
                    opacity: 0.7
                }

                // stage background wash
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: 18
                    color:
                        isSecondary ? "#130F0C" :
                        isFinal ? "#09130F" :
                        "#0A141D"
                    opacity: 0.96
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: 24

                    // ============================================
                    // TOP TERMINAL SIGNAGE
                    // ============================================

                    Rectangle {
                        id: stageHeader
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 54

                        radius: 10
                        color: "#0D1923"
                        border.color: "#1B2E3B"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18

                            Text {
                                text:
                                    isSecondary ? "SECONDARY SCREENING" :
                                    isFinal ? "DEPARTURE CONCOURSE" :
                                    isImmigration ? "PASSPORT CONTROL" :
                                    "ARRIVALS"

                                color: sceneAccent
                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 1.6
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text:
                                    game.connectionMinutes + " MIN REMAINING"

                                color:
                                    game.connectionMinutes <= 15
                                    ? "#FF6767"
                                    : "#728595"

                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.3
                            }
                        }
                    }

                    // ============================================
                    // VISUAL STAGE
                    // ============================================

                    Item {
                        id: stageArea

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: stageHeader.bottom
                        anchors.topMargin: 18
                        anchors.bottom: dialogueBox.top
                        anchors.bottomMargin: 18

                        // ----------------------------------------
                        // ARRIVAL SCENE
                        // ----------------------------------------

                        Item {
                            anchors.fill: parent
                            visible: isArrival

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: "#0B141D"
                                border.color: "#182835"
                            }

                            // windows
                            Repeater {
                                model: 4

                                Rectangle {
                                    width: (stageArea.width - 70) / 4
                                    height: stageArea.height * 0.55
                                    x: 10 + index * (width + 12)
                                    y: 26
                                    radius: 8
                                    color: "#112230"
                                    border.color: "#233949"
                                }
                            }

                            // sky / runway glow
                            Rectangle {
                                x: 22
                                y: 42
                                width: stageArea.width - 44
                                height: stageArea.height * 0.48
                                radius: 10
                                color: "#173244"
                                opacity: 0.45
                            }

                            // airplane silhouette
                            Item {
                                x: stageArea.width * 0.62
                                y: stageArea.height * 0.18
                                width: 160
                                height: 60

                                Rectangle {
                                    x: 25
                                    y: 24
                                    width: 95
                                    height: 10
                                    radius: 5
                                    color: "#C7D8E4"
                                    opacity: 0.25
                                }

                                Rectangle {
                                    x: 80
                                    y: 18
                                    width: 45
                                    height: 8
                                    rotation: -22
                                    radius: 4
                                    color: "#C7D8E4"
                                    opacity: 0.25
                                }

                                Rectangle {
                                    x: 80
                                    y: 34
                                    width: 45
                                    height: 8
                                    rotation: 22
                                    radius: 4
                                    color: "#C7D8E4"
                                    opacity: 0.25
                                }

                                Rectangle {
                                    x: 16
                                    y: 18
                                    width: 16
                                    height: 8
                                    rotation: -30
                                    radius: 4
                                    color: "#C7D8E4"
                                    opacity: 0.25
                                }
                            }

                            // passengers
                            Repeater {
                                model: 5

                                Item {
                                    x: 60 + index * 115
                                    y: stageArea.height * 0.68
                                    width: 40
                                    height: 85

                                    Rectangle {
                                        x: 11
                                        y: 0
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: "#203949"
                                    }

                                    Rectangle {
                                        x: 7
                                        y: 18
                                        width: 26
                                        height: 42
                                        radius: 8
                                        color: "#1A2C38"
                                    }

                                    Rectangle {
                                        x: 0
                                        y: 58
                                        width: 10
                                        height: 22
                                        radius: 4
                                        color: "#1A2C38"
                                    }

                                    Rectangle {
                                        x: 30
                                        y: 58
                                        width: 10
                                        height: 22
                                        radius: 4
                                        color: "#1A2C38"
                                    }

                                    Rectangle {
                                        visible: index % 2 === 0
                                        x: 34
                                        y: 44
                                        width: 12
                                        height: 20
                                        radius: 3
                                        color: "#244557"
                                    }
                                }
                            }
                        }

                        // ----------------------------------------
                        // IMMIGRATION SCENE
                        // ----------------------------------------

                        Item {
                            anchors.fill: parent
                            visible: isImmigration

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: "#0A131C"
                                border.color: "#182835"
                            }

                            // back wall lighting
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: parent.height * 0.42
                                radius: 14
                                color: "#0F2230"
                                opacity: 0.5
                            }

                            // passport control sign
                            Rectangle {
                                x: parent.width * 0.33
                                y: 28
                                width: 240
                                height: 44
                                radius: 8
                                color: "#102B3A"
                                border.color: "#245D79"

                                Text {
                                    anchors.centerIn: parent
                                    text: "PASSPORT CONTROL"
                                    color: "#66D1FF"
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }
                            }

                            // queue posts
                            Repeater {
                                model: 4

                                Rectangle {
                                    width: 10
                                    height: 70
                                    radius: 5
                                    x: 60 + index * 95
                                    y: stageArea.height * 0.57
                                    color: "#264354"
                                }
                            }

                            Repeater {
                                model: 3

                                Rectangle {
                                    width: 95
                                    height: 4
                                    radius: 2
                                    x: 70 + index * 95
                                    y: stageArea.height * 0.62
                                    color: "#386981"
                                }
                            }

                            // officer booth
                            Rectangle {
                                x: stageArea.width * 0.53
                                y: stageArea.height * 0.18
                                width: 250
                                height: 210
                                radius: 12
                                color: "#10202C"
                                border.color: "#213A4A"
                            }

                            Rectangle {
                                x: stageArea.width * 0.57
                                y: stageArea.height * 0.23
                                width: 68
                                height: 68
                                radius: 34
                                color: "#203748"
                            }

                            Rectangle {
                                x: stageArea.width * 0.55
                                y: stageArea.height * 0.33
                                width: 110
                                height: 78
                                radius: 18
                                color: "#1B2D39"
                            }

                            // monitor
                            Rectangle {
                                x: stageArea.width * 0.73
                                y: stageArea.height * 0.27
                                width: 54
                                height: 42
                                radius: 4
                                color: "#182733"
                                border.color: "#314F64"
                            }

                            Rectangle {
                                x: stageArea.width * 0.735
                                y: stageArea.height * 0.28
                                width: 44
                                height: 26
                                radius: 2
                                color: "#163646"
                            }

                            // desk / counter
                            Rectangle {
                                x: stageArea.width * 0.38
                                y: stageArea.height * 0.52
                                width: 360
                                height: 92
                                radius: 10
                                color: "#173041"
                                border.color: "#254A5F"
                            }

                            // passport
                            Rectangle {
                                x: stageArea.width * 0.46
                                y: stageArea.height * 0.57
                                width: 48
                                height: 64
                                radius: 6
                                color: "#1F4B63"
                                border.color: "#4E88A9"
                                rotation: -8

                                Text {
                                    anchors.centerIn: parent
                                    text: "PASSPORT"
                                    color: "#DDECF7"
                                    font.pixelSize: 7
                                    font.bold: true
                                }
                            }

                            // I-20 / docs
                            Rectangle {
                                x: stageArea.width * 0.54
                                y: stageArea.height * 0.58
                                width: 66
                                height: 52
                                radius: 4
                                color: "#E8ECEE"
                                border.color: "#AEB8BF"
                                rotation: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: "I-20"
                                    color: "#2D343A"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            // player silhouette lower-left
                            Item {
                                x: stageArea.width * 0.18
                                y: stageArea.height * 0.46
                                width: 90
                                height: 150

                                Rectangle {
                                    x: 22
                                    y: 0
                                    width: 46
                                    height: 46
                                    radius: 23
                                    color: "#1E3340"
                                }

                                Rectangle {
                                    x: 8
                                    y: 40
                                    width: 74
                                    height: 90
                                    radius: 22
                                    color: "#172732"
                                }
                            }
                        }

                        // ----------------------------------------
                        // SECONDARY SCENE
                        // ----------------------------------------

                        Item {
                            anchors.fill: parent
                            visible: isSecondary

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: "#110E0C"
                                border.color: "#33251B"
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: parent.height * 0.32
                                radius: 14
                                color: "#2D1D13"
                                opacity: 0.28
                            }

                            Rectangle {
                                x: parent.width * 0.33
                                y: 22
                                width: 260
                                height: 42
                                radius: 8
                                color: "#382416"
                                border.color: "#8C5930"

                                Text {
                                    anchors.centerIn: parent
                                    text: "SECONDARY REVIEW"
                                    color: "#F0B56F"
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }
                            }

                            // desk
                            Rectangle {
                                x: parent.width * 0.28
                                y: parent.height * 0.54
                                width: 420
                                height: 92
                                radius: 10
                                color: "#3B281B"
                                border.color: "#6B462A"
                            }

                            // lamp glow
                            Rectangle {
                                x: parent.width * 0.18
                                y: parent.height * 0.12
                                width: 160
                                height: 160
                                radius: 80
                                color: "#B06A2A"
                                opacity: 0.12
                            }

                            // officer
                            Rectangle {
                                x: parent.width * 0.60
                                y: parent.height * 0.22
                                width: 58
                                height: 58
                                radius: 29
                                color: "#4A3223"
                            }

                            Rectangle {
                                x: parent.width * 0.56
                                y: parent.height * 0.31
                                width: 120
                                height: 86
                                radius: 18
                                color: "#3A291D"
                            }

                            // monitor
                            Rectangle {
                                x: parent.width * 0.73
                                y: parent.height * 0.28
                                width: 60
                                height: 44
                                radius: 4
                                color: "#201812"
                                border.color: "#785131"
                            }

                            Rectangle {
                                x: parent.width * 0.735
                                y: parent.height * 0.29
                                width: 48
                                height: 28
                                radius: 2
                                color: "#4A2B17"
                            }

                            // documents on desk
                            Rectangle {
                                x: parent.width * 0.42
                                y: parent.height * 0.58
                                width: 78
                                height: 54
                                radius: 4
                                color: "#E7DFD5"
                                border.color: "#B3A08B"
                                rotation: -4
                            }

                            Rectangle {
                                x: parent.width * 0.52
                                y: parent.height * 0.59
                                width: 52
                                height: 66
                                radius: 5
                                color: "#4A2A20"
                                border.color: "#8A5B43"
                                rotation: 6
                            }

                            // chair / player
                            Rectangle {
                                x: parent.width * 0.18
                                y: parent.height * 0.53
                                width: 90
                                height: 28
                                radius: 8
                                color: "#2A1E16"
                            }

                            Rectangle {
                                x: parent.width * 0.19
                                y: parent.height * 0.41
                                width: 36
                                height: 36
                                radius: 18
                                color: "#33261C"
                            }

                            Rectangle {
                                x: parent.width * 0.16
                                y: parent.height * 0.46
                                width: 88
                                height: 76
                                radius: 18
                                color: "#291E17"
                            }
                        }

                        // ----------------------------------------
                        // FINAL / GATE SCENE
                        // ----------------------------------------

                        Item {
                            anchors.fill: parent
                            visible: isFinal

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: "#0A1410"
                                border.color: "#193226"
                            }

                            // departure board
                            Rectangle {
                                x: 30
                                y: 24
                                width: 270
                                height: 106
                                radius: 10
                                color: "#101D17"
                                border.color: "#214231"
                            }

                            ColumnLayout {
                                x: 48
                                y: 40
                                spacing: 6

                                Text {
                                    text: "DEPARTURES"
                                    color: "#6FDBA1"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }

                                Text {
                                    text: "DFW   " + game.gate + "   BOARDING"
                                    color: "#EAF6EF"
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: "TIME REMAINING   " + game.connectionMinutes + " MIN"
                                    color: "#A8C0B1"
                                    font.pixelSize: 12
                                }
                            }

                            // corridor perspective blocks
                            Rectangle {
                                x: 70
                                y: 180
                                width: 620
                                height: 18
                                radius: 4
                                color: "#163425"
                            }

                            Rectangle {
                                x: 110
                                y: 250
                                width: 520
                                height: 16
                                radius: 4
                                color: "#1C4330"
                            }

                            Rectangle {
                                x: 150
                                y: 320
                                width: 420
                                height: 14
                                radius: 4
                                color: "#214E38"
                            }

                            // gate sign
                            Rectangle {
                                x: parent.width * 0.67
                                y: parent.height * 0.22
                                width: 170
                                height: 120
                                radius: 14
                                color: "#10261B"
                                border.color: "#2D6A4B"
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                            }

                            Text {
                                x: parent.width * 0.72
                                y: parent.height * 0.27
                                text: "GATE"
                                color: "#89E0B0"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.4
                            }

                            Text {
                                x: parent.width * 0.72
                                y: parent.height * 0.32
                                text: game.gate
                                color: "#F2FBF5"
                                font.pixelSize: 42
                                font.bold: true
                            }

                            // arrow
                            Rectangle {
                                x: parent.width * 0.57
                                y: parent.height * 0.40
                                width: 120
                                height: 8
                                radius: 4
                                color: "#67D99D"
                            }

                            Rectangle {
                                x: parent.width * 0.66
                                y: parent.height * 0.37
                                width: 24
                                height: 24
                                rotation: 45
                                color: "#67D99D"
                            }

                            // walking person
                            Item {
                                x: parent.width * 0.24
                                y: parent.height * 0.57
                                width: 48
                                height: 90

                                Rectangle {
                                    x: 13
                                    y: 0
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: "#1F3A2B"
                                }

                                Rectangle {
                                    x: 8
                                    y: 18
                                    width: 30
                                    height: 42
                                    radius: 10
                                    color: "#183022"
                                }

                                Rectangle {
                                    x: 0
                                    y: 58
                                    width: 10
                                    height: 24
                                    radius: 4
                                    color: "#183022"
                                    rotation: -10
                                }

                                Rectangle {
                                    x: 30
                                    y: 58
                                    width: 10
                                    height: 24
                                    radius: 4
                                    color: "#183022"
                                    rotation: 12
                                }
                            }
                        }
                    }

                    // ============================================
                    // DIALOGUE BOX
                    // ============================================

                    Rectangle {
                        id: dialogueBox

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 215

                        radius: 14
                        color: "#0C1822"
                        border.color: "#1C3040"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    width: sceneTagText.implicitWidth + 24
                                    height: 28
                                    radius: 6
                                    color: sceneGlow
                                    border.color: sceneAccent

                                    Text {
                                        id: sceneTagText
                                        anchors.centerIn: parent
                                        text: game.sceneTitle
                                        color: sceneAccent
                                        font.pixelSize: 10
                                        font.bold: true
                                        font.letterSpacing: 1.4
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:
                                        game.documentRequestActive
                                        ? "OFFICER IS WAITING"
                                        : "READ THE ROOM"

                                    color:
                                        game.documentRequestActive
                                        ? "#E8A25D"
                                        : "#667B8D"

                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1.2
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                text: game.story
                                color: "#ECF3F8"
                                wrapMode: Text.WordWrap
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                lineHeight: 1.3
                            }
                        }
                    }
                }
            }

            // ====================================================
            // RIGHT ACTION PANEL
            // ====================================================

            Rectangle {
                id: actionPanel

                Layout.preferredWidth: 410
                Layout.fillHeight: true

                radius: 18
                color: "#09131C"
                border.color: "#1B2E3B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 12

                    Text {
                        text:
                            game.documentRequestActive
                            ? "OFFICER REQUEST"
                            : "YOUR OPTIONS"

                        color:
                            game.documentRequestActive
                            ? "#F0B56F"
                            : "#708293"

                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Rectangle {
                        visible: game.documentRequestActive
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        radius: 12
                        color: "#18130E"
                        border.color: "#A96E38"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            Text {
                                text: "DOCUMENT REQUEST"
                                color: "#E5A25E"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.4
                            }

                            Text {
                                Layout.fillWidth: true
                                text: game.documentRequestText
                                color: "#F0E9E3"
                                wrapMode: Text.WordWrap
                                font.pixelSize: 17
                                font.bold: true
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 46
                                radius: 8
                                color:
                                    openBagMouse.containsMouse
                                    ? "#A96E38"
                                    : "#392415"

                                Text {
                                    anchors.centerIn: parent
                                    text: "OPEN CARRY-ON"
                                    color: "#FFFFFF"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                MouseArea {
                                    id: openBagMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        phoneOpen = false
                                        bagOpen = true
                                    }
                                }
                            }
                        }
                    }

                    Repeater {
                        model:
                            game.documentRequestActive
                            ? []
                            : game.choices

                        delegate: Rectangle {
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 74

                            radius: 12

                            color:
                                choiceMouse.containsMouse
                                ? sceneGlow
                                : "#101D28"

                            border.color:
                                choiceMouse.containsMouse
                                ? sceneAccent
                                : "#263947"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 14

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: "#122836"

                                    Text {
                                        anchors.centerIn: parent
                                        text: (index + 1).toString().padStart(2, "0")
                                        color: sceneAccent
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
                                    color: "#708293"
                                    font.pixelSize: 28
                                }
                            }

                            MouseArea {
                                id: choiceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: game.choose(index)
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 78
                        radius: 10
                        color: "#0D1923"
                        border.color: "#1D303E"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 6

                            Text {
                                text: "NOTE"
                                color: sceneAccent
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                Layout.fillWidth: true
                                text:
                                    game.documentRequestActive
                                    ? "Choose the correct document from your carry-on."
                                    : "Not every consequence is displayed directly."
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

    // ============================================================
    // PHONE OVERLAY
    // ============================================================

    Rectangle {
        id: phonePanel

        visible: x < window.width

        width: 390
        height: 650

        x:
            phoneOpen
            ? window.width - width - 34
            : window.width + 20

        y: 90

        radius: 30
        color: "#05090D"
        border.color: "#334451"
        border.width: 2
        z: 100

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "9:41"
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: game.battery + "%"
                    color:
                        game.battery <= 15
                        ? "#FF6767"
                        : "#FFFFFF"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1C2933"
            }

            Text {
                text: "TRAVEL"
                color: "#7E91A2"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.4
            }

            TabBar {
                id: phoneTabs
                Layout.fillWidth: true

                background: Rectangle {
                    color: "transparent"
                }

                TabButton { text: "PASS" }
                TabButton { text: "MAP" }
                TabButton { text: "WALLET" }
                TabButton { text: "MSG" }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: phoneTabs.currentIndex

                Item {
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 8
                        radius: 18
                        color: "#EDEDED"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 22

                            Text {
                                text: "BOARDING PASS"
                                color: "#161A1D"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1.6
                            }

                            Text {
                                text: "LHR  →  DFW"
                                color: "#080A0C"
                                font.pixelSize: 31
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: "#B7B7B7"
                            }

                            Text {
                                text: "GATE"
                                color: "#676767"
                                font.pixelSize: 10
                            }

                            Text {
                                text: game.gate
                                color: "#080A0C"
                                font.pixelSize: 36
                                font.bold: true
                            }

                            Text {
                                text: "Connection remaining: " + game.connectionMinutes + " minutes"
                                color: "#333333"
                                font.pixelSize: 13
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            Text {
                                text: "SAMUEL"
                                color: "#2B2B2B"
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }
                }

                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 16

                        Text {
                            text: "AIRPORT DIRECTIONS"
                            color: "#7D91A2"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1.3
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            radius: 14
                            color: "#0D1822"
                            border.color: "#1E3443"

                            Item {
                                anchors.fill: parent
                                anchors.margins: 30

                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    x: 10
                                    y: 150
                                    color: "#55D2FF"
                                }

                                Rectangle {
                                    x: 18
                                    y: 154
                                    width: 170
                                    height: 3
                                    color: "#415867"
                                }

                                Rectangle {
                                    x: 185
                                    y: 70
                                    width: 3
                                    height: 87
                                    color: "#415867"
                                }

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    x: 179
                                    y: 62
                                    color: "#68DFA6"
                                }

                                Text {
                                    x: 0
                                    y: 168
                                    text: "YOU"
                                    color: "#61D3FF"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Text {
                                    x: 205
                                    y: 55
                                    text: "GATE " + game.gate
                                    color: "#72E0A9"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }

                        Text {
                            text: game.gateWalkMinutes + " minute walk"
                            color: "#FFFFFF"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "Follow signs toward Terminal B."
                            color: "#718494"
                            font.pixelSize: 12
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "AVAILABLE CASH"
                            color: "#778B9C"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1.4
                        }

                        Text {
                            text: "$" + game.cash
                            color: "#FFFFFF"
                            font.pixelSize: 44
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            radius: 12
                            color: "#0D1822"
                            border.color: "#1C3040"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14

                                Text {
                                    text: "TRAVEL WALLET"
                                    color: "#7B8D9C"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                Text {
                                    text: "USD • Cash"
                                    color: "#DFE7EC"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Text {
                            text: "MESSAGES"
                            color: "#778B9C"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1.3
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 90
                            radius: 14
                            color: "#11202B"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 14

                                Text {
                                    text: "Family"
                                    color: "#FFFFFF"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: "Text me when you land in Dallas."
                                    color: "#9EADB8"
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                radius: 10
                color:
                    closePhoneMouse.containsMouse
                    ? "#192A37"
                    : "#101C25"

                Text {
                    anchors.centerIn: parent
                    text: "CLOSE PHONE"
                    color: "#DDE5EA"
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: closePhoneMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: phoneOpen = false
                }
            }
        }
    }

    // ============================================================
    // CARRY-ON DRAWER
    // ============================================================

    Rectangle {
        id: bagPanel

        visible: x < window.width

        width: 470
        height: window.height - 110

        x:
            bagOpen
            ? window.width - width - 34
            : window.width + 20

        y: 70

        radius: 18
        color: "#0A1117"
        border.color:
            game.documentRequestActive
            ? "#A96E38"
            : "#273947"
        border.width: 1
        z: 110

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "CARRY-ON"
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        text:
                            game.documentRequestActive
                            ? game.documentRequestText
                            : "Documents"
                        color:
                            game.documentRequestActive
                            ? "#E4A05C"
                            : "#728594"
                        font.pixelSize: 11
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 34
                    height: 34
                    radius: 17
                    color: "#14222C"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: "#B8C4CC"
                        font.pixelSize: 21
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bagOpen = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#20313C"
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: game.documentList

                        delegate: Rectangle {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 92
                            radius: 11

                            color:
                                docMouse.containsMouse
                                ? "#142633"
                                : "#101C25"

                            border.color:
                                docMouse.containsMouse
                                ? sceneAccent
                                : "#233642"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 14

                                Rectangle {
                                    width: 44
                                    height: 56
                                    radius: 5
                                    color: "#1B3342"
                                    border.color: "#315064"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "DOC"
                                        color: "#76CEF2"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        text: modelData.name
                                        color: "#F1F5F7"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.detail
                                        color: "#718594"
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Rectangle {
                                    visible: game.documentRequestActive
                                    width: 78
                                    height: 36
                                    radius: 7
                                    color:
                                        docMouse.containsMouse
                                        ? sceneAccent
                                        : "#183040"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "PRESENT"
                                        color:
                                            docMouse.containsMouse
                                            ? "#061018"
                                            : "#75D1F4"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }
                            }

                            MouseArea {
                                id: docMouse
                                anchors.fill: parent
                                hoverEnabled: true

                                cursorShape:
                                    game.documentRequestActive
                                    ? Qt.PointingHandCursor
                                    : Qt.ArrowCursor

                                onClicked: {
                                    if (game.documentRequestActive) {
                                        game.presentDocument(index)
                                        bagOpen = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ============================================================
    // BACKDROP
    // ============================================================

    Rectangle {
        anchors.fill: parent
        visible: phoneOpen || bagOpen
        color: "#000000"
        opacity: 0.28
        z: 90

        MouseArea {
            anchors.fill: parent
            onClicked: {
                phoneOpen = false
                bagOpen = false
            }
        }
    }

    Component.onCompleted: {
        phonePanel.z = 100
        bagPanel.z = 110
    }

    // ============================================================
    // REUSABLE HUD BUTTON
    // ============================================================

    component ToolButtonGame: Rectangle {
        property string label: ""
        property string iconText: ""
        property string valueText: ""
        property bool urgent: false

        signal triggered()

        Layout.preferredWidth: 145
        Layout.preferredHeight: 54

        radius: 10

        color:
            toolMouse.containsMouse
            ? "#172C3A"
            : "#111E28"

        border.color:
            urgent
            ? "#D28B4B"
            : toolMouse.containsMouse
              ? sceneAccent
              : "#263945"

        SequentialAnimation on opacity {
            running: urgent
            loops: Animation.Infinite

            NumberAnimation {
                from: 1
                to: 0.68
                duration: 650
            }

            NumberAnimation {
                from: 0.68
                to: 1
                duration: 650
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 9

            Text {
                text: iconText
                color:
                    urgent
                    ? "#E9A463"
                    : sceneAccent
                font.pixelSize: 18
            }

            ColumnLayout {
                spacing: 1

                Text {
                    text: label
                    color: "#DDE7ED"
                    font.pixelSize: 10
                    font.bold: true
                }

                Text {
                    text: valueText
                    color:
                        urgent
                        ? "#E9A463"
                        : "#718696"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        MouseArea {
            id: toolMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.triggered()
        }
    }
}