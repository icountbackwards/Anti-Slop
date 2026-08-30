import QtQuick
import QtQuick.Controls

Label {
    id: root

    property var widgetData: ({})

    width:
        parent
        ? parent.width
        : implicitWidth

    text:
        widgetData.text || ""

    color: "#EDF2EE"

    font.pixelSize: 17

    wrapMode:
        Text.WordWrap
}