import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0

ListView {
    id: ranges
    property var channels: []
    model: channels.length

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal
    spacing: frameMargin

    readonly property real relativeHeaderHeight: 0.5
    readonly property real relativeComboHeight: 1.2

    delegate: Item {
        id: channelItem
        width: (ranges.width - (channels.length-1)*frameMargin) / channels.length
        height: ranges.height
        readonly property string parChannelRange: "PAR_Channel"+parseInt(channels[index])+"Range"

        Label {
            id: label
            anchors.left: parent.left
            anchors.top: parent.top
            height: rowHeight * relativeHeaderHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignBottom
            text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo[parChannelRange].ChannelName) + ":"
            color: FT.getColorByIndex(channels[index], root.groupingActive)
        }
        VFComboBox {
            id: rangeCombo
            height: rowHeight * relativeComboHeight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: label.bottom

            // To flash once only we set model only on content change
            // because metadata is JSON and that reports change on all channels
            flashOnContentChange: true
            readonly property var validationData: ModuleIntrospection.rangeIntrospection.ComponentInfo[parChannelRange].Validation.Data
            property string validdationDataStr
            onValidationDataChanged: {
                let newValidationData = JSON.stringify(validationData)
                if(validdationDataStr !== newValidationData) {
                    validdationDataStr = newValidationData
                    model = validationData
                }
            }

            arrayMode: true
            entity: VeinEntity.getEntity("RangeModule1")
            controlPropertyName: parChannelRange
            contentMaxRows: 5
            centerVertical: true
            enabled: true // TODO
        }
        SimpleAndCheapVu {
            id: vu
            anchors.top : rangeCombo.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            horizontal: true
            nominal: 100
            overshootFactor: 1.25
            actual: 122
        }
    }
}
