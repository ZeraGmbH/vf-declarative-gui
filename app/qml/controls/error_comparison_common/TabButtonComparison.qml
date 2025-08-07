import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraThemeConfig 1.0
import ".."

TabButton {
    id: tabButton
    property var entity
    property string baseLabel
    property bool running

    contentItem: Label {
        text: baseLabel + errMeasHelper.comparisonProgress(entity, tabButton.running && !checked)
        font.capitalization: Font.AllUppercase
        font.pointSize: tabPointSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Material.foreground: {
            if (tabButton.checked)
                return ZTC.accentColor
            if (errMeasHelper.comparisonPass(entity) || errMeasHelper.comparisonProgress(entity, tabButton.running))
                return ZTC.primaryTextColor
            return Material.Red
        }
    }
    AnimationActivity {
        targetItem: tabButton
        running: tabButton.running
    }
}
