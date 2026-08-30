import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var widgetData: ({})

    width:
        parent
        ? parent.width
        : implicitWidth

    spacing: 8


    Label {
        Layout.fillWidth: true

        text:
            root.widgetData.question
            || ""

        color: "#EDF2EE"

        font.pixelSize: 16

        wrapMode:
            Text.WordWrap
    }


    Repeater {
        model:
            root.widgetData.options
            || []


        delegate: Button {
            required property var modelData

            Layout.fillWidth: true

            Layout.preferredHeight: 42

            text: modelData


            onClicked: {
                core.session.setWidgetValue(
                    root.widgetData.widgetId,
                    modelData
                )
            }
        }
    }
}