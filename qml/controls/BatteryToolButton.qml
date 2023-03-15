import QtQuick 2.0
import QtQuick.Controls 2.0
import GlobalConfig 1.0
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
            if(GC.accumulatorStatusText === "1"){
                if(GC.accumulatorSocText <= 10)
                    FAQ.colorize(FAQ.fa_battery_empty, "red")
                else if(GC.accumulatorSocText >= 11 && GC.accumulatorSocText <= 40)
                    FAQ.colorize(FAQ.fa_battery_quarter, "orange")
                else if(GC.accumulatorSocText >= 41 && GC.accumulatorSocText <= 60)
                    FAQ.fa_battery_half
                else if(GC.accumulatorSocText >= 61 && GC.accumulatorSocText <= 89)
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
        running: GC.accumulatorStatusText === "3" && GC.accumulatorSocText >= 0 && GC.accumulatorSocText <= 30
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
        running: GC.accumulatorStatusText === "3" && GC.accumulatorSocText >= 31 && GC.accumulatorSocText <= 60
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
        running: GC.accumulatorStatusText === "3" && GC.accumulatorSocText >= 61 && GC.accumulatorSocText <= 80
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
        running: GC.accumulatorStatusText === "3" && GC.accumulatorSocText >= 81
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
