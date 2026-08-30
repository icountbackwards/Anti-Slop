import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property var widgetData: ({})

    width:
        parent
        ? parent.width
        : 600

    height: 220

    radius: 8

    color: "#0D1512"

    border.color: "#31443A"
    border.width: 1


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 6


        Label {
            visible:
                root.widgetData.language
                !== undefined

            text:
                root.widgetData.language
                || ""

            color: "#AAB8AF"

            font.pixelSize: 12
        }


        TextArea {
            id: codeEditor

            Layout.fillWidth: true
            Layout.fillHeight: true

            text:
                root.widgetData.starterCode
                || ""

            color: "#EDF2EE"

            font.family:
                "monospace"

            font.pixelSize: 14

            wrapMode:
                TextEdit.NoWrap

            background: null


            onTextChanged: {
                if (
                    root.widgetData.widgetId
                ) {
                    core.session.setWidgetValue(
                        root.widgetData.widgetId,
                        text
                    )
                }
            }
        }
    }
}