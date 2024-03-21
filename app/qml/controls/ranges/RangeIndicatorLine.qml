import QtQuick 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import MeasChannelInfo 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0

ListView {
    id: localRoot
    property int contentWidth
    property bool highlighted
    property int groupTrailerIdx

    interactive: false
    boundsBehavior: ListView.StopAtBounds
    orientation: Qt.Horizontal
    spacing: localRoot.contentWidth*0.1

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property real groupSizeShrinkFactor: 1

    delegate: Item {
        id: delegateItem
        readonly property int systemChannelNo: modelData // 1-based!!
        readonly property bool isGroupTrailer: systemChannelNo === groupTrailerIdx
        readonly property bool isTrailerOrNotInGroup: isGroupTrailer || !MeasChannelInfo.isGroupMember(systemChannelNo)
        width: {
            let baseWith = localRoot.contentWidth * 0.9
            if(!MeasChannelInfo.isGroupMember(systemChannelNo))
                return baseWith
            if(isGroupTrailer)
                return baseWith * (1 + localRoot.groupSizeShrinkFactor * MeasChannelInfo.groupAnimationValue)
            return baseWith * (1 - MeasChannelInfo.groupAnimationValue * localRoot.groupSizeShrinkFactor/2)
        }
        height: localRoot.height

        Label {
            width: parent.width*0.5
            font.pointSize: smallPointSize
            anchors.verticalCenter: parent.verticalCenter
            text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData)+"Range"].ChannelName)
            color: FT.getColorByIndex(modelData)
            font.bold: true
        }
        Label {
            width: parent.width*0.5
            anchors.right: parent.right
            anchors.rightMargin: {
                if(!isGroupTrailer)
                    return 0
                let baseWith = localRoot.contentWidth * 0.9
                return MeasChannelInfo.groupAnimationValue * baseWith * localRoot.groupSizeShrinkFactor
            }
            horizontalAlignment: Label.AlignRight
            font.pointSize: smallPointSize
            anchors.verticalCenter: parent.verticalCenter
            text: localRoot.rangeModule["PAR_Channel"+parseInt(modelData)+"Range"]
            color: localRoot.highlighted ? Material.accentColor : Material.primaryTextColor
            opacity: 1 - (isTrailerOrNotInGroup ? 0 : MeasChannelInfo.groupAnimationValue)
        }
        readonly property var validationData: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData)+"Range"].Validation.Data
        property string validdationDataStr
        onValidationDataChanged: {
            let newValidationData = JSON.stringify(validationData)
            if(validdationDataStr !== newValidationData) {
                validdationDataStr = newValidationData
                rangeRipple.startFlash()
            }
        }
        ZFlashingRipple {
            anchor: delegateItem
            id: rangeRipple
        }
    }
}
