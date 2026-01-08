import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraThemeConfig 1.0
import "../../helpers"
import ".."

TabButton {
    id: tabButton
    property var entity
    property string baseLabel
    property bool running

    EntityErrorMeasHelper { id: errMeasHelper }

    TabButton {
        id: qt5Qt6MaterialPropertyGetter
        visible: false
    }
    contentItem: Label {
        text: baseLabel + errMeasHelper.comparisonProgress(entity, running && !checked)
        font.capitalization: qt5Qt6MaterialPropertyGetter.font.capitalization
        font.pointSize: tabPointSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Label.ElideNone
        Material.foreground: {
            if (tabButton.checked)
                return ZTC.accentColor
            if (errMeasHelper.comparisonPass(entity) || errMeasHelper.comparisonProgress(entity, running))
                return ZTC.primaryTextColor
            return Material.Red
        }
    }
    AnimationActivity {
        targetItem: tabButton
        running: tabButton.running && !tabButton.checked
    }
}
