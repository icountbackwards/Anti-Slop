import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: study

    background: Rectangle {
        color: "#0D1512"
    }


    // ============================================================
    // TIMER TICKER
    // ============================================================

    Timer {
        id: timerTicker

        interval: 1000
        repeat: true
        running: core.session.running

        onTriggered: {
            core.session.tickTimer()
        }
    }


    // ============================================================
    // AI STUDY CANVAS
    // ============================================================

    Rectangle {
        id: studyCanvas

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: timerLabel.top

            topMargin: 30
            leftMargin: 40
            rightMargin: 40
            bottomMargin: 30
        }

        radius: 14

        color: "#101C17"

        border.color: "#31443A"
        border.width: 1

        clip: true


        ScrollView {
            id: canvasScroll

            anchors.fill: parent
            anchors.margins: 24

            clip: true


            ColumnLayout {
                id: canvasLayout

                width: canvasScroll.availableWidth

                spacing: 16


                // ------------------------------------------------
                // EMPTY CANVAS MESSAGE
                // ------------------------------------------------

                Label {
                    Layout.fillWidth: true

                    visible:
                        core.session.canvasModel.length === 0

                    text:
                        "Waiting for study content..."

                    color: "#6F7E75"

                    font.pixelSize: 16

                    horizontalAlignment:
                        Text.AlignHCenter
                }


                // ------------------------------------------------
                // DYNAMIC AI WIDGETS
                // ------------------------------------------------

                Repeater {
                    model: core.session.canvasModel

                    delegate: Loader {
                        id: widgetLoader

                        required property var modelData

                        Layout.fillWidth: true

                        property var widgetData: modelData

                        Layout.preferredHeight: {
                            switch (widgetData.type) {

                            case "latex":
                                return 80

                            case "text_input":
                                return 46

                            case "code_input":
                                return 220

                            case "multiple_choice":
                                return item
                                    ? item.implicitHeight
                                    : 100

                            case "button":
                                return 45

                            case "text":
                                return item
                                    ? item.implicitHeight
                                    : 30

                            default:
                                return 55
                            }
                        }

                        source: {
                            switch (widgetData.type) {

                            case "text":
                                return "widgets/TextWidget.qml"

                            case "latex":
                                return "widgets/LatexWidget.qml"

                            case "text_input":
                                return "widgets/TextInputWidget.qml"

                            case "code_input":
                                return "widgets/CodeInputWidget.qml"

                            case "multiple_choice":
                                return "widgets/MultipleChoiceWidget.qml"

                            case "button":
                                return "widgets/ButtonWidget.qml"

                            default:
                                return "widgets/UnknownWidget.qml"
                            }
                        }

                        onLoaded: {
                            if (item) {
                                item.widgetData = widgetData

                                console.log(
                                    "LOADED",
                                    widgetData.type,
                                    source,
                                    "loader:",
                                    width,
                                    height,
                                    "item:",
                                    item.width,
                                    item.height
                                )
                            }
                        }

                        onStatusChanged: {
                            if (status === Loader.Error) {
                                console.log(
                                    "FAILED TO LOAD:",
                                    source
                                )
                            }
                        }
                    }
                }
            }
        }
    }


    // ============================================================
    // TIMER - BOTTOM CENTER
    // ============================================================

    Label {
        id: timerLabel

        anchors.horizontalCenter:
            parent.horizontalCenter

        anchors.bottom:
            parent.bottom

        anchors.bottomMargin: 35


        text: {
            var total =
                core.session.timer

            var hours =
                Math.floor(
                    total / 3600
                )

            var minutes =
                Math.floor(
                    (total % 3600) / 60
                )

            var seconds =
                total % 60


            return String(hours)
                    .padStart(2, "0")
                    + ":"
                    + String(minutes)
                    .padStart(2, "0")
                    + ":"
                    + String(seconds)
                    .padStart(2, "0")
        }


        color:
            core.session.timer === 0
            ? "#E3B85B"
            : "#EDF2EE"

        font.pixelSize: 28
        font.bold: true
    }


    // ============================================================
    // END SESSION BUTTON
    // ============================================================

    Button {
        id: endButton

        anchors.right:
            parent.right

        anchors.bottom:
            parent.bottom

        anchors.rightMargin: 30
        anchors.bottomMargin: 30

        width: 140
        height: 45

        text: "End Session"


        contentItem: Text {
            text: endButton.text

            color: "#EDF2EE"

            font.pixelSize: 14
            font.bold: true

            horizontalAlignment:
                Text.AlignHCenter

            verticalAlignment:
                Text.AlignVCenter
        }


        background: Rectangle {
            radius: 8

            color:
                endButton.down
                ? "#382525"
                : endButton.hovered
                  ? "#2B1B1B"
                  : "#14211B"

            border.color:
                endButton.hovered
                ? "#D87575"
                : "#31443A"

            border.width: 1
        }


        onClicked: {
            core.session.endSession()

            study.StackView.view.pop()
        }
    }
}