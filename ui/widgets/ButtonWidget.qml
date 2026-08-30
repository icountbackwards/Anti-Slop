import QtQuick
import QtQuick.Controls

Button {
    id: root

    property var widgetData: ({})

    width: 180
    height: 45

    text:
        widgetData.text || "Button"


    contentItem: Text {
        text: root.text

        color: "#0D1512"

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
            root.down
            ? "#5C8E70"
            : root.hovered
              ? "#8DBB9A"
              : "#74A987"
    }


    onClicked: {
        if (widgetData.widgetId) {
            core.session.widgetAction(
                widgetData.widgetId
            )
        }
    }
}