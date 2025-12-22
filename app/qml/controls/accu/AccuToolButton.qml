import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraFa 1.0
import FontAwesomeQml 1.0
import ZeraThemeConfig 1.0

ToolButton {
    id: accuToolButton
    enabled: false
    highlighted: false;
    visible: accuState.accuAvail
    readonly property real chargingMinDisplayedVal: 15

    property real chargeAnimationPortion: 0
    readonly property real actValLimited: Math.max(0, Math.min(100, accuState.accumulatorChargeValue))
    readonly property real chargingVal: Math.max(chargingMinDisplayedVal, actValLimited) * chargeAnimationPortion
    readonly property real displayedVal: accuState.accuCharging ? chargingVal : actValLimited
    readonly property bool accuLow: accuState.accuLowWarning || accuState.accuLowAlert
    opacity: !accuLow || lowAccuBlinker.show ? 1 : 0
    AccumulatorState { id: accuState }
    Text {
        id: battery
        font.family: FA.old
        font.pointSize: pointSize * 0.9
        color: {
            if(!accuState.accuCharging) {
                const redLimitVal = 10
                const orangeLimitVal = 20
                if(accuState.accumulatorChargeValue <= redLimitVal)
                    return Material.color(Material.Red)
                else if(accuState.accumulatorChargeValue <= orangeLimitVal)
                    return Material.color(Material.Orange)
            }
            return ZTC.primaryTextColor
        }
        verticalAlignment: Text.AlignVCenter
        text: FAQ.fa_battery_empty
        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            anchors { topMargin: parent.height * 0.35; bottomMargin: parent.height * 0.315 }
            anchors { leftMargin: parent.width * 0.1 }
            color: battery.color
            width: parent.width * 0.735 * displayedVal / 100
        }
    }
    Timer {
        id: chargeAnimationTimer
        repeat: true
        interval: 1000
        running: accuState.accuCharging
        property int iconState: 0
        onTriggered: {
            iconState++
            const maxState = 4
            if(iconState >= maxState)
                iconState = 0
            chargeAnimationPortion = iconState / (maxState-1)
        }
    }
    Timer {
        id: lowAccuBlinker
        interval: accuState.accuLowAlert ? 150 : 300
        repeat: true
        running: accuLow
        property bool show: true
        onTriggered: {
            show = !show
        }
    }

}
