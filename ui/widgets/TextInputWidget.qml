import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property var widgetData: ({})

    implicitWidth: 600
    implicitHeight: 46

    width: parent ? parent.width : implicitWidth
    height: 46

    radius: 7

    color: "#0D1512"

    border.color: inputField.activeFocus
                  ? "#74A987"
                  : "#4E6A5A"

    border.width: 1


    TextField {
        id: inputField

        anchors.fill: parent

        leftPadding: 14
        rightPadding: 14

        placeholderText:
            root.widgetData.placeholder
            || "Enter your answer..."

        color: "#EDF2EE"

        placeholderTextColor: "#7F9286"

        font.pixelSize: 14

        background: null


        onTextChanged: {
            if (root.widgetData.widgetId) {
                core.session.setWidgetValue(
                    root.widgetData.widgetId,
                    text
                )
            }
        }
    }
}