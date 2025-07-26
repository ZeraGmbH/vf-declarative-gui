pragma Singleton
import QtQuick 2.0
import QtQuick.Controls.Material 2.14
import ZeraSettings 1.0
import ModuleIntrospection 1.0
import MeasChannelInfo 1.0

Item {
    /////////////////////////////////////////////////////////////////////////////
    // public

    readonly property color dividerColor: Material.dividerColor //Qt.darker("darkgrey", 2.5)
    readonly property color tableShadeColor: "#003040"

    property color colorUL1: getInitialColorByIndex(0)
    property color colorUL2: getInitialColorByIndex(1)
    property color colorUL3: getInitialColorByIndex(2)
    property color colorIL1: getInitialColorByIndex(3)
    property color colorIL2: getInitialColorByIndex(4)
    property color colorIL3: getInitialColorByIndex(5)
    property color colorUAux1: getInitialColorByIndex(6)
    property color colorIAux1: getInitialColorByIndex(7)

    function getColorByIndex(idx) {
        return currentColorTable[idx]
    }

    function getColorByIndexWithReference(rangIndex) { // Index starts on 1!!!
        let channelName = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+rangIndex+"Range"].ChannelName;
        if(MeasChannelInfo.rangeGroupRef.indexOf(channelName) >= 0)
            return groupColorReference
        return currentColorTable[rangIndex-1]
    }

    property real currentBrightness: parseFloat(Settings.getOption("currentBrightness", defaultCurrentBrightness))
    function setCurrentBrigtness(brightness) {
        currentBrightness = brightness
        Settings.setOption("currentBrightness", brightness);
    }
    property real blackBrightness: parseFloat(Settings.getOption("blackBrightness", defaultBlackBrightness))
    function setBlackBrigtness(brightness) {
        blackBrightness = brightness
        Settings.setOption("blackBrightness", brightness);
    }
    function restoreDefaultBrighnesses() {
        setCurrentBrigtness(defaultCurrentBrightness)
        setBlackBrigtness(defaultBlackBrightness)
    }

    readonly property var defaultColorsTableArray: {
        function colorCurrent(baseColor) {
            return Qt.lighter(baseColor, currentBrightness)
        }
        function colorBlack(baseColor) {
            return Qt.lighter(baseColor, blackBrightness)
        }
        return [
                    // sorting is odd (historical..): U1 / U2 / U3 / I1 /I2 / I3 / UAux / IAux
                    // 0: International
                    [ baseRed, baseYellow, baseBlue, colorCurrent(baseRed), colorCurrent(baseYellow), colorCurrent(baseBlue), colorBlack(baseBlack), colorCurrent(baseBlack2) ],
                    // 1: Austria/Germany
                    [ baseYellow, baseGreen, basePurple, colorCurrent(baseYellow), colorCurrent(baseGreen), colorCurrent(basePurple), baseWhite, colorCurrent(baseWhite2) ],
                    // 2: France
                    [ baseBrown, colorBlack(baseBlack), baseRed, colorCurrent(baseBrown), colorCurrent(baseBlack2), colorCurrent(baseRed), baseBlue, colorCurrent(baseBlue) ],
                    // 3: Norway/Denmark
                    [ colorBlack(baseBlack), baseBrown, baseGrey, colorCurrent(baseBlack2), colorCurrent(baseBrown), colorCurrent(baseGrey2), baseBlue, colorCurrent(baseBlue) ],
                    // 4: Sweden
                    [ baseBrown, colorBlack(baseBlack), baseWhite, colorCurrent(baseBrown), colorCurrent(baseBlack2), colorCurrent(baseWhite2), baseBlue, colorCurrent(baseBlue) ],
                    // 5: China
                    [ baseYellow, baseGreen, baseRed, colorCurrent(baseYellow), colorCurrent(baseGreen), colorCurrent(baseRed), colorBlack(baseBlack), colorCurrent(baseBlack2) ],
                    // 6: Hongkong
                    [ baseBrown, colorBlack(baseBlack), baseGrey, colorCurrent(baseBrown), colorCurrent(baseBlack2), colorCurrent(baseGrey2), baseBlue, colorCurrent(baseBlue) ],
               ]
    }

    readonly property var currentColorTable: {
        let colorTable = []
        colorTable.push(colorUL1)
        colorTable.push(colorUL2)
        colorTable.push(colorUL3)
        colorTable.push(colorIL1)
        colorTable.push(colorIL2)
        colorTable.push(colorIL3)
        colorTable.push(colorUAux1)
        colorTable.push(colorIAux1)
        return colorTable
    }

    function setSystemColorByIndex(index, color) {
        switch(index) {
        case 1:
            colorUL1 = color
            break
        case 2:
            colorUL2 = color
            break
        case 3:
            colorUL3 = color
            break
        case 4:
            colorIL1 = color
            break
        case 5:
            colorIL2 = color
            break
        case 6:
            colorIL3 = color
            break
        case 7:
            colorUAux1 = color
            break
        case 8:
            colorIAux1 = color
            break

        }
        Settings.setOption(arrayJsonColorNames[index-1], color)
    }

    function setSystemDefaultColors(defaultEntry) {
        for(let index=0; index<initialColorTable.length; ++index) {
            setSystemColorByIndex(index+1, defaultColorsTableArray[defaultEntry][index])
        }
    }

    // Looks nice often so no option for default group colors
    readonly property color groupColorReference: Settings.getOption("groupColor3", "darkorange")

    /////////////////////////////////////////////////////////////////////////////
    // private

    function getInitialColorByIndex(idx) {
        return Settings.getOption(arrayJsonColorNames[idx], initialColorTable[idx])
    }

    readonly property var arrayJsonColorNames:
        ["colorUL1",     // 1
        "colorUL2",     // 2
        "colorUL3",     // 3
        "colorIL1",     // 4
        "colorIL2",     // 5
        "colorIL3",     // 6
        "colorUAux1",   // 7
        "colorIAux1"]  // 8

    readonly property real defaultCurrentBrightness: 1.75
    readonly property real defaultBlackBrightness: 35

    readonly property string baseBlue:   "#EE0092ff"
    readonly property string baseBrown:  "#EE9b5523"
    readonly property string baseGreen:  "#EE00C000"
    readonly property string basePurple: "#EEE000E0"
    readonly property string baseRed:    "#EEff0000"
    readonly property string baseYellow: "#EEffff00"

    readonly property string baseWhite:  "#ffffffff" // white is opposite
    readonly property string baseWhite2: "#EEA0A0A0"

    readonly property string baseGrey:   "#EEB0B0B0"
    readonly property string baseGrey2:  "#EEffffff"

    readonly property string baseBlack:  "#EE080808"
    readonly property string baseBlack2: "#EE707070"
    readonly property var initialColorTable: {
        function colorCurrent(baseColor) {
            return Qt.lighter(baseColor, defaultCurrentBrightness)
        }
        function colorBlack(baseColor) {
            return Qt.lighter(baseColor, defaultBlackBrightness)
        }
        // sorting is odd (historical..): U1 / U2 / U3 / I1 /I2 / I3 / UAux / IAux
        // 0: International
        return [ baseRed, baseYellow, baseBlue, colorCurrent(baseRed), colorCurrent(baseYellow), colorCurrent(baseBlue), colorBlack(baseBlack), colorCurrent(baseBlack2) ]
    }
}
