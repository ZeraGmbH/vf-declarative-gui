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

    property real currentBrightness: getCurrentBrightness(ZTC.isDarkTheme)
    function setCurrentBrightness(brightness, isDarkTheme) {
        currentBrightness = brightness
        let settingsKey = isDarkTheme ? "currentBrightness" : "currentBrightnessLight"
        Settings.setOption(settingsKey, brightness)
        brightnessChangeCount++
    }
    property real whiteBrightness: getWhiteBrightness(ZTC.isDarkTheme)
    function setWhiteBrightness(brightness, isDarkTheme) {
        whiteBrightness = brightness
        let settingsKey = isDarkTheme ? "whiteBrightness" : "whiteBrightnessLight"
        Settings.setOption(settingsKey, brightness)
        brightnessChangeCount++
    }
    property real blackBrightness: getBlackBrightness(ZTC.isDarkTheme)
    function setBlackBrightness(brightness, isDarkTheme) {
        blackBrightness = brightness
        let settingsKey = isDarkTheme ? "blackBrightness" : "blackBrightnessLight"
        Settings.setOption(settingsKey, brightness)
        brightnessChangeCount++
    }
    function restoreDefaultBrighnesses() {
        setCurrentBrightness(getDefaultCurrentBrightness(ZTC.isDarkTheme), ZTC.isDarkTheme)
        setWhiteBrightness(getDefaultWhiteBrightness(ZTC.isDarkTheme), ZTC.isDarkTheme)
        setBlackBrightness(getDefaultBlackBrightness(ZTC.isDarkTheme), ZTC.isDarkTheme)
    }

    function getDefaultColor(colorIdx, channel, isDarkTheme) {
        let dummy = brightnessChangeCount // trigger on change
        function colorCurrent(baseColor) {
            return Qt.lighter(baseColor, getCurrentBrightness(isDarkTheme))
        }
        function colorWhite(baseColor) {
            return Qt.lighter(baseColor, getWhiteBrightness(isDarkTheme))
        }
        function colorBlack(baseColor) {
            return Qt.lighter(baseColor, getBlackBrightness(isDarkTheme))
        }
        let baseBlue    = "#EE0092ff"
        var baseBrown   = "#EE9b5523"
        var baseGreen   = "#FF04b007"//"#EE00C000"
        var basePurple  = "#EEE000E0"
        var baseRed     = "#EEff0000"
        var baseYellow  = isDarkTheme ? "#ffe0e000" : "#FFd0c800" //"#EEffff00"

        var baseWhite   = "#ffffffff" // white is opposite
        var baseWhite2  = "#EEA0A0A0"//"#FF808080"

        var baseGrey    = "#EEB0B0B0"
        var baseGrey2   = "#EEffffff"

        var baseBlack   = "#EE080808"
        var baseBlack2  = "#EE707070"

        var colorTable =
                [
                    // sorting is odd (historical..): U1 / U2 / U3 / I1 /I2 / I3 / UAux / IAux
                    // 0: International
                    [ baseRed, baseYellow, baseBlue, colorCurrent(baseRed), colorCurrent(baseYellow), colorCurrent(baseBlue), colorBlack(baseBlack), colorCurrent(baseBlack2) ],
                    // 1: Austria/Germany
                    [ baseYellow, baseGreen, basePurple, colorCurrent(baseYellow), colorCurrent(baseGreen), colorCurrent(basePurple), colorWhite(baseWhite), colorCurrent(baseWhite2) ],
                    // 2: France
                    [ baseBrown, colorBlack(baseBlack), baseRed, colorCurrent(baseBrown), colorCurrent(baseBlack2), colorCurrent(baseRed), baseBlue, colorCurrent(baseBlue) ],
                    // 3: Norway/Denmark
                    [ colorBlack(baseBlack), baseBrown, baseGrey, colorCurrent(baseBlack2), colorCurrent(baseBrown), colorCurrent(baseGrey2), baseBlue, colorCurrent(baseBlue) ],
                    // 4: Sweden
                    [ baseBrown, colorBlack(baseBlack), colorWhite(baseWhite), colorCurrent(baseBrown), colorCurrent(baseBlack2), colorCurrent(baseWhite2), baseBlue, colorCurrent(baseBlue) ],
                    // 5: China
                    [ baseYellow, baseGreen, baseRed, colorCurrent(baseYellow), colorCurrent(baseGreen), colorCurrent(baseRed), colorBlack(baseBlack), colorCurrent(baseBlack2) ],
                    // 6: Hongkong
                    [ baseBrown, colorBlack(baseBlack), baseGrey, colorCurrent(baseBrown), colorCurrent(baseBlack2), colorCurrent(baseGrey2), baseBlue, colorCurrent(baseBlue) ],
               ]
        return colorTable[colorIdx][channel]
    }
    readonly property int colorSetCount: 7

    function setSystemColorByIndex(index, color, isDarkTheme) {
        let settingsKey = isDarkTheme ? arrayJsonColorNames[index] : arrayJsonColorNamesLight[index]
        Settings.setOption(settingsKey, color)
        colorChangeCount++
    }

    function setSystemDefaultColors(defaultEntry, isDarkTheme) {
        for(let index=0; index<initialColorTable.length; ++index)
            setSystemColorByIndex(index, getDefaultColor(defaultEntry, index, isDarkTheme), isDarkTheme)
    }

    // Looks nice often so no option for default group colors
    readonly property color groupColorReference: Settings.getOption("groupColor3", "darkorange")

    /////////////////////////////////////////////////////////////////////////////
    // private

    Component.onCompleted: {
        ZTC.materialTheme = parseInt(Settings.getOption("material_theme", Material.Dark))
    }

    property int colorChangeCount: 0
    property int brightnessChangeCount: 0
    function getInitialColorByIndex(idx) {
        let dummy = colorChangeCount // refresh on change
        let settingsKey = ZTC.isDarkTheme ? arrayJsonColorNames[idx] : arrayJsonColorNamesLight[idx]
        return Settings.getOption(settingsKey, initialColorTable[idx])
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
    readonly property var arrayJsonColorNamesLight:
        ["colorUL1Light",     // 1
        "colorUL2Light",     // 2
        "colorUL3Light",     // 3
        "colorIL1Light",     // 4
        "colorIL2Light",     // 5
        "colorIL3Light",     // 6
        "colorUAux1Light",   // 7
        "colorIAux1Light"]  // 8

    function getDefaultCurrentBrightness(isDarkTheme) { return isDarkTheme ? 1.75 : 0.63 }
    function getDefaultWhiteBrightness(isDarkTheme) { return isDarkTheme ? 0.7 : 0.1 }
    function getDefaultBlackBrightness(isDarkTheme) { return isDarkTheme ? 35 : 1 }

    readonly property string baseBlue:   "#EE0092ff"
    readonly property string baseBrown:  "#EE9b5523"
    readonly property string baseGreen:  "#FF04b007"//"#EE00C000"
    readonly property string basePurple: "#EEE000E0"
    readonly property string baseRed:    "#EEff0000"
    readonly property string baseYellow: ZTC.isDarkTheme ? "#ffe0e000" : "#FFd0c800" //"#EEffff00"

    readonly property string baseWhite:  "#ffffffff" // white is opposite
    readonly property string baseWhite2: "#EEA0A0A0"//"#FF808080"

    readonly property string baseGrey:   "#EEB0B0B0"
    readonly property string baseGrey2:  "#EEffffff"

    readonly property string baseBlack:  "#EE080808"
    readonly property string baseBlack2: "#EE707070"
    readonly property var initialColorTable: {
        function colorCurrent(baseColor) {
            return Qt.lighter(baseColor, getDefaultCurrentBrightness(ZTC.isDarkTheme))
        }
        function colorBlack(baseColor) {
            return Qt.lighter(baseColor, getDefaultBlackBrightness(ZTC.isDarkTheme))
        }
        // sorting is odd (historical..): U1 / U2 / U3 / I1 /I2 / I3 / UAux / IAux
        // 0: International
        return [ baseRed, baseYellow, baseBlue, colorCurrent(baseRed), colorCurrent(baseYellow), colorCurrent(baseBlue), colorBlack(baseBlack), colorCurrent(baseBlack2) ]
    }

    function getCurrentBrightness(isDarkTheme) {
        let settingsKey = isDarkTheme ? "currentBrightness" : "currentBrightnessLight"
        return parseFloat(Settings.getOption(settingsKey, getDefaultCurrentBrightness(isDarkTheme)))
    }
    function getWhiteBrightness(isDarkTheme) {
        let settingsKey = isDarkTheme ? "whiteBrightness" : "whiteBrightnessLight"
        return parseFloat(Settings.getOption(settingsKey, getDefaultWhiteBrightness(isDarkTheme)))
    }
    function getBlackBrightness(isDarkTheme) {
        let settingsKey = isDarkTheme ? "blackBrightness" : "blackBrightnessLight"
        return parseFloat(Settings.getOption(settingsKey, getDefaultBlackBrightness(isDarkTheme)))
    }
    readonly property bool isDarkThemeForChangeOnly: ZTC.isDarkTheme
    onIsDarkThemeForChangeOnlyChanged: {
        currentBrightness = getCurrentBrightness(ZTC.isDarkTheme)
        whiteBrightness = getWhiteBrightness(ZTC.isDarkTheme)
        blackBrightness = getBlackBrightness(ZTC.isDarkTheme)
    }

}
