import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: resultPage

    required property string subjectName
    required property var topics
    required property var resources

    background: Rectangle {
        color: "#0D1512"
    }


    // ============================================================
    // SCROLLABLE RESULTS
    // ============================================================

    ScrollView {
        id: scrollView

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: homeButton.top

            topMargin: 20
            leftMargin: 35
            rightMargin: 35
            bottomMargin: 20
        }

        clip: true


        ColumnLayout {
            width: scrollView.availableWidth

            spacing: 20


            // ====================================================
            // RESULTS CARD
            // ====================================================

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: resultsLayout.implicitHeight + 60

                radius: 14

                color: "#1B2B23"

                border.color: "#31443A"
                border.width: 1


                ColumnLayout {
                    id: resultsLayout

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top

                        margins: 30
                    }

                    spacing: 18


                    // ============================================
                    // TITLE
                    // ============================================

                    Label {
                        text: "Subject Created"

                        color: "#74A987"

                        font.pixelSize: 24
                        font.bold: true
                    }


                    // ============================================
                    // SUBJECT NAME
                    // ============================================

                    Label {
                        text: "Subject Name"

                        color: "#AAB8AF"

                        font.pixelSize: 13
                    }


                    Label {
                        Layout.fillWidth: true

                        text: resultPage.subjectName

                        color: "#EDF2EE"

                        font.pixelSize: 20
                        font.bold: true

                        wrapMode: Text.WordWrap
                    }


                    Rectangle {
                        Layout.fillWidth: true

                        Layout.preferredHeight: 1

                        color: "#31443A"
                    }


                    // ============================================
                    // TOPICS
                    // ============================================

                    Label {
                        text: "Topics"

                        color: "#EDF2EE"

                        font.pixelSize: 16
                        font.bold: true
                    }


                    Label {
                        visible: resultPage.topics.length === 0

                        text: "No topics generated."

                        color: "#AAB8AF"
                    }


                    Repeater {
                        model: resultPage.topics


                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 50

                            radius: 8

                            color: "#101C17"

                            border.color: "#31443A"
                            border.width: 1


                            Label {
                                anchors {
                                    fill: parent

                                    leftMargin: 16
                                    rightMargin: 16
                                }

                                text: modelData

                                color: "#EDF2EE"

                                font.pixelSize: 14

                                verticalAlignment: Text.AlignVCenter

                                wrapMode: Text.WordWrap
                            }
                        }
                    }


                    // ============================================
                    // RESOURCES
                    // ============================================

                    Label {
                        Layout.topMargin: 15

                        text: "Resources"

                        color: "#EDF2EE"

                        font.pixelSize: 16
                        font.bold: true
                    }


                    Label {
                        visible: resultPage.resources.length === 0

                        text: "No resources found."

                        color: "#AAB8AF"
                    }


                    Repeater {
                        model: resultPage.resources


                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true

                            Layout.preferredHeight:
                                resourceLayout.implicitHeight + 24

                            radius: 8

                            color: "#101C17"

                            border.color: "#31443A"
                            border.width: 1


                            RowLayout {
                                id: resourceLayout

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter

                                    leftMargin: 14
                                    rightMargin: 14
                                }

                                spacing: 12


                                // Attachment/resource icon
                                Label {
                                    text: "⌕"

                                    color: "#AAB8AF"

                                    font.pixelSize: 16
                                }


                                ColumnLayout {
                                    Layout.fillWidth: true

                                    spacing: 4


                                    // RESOURCE NAME
                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            modelData.name
                                            ? modelData.name
                                            : "Unnamed resource"

                                        color: "#EDF2EE"

                                        font.pixelSize: 14
                                        font.bold: true

                                        wrapMode: Text.WordWrap
                                    }


                                    // RESOURCE URL / PATH
                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            modelData.url
                                            ? modelData.url
                                            : ""

                                        color: "#AAB8AF"

                                        font.pixelSize: 12

                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }
                        }
                    }


                    // Space at the bottom of the card
                    Item {
                        Layout.preferredHeight: 5
                    }
                }
            }


            // Important extra space at bottom of ScrollView
            Item {
                Layout.preferredHeight: 20
            }
        }
    }


    // ============================================================
    // HOME BUTTON
    // ============================================================

    Button {
        id: homeButton

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 30
        anchors.bottomMargin: 30

        width: 130
        height: 45

        text: "← Home"


        contentItem: Text {
            text: homeButton.text

            color: "#EDF2EE"

            font.pixelSize: 14
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }


        background: Rectangle {
            radius: 8

            color:
                homeButton.down
                ? "#1B2B23"
                : homeButton.hovered
                  ? "#22362C"
                  : "#14211B"

            border.color:
                homeButton.hovered
                ? "#74A987"
                : "#31443A"

            border.width: 1
        }


        onClicked: {
            while (
                resultPage.StackView.view.depth > 1
            ) {
                resultPage.StackView.view.pop()
            }
        }
    }
}