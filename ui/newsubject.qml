import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Page {
    id: newsubject

    background: Rectangle {
        color: "#0D1512"
    }

    property var attachments: []


    FileDialog {
        id: fileDialog

        title: "Select attachments"
        fileMode: FileDialog.OpenFiles

        onAccepted: {
            var newAttachments = attachments.slice()

            for (var i = 0; i < selectedFiles.length; i++) {
                if (newAttachments.indexOf(selectedFiles[i]) === -1) {
                    newAttachments.push(selectedFiles[i])
                }
            }

            attachments = newAttachments
        }
    }


    Rectangle {
        anchors.centerIn: parent

        width: 600
        height: formLayout.implicitHeight + 60

        radius: 14

        color: "#1B2B23"

        border.color: "#31443A"
        border.width: 1


        ColumnLayout {
            id: formLayout

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 30
            }

            spacing: 20


            // ====================================================
            // SUBJECT NAME
            // ====================================================

            Label {
                text: "Subject Name"

                color: "#EDF2EE"

                font.pixelSize: 15
                font.bold: true
            }


            TextField {
                id: subjectNameInput

                Layout.fillWidth: true
                Layout.preferredHeight: 45

                placeholderText: "e.g. Calculus"

                color: "#EDF2EE"
                placeholderTextColor: "#6F7E75"

                background: Rectangle {
                    radius: 7

                    color: "#0D1512"

                    border.color: subjectNameInput.activeFocus
                                  ? "#74A987"
                                  : "#31443A"

                    border.width: 1
                }
            }


            // ====================================================
            // DESCRIPTION
            // ====================================================

            Label {
                text: "Description"

                color: "#EDF2EE"

                font.pixelSize: 15
                font.bold: true
            }


            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 160

                clip: true

                background: Rectangle {
                    radius: 7

                    color: "#0D1512"

                    border.color: descriptionInput.activeFocus
                                  ? "#74A987"
                                  : "#31443A"

                    border.width: 1
                }

                TextArea {
                    id: descriptionInput

                    placeholderText:
                        "What do you want to learn about this subject?"

                    color: "#EDF2EE"
                    placeholderTextColor: "#6F7E75"

                    wrapMode: TextArea.Wrap

                    background: null
                }
            }


            // ====================================================
            // ATTACHMENTS
            // ====================================================

            Label {
                text: "Attachments"

                color: "#EDF2EE"

                font.pixelSize: 15
                font.bold: true
            }


            Button {
                id: attachmentButton

                Layout.preferredWidth: 180
                Layout.preferredHeight: 42

                text: "+ Add Attachments"

                onClicked: {
                    fileDialog.open()
                }

                contentItem: Text {
                    text: attachmentButton.text

                    color: "#EDF2EE"

                    font.pixelSize: 14

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8

                    color: attachmentButton.hovered
                           ? "#22362C"
                           : "#14211B"

                    border.color: attachmentButton.hovered
                                  ? "#74A987"
                                  : "#31443A"

                    border.width: 1
                }
            }


            // Show number of attached files
            ColumnLayout {
                Layout.fillWidth: true
                visible: attachments.length > 0

                spacing: 6

                Label {
                    text: attachments.length + " file(s) attached"

                    color: "#AAB8AF"
                    font.pixelSize: 13
                }

                Repeater {
                    model: attachments

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 42

                        radius: 6

                        color: "#14211B"

                        border.color: "#31443A"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 12
                            anchors.rightMargin: 8

                            spacing: 10


                            // File icon
                            Label {
                                text: "📎"

                                color: "#AAB8AF"
                                font.pixelSize: 14
                            }


                            // Filename
                            Label {
                                Layout.fillWidth: true

                                // Convert URL to filename
                                text: {
                                    var path = modelData.toString()

                                    path = decodeURIComponent(path)

                                    return path.substring(
                                        path.lastIndexOf("/") + 1
                                    )
                                }

                                color: "#EDF2EE"

                                font.pixelSize: 13

                                elide: Text.ElideMiddle
                            }


                            // Remove attachment
                            Button {
                                id: removeButton

                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30

                                text: "×"

                                contentItem: Text {
                                    text: removeButton.text

                                    color: "#D87575"

                                    font.pixelSize: 18

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 5

                                    color: removeButton.hovered
                                        ? "#2B1B1B"
                                        : "transparent"
                                }

                                onClicked: {
                                    var newAttachments = attachments.slice()

                                    newAttachments.splice(index, 1)

                                    attachments = newAttachments
                                }
                            }
                        }
                    }
                }
            }

            // ====================================================
            // CREATE SUBJECT
            // ====================================================

            Button {
                id: createButton

                Layout.fillWidth: true
                Layout.preferredHeight: 55

                text: "Create Subject"

                contentItem: Text {
                    text: createButton.text

                    color: "#0D1512"

                    font.pixelSize: 16
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 9

                    color: createButton.down
                           ? "#5C8E70"
                           : createButton.hovered
                             ? "#8DBB9A"
                             : "#74A987"
                }

                onClicked: {
                    var result = core.createSubject(
                        subjectNameInput.text,
                        descriptionInput.text,
                        attachments
                    )

                    newsubject.StackView.view.push(
                        "SubjectResult.qml",
                        {
                            "subjectName": result.name,
                            "topics": result.topics,
                            "resources": result.resources
                        }
                    )
                }
            }
        }
    }


    // ============================================================
    // BACK BUTTON
    // ============================================================

    Button {
        id: backButton

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 30
        anchors.bottomMargin: 30

        width: 130
        height: 45

        text: "← Home"

        contentItem: Text {
            text: backButton.text

            color: "#EDF2EE"

            font.pixelSize: 14
            font.bold: true

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 8

            color: backButton.down
                   ? "#1B2B23"
                   : backButton.hovered
                     ? "#22362C"
                     : "#14211B"

            border.color: backButton.hovered
                          ? "#74A987"
                          : "#31443A"

            border.width: 1
        }

        onClicked: {
            newsubject.StackView.view.pop()
        }
    }
}