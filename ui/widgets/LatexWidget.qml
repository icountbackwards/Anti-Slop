import QtQuick
import QtWebEngine

Item {
    id: root

    property var widgetData: ({})

    implicitWidth: 600
    implicitHeight: 80

    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    clip: true

    WebEngineView {
        id: webView

        anchors.fill: parent
        backgroundColor: "#101C17"
    }

    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
    }

    function renderLatex() {
        var latex = widgetData.latex || ""

        if (latex.length === 0)
            return

        var safeLatex = escapeHtml(latex)

        var html =
            "<html>" +
            "<head>" +
            "<meta charset='UTF-8'>" +

            "<script>" +
            "window.MathJax={" +
                "tex:{" +
                    "inlineMath:[['$','$']]," +
                    "displayMath:[['$$','$$']]" +
                "}," +
                "svg:{fontCache:'none'}" +
            "};" +
            "</script>" +

            "<script src='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js'></script>" +

            "<style>" +
            "html,body{" +
                "margin:0;" +
                "padding:0;" +
                "background:#101C17;" +
                "color:#EDF2EE;" +
                "overflow:hidden;" +
                "height:100%;" +
            "}" +

            "body{" +
                "display:flex;" +
                "align-items:center;" +
                "justify-content:center;" +
                "font-size:22px;" +
            "}" +

            "mjx-container{" +
                "margin:0 !important;" +
                "color:#EDF2EE !important;" +
            "}" +

            "</style>" +
            "</head>" +

            "<body>" +
                "$$" + safeLatex + "$$" +
            "</body>" +

            "</html>"

        webView.loadHtml(html)
    }

    Component.onCompleted: {
        renderLatex()
    }

    onWidgetDataChanged: {
        renderLatex()
    }
}