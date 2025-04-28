import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.0
import ".."

TabButton {
    id: tabButton
    property var entity
    property string baseLabel
    property bool running

    font.pointSize: tabPointSize
    height: tabHeight

    contentItem: Label {
        text: baseLabel + errMeasHelper.comparisonProgress(entity, tabButton.running && !checked)
        font.capitalization: Font.AllUppercase
        font.pointSize: tabPointSize
        height: tabHeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Material.foreground: (errMeasHelper.comparisonPass(entity) || errMeasHelper.comparisonProgress(entity, tabButton.running)) ? Material.White : Material.Red
    }
    AnimationActivity {
        targetItem: tabButton
        running: tabButton.running
    }
}
