import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    visible: true
    width: 1200
    height: 750

    title: "Antislop"

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

    color: backgroundColor


    // ============================================================
    // NAVBAR
    // ============================================================

    header: ToolBar {
        height: 64

        background: Rectangle {
            color: navbarColor

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: borderColor
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            Label {
                text: "Antislop"
                color: textPrimaryColor
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }


    // ============================================================
    // PAGE NAVIGATION
    // ============================================================

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: Home {
            stackView: stackView
        }
    }
}