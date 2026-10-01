import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraComponents 1.0
import ZeraThemeConfig 1.0

Item {
    id: root
    // setters
    property QtObject entity
    property real visibleHeight

    visible: privProps.canChangePhases
    height: privProps.canChangePhases ? visibleHeight : 0
    width: parent.width

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: ZTC.buttonColor
        border.color: Material.dropShadowColor
        Repeater {
            id: phasesChecks
            anchors.fill: parent
            model: privProps.phaseMask
            ZCheckBox {
                visible: privProps.maxMeasSysCount > 1
                x: (root.width/3 * index)
                height: root.height
                width: root.width / privProps.measSysCount
                checked: modelData === "1"
                onCheckedChanged: phaseChange(index, checked)
            }
        }
        Repeater {
            id: phasesRadios
            anchors.fill: parent
            ZRadioButton {
                visible: privProps.maxMeasSysCount == 1
                x: (root.width/3 * index)
                height: root.height
                width: root.width / privProps.measSysCount
                readonly property int phaseNo: index
                checked: modelData === "1"
                ButtonGroup.group: radioGroup
            }
            model: privProps.phaseMask
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
        mask[phaseNo] = phaseSet ? "1" : "0"
        entity.PAR_MeasModePhaseSelect = mask.join("")
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
}
