import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraFa 1.0
import FontAwesomeQml 1.0
import ZeraThemeConfig 1.0

ToolButton {
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
        Item {
            anchors.fill: parent
            anchors { topMargin: parent.height * 0.35; bottomMargin: parent.height * 0.315 }
            anchors { leftMargin: parent.width * 0.1; rightMargin: parent.width * 0.175 }
            Rectangle {
                color: battery.color
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: parent.width * displayedVal / 100
            }
        }
    }
    NumberAnimation on chargeAnimationPortion {
        running: accuState.accuCharging
        loops: Animation.Infinite
        from: 0
        to: 1
        duration: 2500
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
