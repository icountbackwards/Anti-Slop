import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property var widgetData: ({})

    width:
        parent
        ? parent.width
        : implicitWidth

    height: 55

    radius: 7

    color: "#251A1A"

    border.color: "#D87575"
    border.width: 1


    Label {
        anchors.centerIn: parent

        text:
            "Unsupported widget: "
            + (
                root.widgetData.type
                || "unknown"
            )

        color: "#D87575"

        font.pixelSize: 14
    }
}