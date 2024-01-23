import QtQuick 2.0
import QtQuick.Controls 2.0
import AccumulatorState 1.0
import ZeraFa 1.0
import FontAwesomeQml 1.0

ToolButton {
    readonly property real redLimitVal: 10
    readonly property real orangeLimitVal: 25
    readonly property real chargingMinDisplayedVal: 15
    readonly property real actValLimited: Math.max(0, Math.min(100, AccuState.accumulatorChargeValue))
    readonly property real chargingVal: Math.max(chargingMinDisplayedVal, actValLimited) * chargeAnimationVal
    readonly property real displayedVal: AccuState.accuCharging ? chargingVal : actValLimited
    Text {
        id: battery
        font.family: FA.old
        font.pointSize: pointSize * 0.9
        color: {
            if(!AccuState.accuCharging) {
                if(AccuState.accumulatorChargeValue <= redLimitVal)
                    return "red"
                else if(AccuState.accumulatorChargeValue <= orangeLimitVal)
                    return "orange"
            }
            return "white"
        }
        verticalAlignment: Text.AlignVCenter
        text: FAQ.fa_battery_empty
        Item {
            anchors.fill: parent
            anchors { topMargin: parent.height * 0.36; bottomMargin: parent.height * 0.315 }
            anchors { leftMargin: parent.width * 0.1; rightMargin: parent.width * 0.175 }
            Rectangle {
                color: battery.color
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: parent.width * displayedVal / 100
            }
        }
    }
    property real chargeAnimationVal: 0
    NumberAnimation on chargeAnimationVal {
        running: AccuState.accuCharging
        loops: Animation.Infinite
        from: 0
        to: 1
        duration: 2500
    }
}
