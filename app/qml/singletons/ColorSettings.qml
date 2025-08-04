pragma Singleton
import QtQuick 2.14
import QtQuick.Controls.Material 2.14
import ZeraSettings 1.0
import ModuleIntrospection 1.0
import MeasChannelInfo 1.0
import ZeraThemeConfig 1.0

Item {
    /////////////////////////////////////////////////////////////////////////////
    // public

    function setMaterialTheme(theme) {
        ZTC.materialTheme = theme
        Settings.setOption("material_theme", theme)
    }

    // phase colors
    property color colorUL1: getInitialColorByIndex(0)
    property color colorUL2: getInitialColorByIndex(1)
    property color colorUL3: getInitialColorByIndex(2)
    property color colorIL1: getInitialColorByIndex(3)
    property color colorIL2: getInitialColorByIndex(4)
    property color colorIL3: getInitialColorByIndex(5)
    property color colorUAux1: getInitialColorByIndex(6)
    property color colorIAux1: getInitialColorByIndex(7)

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

    function setSystemColorByIndex(index, color) {
        switch(index) {
        case 0:
            colorUL1 = color
            break
        case 1:
            colorUL2 = color
            break
        case 2:
            colorUL3 = color
            break
        case 3:
            colorIL1 = color
            break
        case 4:
            colorIL2 = color
            break
        case 5:
            colorIL3 = color
            break
        case 6:
            colorUAux1 = color
            break
        case 7:
            colorIAux1 = color
            break

        }
        Settings.setOption(arrayJsonColorNames[index], color)
    }

    function setSystemDefaultColors(defaultEntry) {
        for(let index=0; index<initialColorTable.length; ++index) {
            setSystemColorByIndex(index, defaultColorsTableArray[defaultEntry][index])
        }
    }

    // Looks nice often so no option for default group colors
    readonly property color groupColorReference: Settings.getOption("groupColor3", "darkorange")

    /////////////////////////////////////////////////////////////////////////////
    // private

    Component.onCompleted: {
        ZTC.materialTheme = parseInt(Settings.getOption("material_theme", Material.Dark))
    }

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
    readonly property real defaultCurrentBrightnessLight: 0.63
    readonly property real defaultBlackBrightnessLight: 1

    readonly property string baseBlue:   "#EE0092ff"
    readonly property string baseBrown:  "#EE9b5523"
    readonly property string baseGreen:  "#FF04b007"//"#EE00C000"
    readonly property string basePurple: "#EEE000E0"
    readonly property string baseRed:    "#EEff0000"
    readonly property string baseYellow: ZTC.isDarkTheme ? "#ffe0e000" : "#FFd0c800" //"#EEffff00"

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
