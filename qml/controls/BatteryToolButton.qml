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
            if(AccuState.accumulatorStatusText === "1"){
                if(AccuState.accumulatorSocText <= 10)
                    FAQ.colorize(FAQ.fa_battery_empty, "red")
                else if(AccuState.accumulatorSocText >= 11 && AccuState.accumulatorSocText <= 40)
                    FAQ.colorize(FAQ.fa_battery_quarter, "orange")
                else if(AccuState.accumulatorSocText >= 41 && AccuState.accumulatorSocText <= 60)
                    FAQ.fa_battery_half
                else if(AccuState.accumulatorSocText >= 61 && AccuState.accumulatorSocText <= 89)
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
        running: AccuState.accumulatorStatusText === "3" && AccuState.accumulatorSocText >= 0 && AccuState.accumulatorSocText <= 30
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
        running: AccuState.accumulatorStatusText === "3" && AccuState.accumulatorSocText >= 31 && AccuState.accumulatorSocText <= 60
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
        running: AccuState.accumulatorStatusText === "3" && AccuState.accumulatorSocText >= 61 && AccuState.accumulatorSocText <= 80
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
        running: AccuState.accumulatorStatusText === "3" && AccuState.accumulatorSocText >= 81
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
