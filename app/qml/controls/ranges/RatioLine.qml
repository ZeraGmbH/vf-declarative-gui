import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraComponents 1.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import FontAwesomeQml 1.0

Item {
    property int prescalingGroup
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

    RatioPopup {
        id: ratioPopup

    }

    Label {
        id: ratioLabel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        readonly property string prescalingComponentName: "PAR_PreScalingGroup" + prescalingGroup
        readonly property bool prescalingActive: rangeModule["PAR_PreScalingEnabledGroup" + prescalingGroup]
        readonly property var nominatorDenominator: rangeModule[prescalingComponentName].split("*")[0].split("/")
        readonly property string squareRootText: {
            let str = ""

            if(rangeModule[prescalingComponentName].includes("(1/sqrt(3))"))
                str = " * 1/\u221A" + "3"
            if(rangeModule[prescalingComponentName].includes("(sqrt(3))"))
                str = " * \u221A" + "3"
            return str
        }
        text: {
            let prescaleStr = "1/1"
            if(prescalingActive) {
                let colorPrefix = ""
                let colorPostfix = ""
                if(prescalingActive) {
                    colorPrefix = "<font color='" + Qt.lighter(Material.color(Material.Amber)) + "'>"
                    colorPostfix = "</font>"
                }
                prescaleStr = colorPrefix + nominatorDenominator[0] + "/" + nominatorDenominator[1] + squareRootText + colorPostfix
            }
            return "Ratio: " + prescaleStr
        }
        font.pointSize: pointSize
        verticalAlignment: Label.AlignVCenter
    }
    ZButton {
        id: ratioButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height
        text: FAQ.fa_edit
        font.pointSize: pointSize
        onClicked: ratioPopup.open()
    }
}
