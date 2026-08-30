import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: homePage

    required property StackView stackView
    // ============================================================
    // COLOR PALETTE
    // ============================================================

    property color backgroundColor: "#0D1512"
    property color navbarColor: "#14211B"
    property color surfaceColor: "#1B2B23"
    property color borderColor: "#31443A"

    property color primaryColor: "#74A987"
    property color primaryHoverColor: "#8DBB9A"
    property color primaryPressedColor: "#5C8E70"

    property color accentColor: "#E3B85B"

    property color textPrimaryColor: "#EDF2EE"
    property color textSecondaryColor: "#AAB8AF"
    property color textDisabledColor: "#6F7E75"

    background: Rectangle {
        color: "#0D1512"
    }

    // ============================================================
    // MAIN WORKSPACE
    // ============================================================

    Rectangle {
        anchors.centerIn: parent

        width: 560
        height: workspaceLayout.implicitHeight + 60

        radius: 14

        color: surfaceColor

        border.color: borderColor
        border.width: 1


        ColumnLayout {
            id: workspaceLayout

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top

                margins: 30
            }

            spacing: 30


            // ====================================================
            // SLIDER
            // ====================================================

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 10


                Label {
                    text: "How much time have you got today? (in hours)"

                    color: textPrimaryColor

                    font.pixelSize: 15
                    font.bold: true
                }


                Slider {
                    id: mainSlider

                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    from: 0
                    to: 24
                    value: core.sliderValue

                    live: true

                    background: Rectangle {
                        x: mainSlider.leftPadding
                        y: mainSlider.topPadding
                        + mainSlider.availableHeight / 2
                        - height / 2

                        implicitWidth: 200
                        implicitHeight: 6

                        width: mainSlider.availableWidth
                        height: 6

                        radius: 3
                        color: borderColor

                        Rectangle {
                            width: mainSlider.visualPosition * parent.width
                            height: parent.height

                            radius: 3
                            color: primaryColor
                        }
                    }

                    handle: Rectangle {
                        x: mainSlider.leftPadding
                        + mainSlider.visualPosition
                        * (mainSlider.availableWidth - width)

                        y: mainSlider.topPadding
                        + mainSlider.availableHeight / 2
                        - height / 2

                        implicitWidth: 20
                        implicitHeight: 20

                        width: 20
                        height: 20

                        radius: 10

                        color: mainSlider.pressed
                            ? primaryPressedColor
                            : primaryColor

                        border.color: textPrimaryColor
                        border.width: 2
                    }
                }


                Label {
                    text: Math.round(mainSlider.value)

                    color: accentColor

                    font.pixelSize: 14
                    font.bold: true
                }
            }


            // ====================================================
            // DROPDOWN
            // ====================================================

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 10


                Label {
                    text: "Pick subject"

                    color: textPrimaryColor

                    font.pixelSize: 15
                    font.bold: true
                }


                ComboBox {
                    id: mainDropdown

                    Layout.fillWidth: true
                    Layout.preferredHeight: 46

                    model: dropdown
                    textRole: "display"


                    contentItem: Text {
                        leftPadding: 14

                        text: mainDropdown.displayText

                        color: textPrimaryColor
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 7

                        color: mainDropdown.hovered
                               ? "#22362C"
                               : backgroundColor

                        border.color: mainDropdown.activeFocus
                                      ? primaryColor
                                      : borderColor

                        border.width: 1
                    }


                    indicator: Label {
                        x: mainDropdown.width - width - 15

                        anchors.verticalCenter: parent.verticalCenter

                        text: "▼"

                        color: textSecondaryColor

                        font.pixelSize: 10
                    }


                    popup: Popup {
                        y: mainDropdown.height + 5

                        width: mainDropdown.width

                        implicitHeight: contentItem.implicitHeight

                        padding: 5


                        background: Rectangle {
                            radius: 7

                            color: navbarColor

                            border.color: borderColor
                            border.width: 1
                        }


                        contentItem: ListView {
                            clip: true

                            implicitHeight: contentHeight

                            model: mainDropdown.popup.visible
                                   ? mainDropdown.delegateModel
                                   : null

                            currentIndex: mainDropdown.highlightedIndex
                        }
                    }


                    delegate: ItemDelegate {
                        width: mainDropdown.width - 10
                        height: 42

                        highlighted: mainDropdown.highlightedIndex === index

                        contentItem: Text {
                            text: mainDropdown.textAt(index)

                            color: textPrimaryColor
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 5

                            color: highlighted
                                ? surfaceColor
                                : "transparent"
                        }
                    }
                }
            }


            // ====================================================
            // START STUDYING
            // ====================================================

            Button {
                id: mainButton

                Layout.fillWidth: true
                Layout.preferredHeight: 90

                text: "Start Studying"

                onClicked :{
                    core.startStudyingClicked(Math.round(mainSlider.value),mainDropdown.currentText)
                    stackView.push("study.qml")
                }


                contentItem: Text {
                    text: mainButton.text

                    color: backgroundColor

                    font.pixelSize: 18
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }


                background: Rectangle {
                    radius: 10

                    color: {
                        if (mainButton.down)
                            return primaryPressedColor

                        if (mainButton.hovered)
                            return primaryHoverColor

                        return primaryColor
                    }
                }
            }

            // ====================================================
            // NEW SUBJECT
            // ====================================================

            Button {
                id: secondaryButton

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 180
                Layout.preferredHeight: 42

                text: "New Subject"

                onClicked :{
                    core.newSubjectClicked()
                    stackView.push("newsubject.qml")
                }


                contentItem: Text {
                    text: secondaryButton.text

                    color: textPrimaryColor
                    font.pixelSize: 14
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8

                    color: secondaryButton.down
                        ? "#22362C"
                        : secondaryButton.hovered
                            ? "#263C31"
                            : backgroundColor

                    border.color: secondaryButton.hovered
                                ? primaryColor
                                : borderColor

                    border.width: 1
                }
            }
        }
    }
}