import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraComponents 1.0

Loader {
    id: root
    // setters
    property QtObject entity
    property real visibleHeight

    height: privProps.canChangePhases ? visibleHeight : 0
    width: parent.width
    active: privProps.canChangePhases
    sourceComponent: viewComponent

    Component {
        id: viewComponent
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: Qt.darker(Material.frameColor)
            border.color: Material.dropShadowColor
            ListView {
                anchors.fill: parent
                delegate: privProps.maxMeasSysCount > 1 ? singlePhaseDelegateCheck : singlePhaseDelegateRadio
                model: privProps.phaseMask
                orientation: ListView.Horizontal
            }
        }
    }
    QtObject {
        id: privProps
        readonly property bool canChangePhases: entity.ACT_CanChangePhaseMask
        readonly property string phaseMaskStr: String(entity.PAR_MeasModePhaseSelect)
        readonly property var phaseMask: privProps.phaseMaskStr.split('')
        readonly property int measSysCount: phaseMaskStr.length
        readonly property int maxMeasSysCount: entity.ACT_MaxMeasSysCount // common 3 / 2wire 1
    }
    // Checkbox for X-modes
    function phaseChange(phaseNo, phaseSet) {
        let mask = privProps.phaseMask
        if(phaseSet)
            mask[phaseNo] = "1"
        else
            mask[phaseNo] = "0"
        entity.PAR_MeasModePhaseSelect = mask.join("")
    }
    Component {
        id: singlePhaseDelegateCheck
        Item {
            height: root.height
            width: root.width / privProps.measSysCount
            ZCheckBox {
                anchors.fill: parent
                checked: modelData === "1"
                onCheckedChanged: phaseChange(index, checked)
            }
        }
    }
    // Radio for 2-wire modes
    ButtonGroup {
        id: radioGroup
        onClicked: {
            let phaseMaskStr = ""
            for(let i=0; i<privProps.measSysCount; ++i) {
                if(i===button.phaseNo)
                    phaseMaskStr += "1"
                else
                    phaseMaskStr += "0"
            }
            entity.PAR_MeasModePhaseSelect = phaseMaskStr
        }
    }
    Component {
        id: singlePhaseDelegateRadio
        Item {
            height: root.height
            width: root.width / privProps.measSysCount
            RadioButton {
                anchors.fill: parent
                readonly property int phaseNo: index
                checked: modelData === "1"
                ButtonGroup.group: radioGroup
            }
        }
    }
}
