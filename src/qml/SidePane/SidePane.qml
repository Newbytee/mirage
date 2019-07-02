import QtQuick 2.7
import QtQuick.Layouts 1.3
import "../Base"

HRectangle {
    id: sidePane

    property int normalSpacing: 8
    property bool collapsed: false

    HColumnLayout {
        anchors.fill: parent

        AccountList {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: collapsed ? 0 : normalSpacing * 3
            topMargin: normalSpacing
            bottomMargin: normalSpacing
            Layout.leftMargin: normalSpacing

            Behavior on spacing {
                NumberAnimation { duration: HStyle.animationDuration }
            }
        }

        PaneToolBar {
            id: paneToolBar
        }
    }
}
