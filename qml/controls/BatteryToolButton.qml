import QtQuick 2.0
import QtQuick.Controls 2.0
import AccumulatorState 1.0
import ZeraFa 1.0
import FontAwesomeQml 1.0

ToolButton {
    Text {
        id: battery
        font.family: FA.old
        font.pointSize: pointSize * 0.9
        color: "white"
        verticalAlignment: Text.AlignVCenter
        text: {
            if(AccuState.accumulatorStatus === 1){
                if(AccuState.accumulatorChargeValue <= 10)
                    FAQ.colorize(FAQ.fa_battery_empty, "red")
                else if(AccuState.accumulatorChargeValue >= 11 && AccuState.accumulatorChargeValue <= 40)
                    FAQ.colorize(FAQ.fa_battery_quarter, "orange")
                else if(AccuState.accumulatorChargeValue >= 41 && AccuState.accumulatorChargeValue <= 60)
                    FAQ.fa_battery_half
                else if(AccuState.accumulatorChargeValue >= 61 && AccuState.accumulatorChargeValue <= 89)
                    FAQ.fa_battery_three_quarters
                else
                    FAQ.fa_battery_full
                }
            else {
                FAQ.colorize(FAQ.fa_battery_empty, "white")
            }
        }
    }
    SequentialAnimation {
        id: chargingAnimationQuarter
        loops: Animation.Infinite
        running: AccuState.accumulatorStatus === 3 && AccuState.accumulatorChargeValue >= 0 && AccuState.accumulatorChargeValue <= 30
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_empty
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_quarter
            duration: 500
        }
    }
    SequentialAnimation {
        id: chargingAnimationHalf
        loops: Animation.Infinite
        running: AccuState.accumulatorStatus === 3 && AccuState.accumulatorChargeValue >= 31 && AccuState.accumulatorChargeValue <= 60
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_empty
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_quarter
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_half
            duration: 500
        }
    }
    SequentialAnimation {
        id: chargingAnimationThreeQuarters
        loops: Animation.Infinite
        running: AccuState.accumulatorStatus === 3 && AccuState.accumulatorChargeValue >= 61 && AccuState.accumulatorChargeValue <= 80
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_empty
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_quarter
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_half
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_three_quarters
            duration: 500
        }
    }
    SequentialAnimation {
        id: chargingAnimationFull
        loops: Animation.Infinite
        running: AccuState.accumulatorStatus === 3 && AccuState.accumulatorChargeValue >= 81
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_empty
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_quarter
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_half
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_three_quarters
            duration: 500
        }
        PropertyAnimation {
            target: battery
            property: "text"
            to: FAQ.fa_battery_full
            duration: 500
        }
    }
}
