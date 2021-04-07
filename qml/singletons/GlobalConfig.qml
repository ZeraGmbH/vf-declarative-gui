pragma Singleton
import QtQuick 2.0
import ModuleIntrospection 1.0
import ZeraSettings 1.0
import ZeraTranslation 1.0
import VeinEntity 1.0
import ZeraComponentsConfig 1.0
import ZeraLocale 1.0
import QtQuick.VirtualKeyboard.Settings 2.2


Item {
    id: globalConfig
    /**
    * @b default configuration values and utility functions
    * @todo reimplement as QObject with Q_PROPERTY / Q_INVOKABLE to get QtCreator to code complete stuff...
    */

    /////////////////////////////////////////////////////////////////////////////
    // The JSON settings item
    //
    // IMPORTANT: ensure to wrap each call to settings.globalSettings.getOption
    // by a specific property to avoid cross property change activities: settings
    // has just one single notification for ALL settings-entries
    ZeraGlobalSettings {
        id: settings
    }

    /////////////////////////////////////////////////////////////////////////////
    // Page persistency
    readonly property bool keepPagesPesistent: parseInt(settings.globalSettings.getOption("pagePersistent", "1"))
    function setKeepPagesPesistent(persistent) {
        settings.globalSettings.setOption("pagePersistent", persistent ? 1 : 0)
        if(persistent) {
            // Avoid confusion switching on/off/on: Our page selectors might
            // highlight the page not currently selected. So store once
            setLastPageViewIndexSelected(lastPageViewIndexSelectedVolatile)
        }
    }

    readonly property string sessionNamePrefix: VeinEntity.getEntity("_System").Session.replace(".json", "-")
    property int lastPageViewIndexSelectedVolatile: 0
    readonly property int lastPageViewIndexSelected: {
        return keepPagesPesistent ?
            parseInt(settings.globalSettings.getOption(sessionNamePrefix + "pageIndex", "0")) :
            lastPageViewIndexSelectedVolatile
    }
    function setLastPageViewIndexSelected(index) {
        lastPageViewIndexSelectedVolatile = index
        if(keepPagesPesistent) {
            settings.globalSettings.setOption(sessionNamePrefix + "pageIndex", index);
        }
    }

    readonly property int lastTabSelected: {
        return keepPagesPesistent ?
            parseInt(settings.globalSettings.getOption(sessionNamePrefix + "page" + lastPageViewIndexSelected + "Tab", "0")) :
            0
    }
    function setLastTabSelected(tabNo) {
        if(keepPagesPesistent) {
            settings.globalSettings.setOption(sessionNamePrefix + "page" + lastPageViewIndexSelected + "Tab", tabNo)
        }
    }

    readonly property int lastSettingsTabSelected: {
        return keepPagesPesistent ?
            parseInt(settings.globalSettings.getOption("lastTabSettings", "0")) :
            0
    }
    function setLastSettingsTabSelected(tabNo) {
        if(keepPagesPesistent) {
            settings.globalSettings.setOption("lastTabSettings", tabNo)
        }
    }

    readonly property int lastInfoTabSelected: {
        return keepPagesPesistent ?
            parseInt(settings.globalSettings.getOption("lastTabInfo", "0")) :
            0
    }
    function setLastInfoTabSelected(tabNo) {
        if(keepPagesPesistent) {
            settings.globalSettings.setOption("lastTabInfo", tabNo)
        }
    }

    /////////////////////////////////////////////////////////////////////////////
    // Digit settings
    readonly property int digitsTotal: parseInt(settings.globalSettings.getOption("digitsTotal", "6"))
    function setDigitsTotal(digits) {
        settings.globalSettings.setOption("digitsTotal", digits);
    }

    readonly property int decimalPlaces: parseInt(settings.globalSettings.getOption("digits", "4"))
    function setDecimalPlaces(digits) {
        settings.globalSettings.setOption("digits", digits);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Aux phases
    readonly property bool showAuxPhases: parseInt(settings.globalSettings.getOption("show_aux_phases", "0"))
    function setShowAuxPhases(showAux) {
        var setValue = showAux ? 1 : 0
        settings.globalSettings.setOption("show_aux_phases", setValue);
    }

    /////////////////////////////////////////////////////////////////////////////
    // FFT specials
    readonly property int showFftTableAsRelative: parseInt(settings.globalSettings.getOption("fft_table_as_relative", "0"))
    function setShowFftTableAsRelative(isRelative) {
        var setValue = isRelative ? 1 : 0
        settings.globalSettings.setOption("fft_table_as_relative", setValue);
    }

    readonly property int showFftTablePhase: parseInt(settings.globalSettings.getOption("fft_table_show_phase", "0"))
    function setShowFftTablePhase(showPhase) {
        var setValue = showPhase ? 1 : 0
        settings.globalSettings.setOption("fft_table_show_phase", setValue);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Vector settings
    readonly property int vectorMode: parseInt(settings.globalSettings.getOption("vector_mode", "0"))
    function setVectorMode(mode) {
        settings.globalSettings.setOption("vector_mode", mode);
    }
    readonly property bool vectorShowI: parseInt(settings.globalSettings.getOption("vector_show_i", "1"))
    function setVectorShowI(show) {
        var setValue = show ? 1 : 0
        settings.globalSettings.setOption("vector_show_i", setValue);
    }
    readonly property bool vectorIecMode: parseInt(settings.globalSettings.getOption("vector_iecmode", "0"))
    function setVectorIecMode(mode) {
        settings.globalSettings.setOption("vector_iecmode", mode);
    }
    readonly property bool vectorCircleMode: parseInt(settings.globalSettings.getOption("vector_circlecmode", "0"))
    function setVectorCircleMode(mode) {
        settings.globalSettings.setOption("vector_circlecmode", mode);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Pinch settings
    readonly property real osciPinchScale: Number(settings.globalSettings.getOption("osci_pinch_scale", "3"))
    function setOsciPinchScale(scale) {
        settings.globalSettings.setOption("osci_pinch_scale", scale);
    }
    readonly property real fftChartsPinchScale: Number(settings.globalSettings.getOption("fft_charts_pinch_scale", "3"))
    function setFftChartsPinchScale(scale) {
        settings.globalSettings.setOption("fft_charts_pinch_scale", scale);
    }
    readonly property real harmonicPowerChartPinchScale: Number(settings.globalSettings.getOption("harm_power_charts_pinch_scale", "3"))
    function setHarmonicPowerChartPinchScale(scale) {
        settings.globalSettings.setOption("harm_power_charts_pinch_scale", scale);
    }


    readonly property int energyScaleSelection: parseInt(settings.globalSettings.getOption("energy_scale_selection", "1")) // 1 -> kWh
    function setEnergyScaleSelection(selection) {
        settings.globalSettings.setOption("energy_scale_selection", selection);
    }

    readonly property var rangePeakVisualisationEnum: {
        "RPV_ABSOLUTE" : 0,
        "RPV_ABSOLUTE_LOGSCALE" : 1,
        "RPV_RELATIVE_TO_LIMIT" : 2
    }

    readonly property var layoutStackEnum: {
        "layoutPageIndex": 0,
        "layoutRangeIndex": 1,
        "layoutLoggerIndex": 2,
        "layoutSettingsIndex": 3,
        "layoutStatusIndex": 4,
        "layoutSplashIndex": 5
    }


    readonly property real rangePeakVisualisation: parseInt(settings.globalSettings.getOption("range_peak_logarithmic", "2")) ///@todo rename config key?
    function setRangePeakVisualisation(rangePeakVisualisation) {
        if(typeof rangePeakVisualisation === "number"
                && rangePeakVisualisation >=0
                && rangePeakVisualisation < Object.keys(rangePeakVisualisationEnum).length) {
            settings.globalSettings.setOption("range_peak_logarithmic", rangePeakVisualisation);
        }
        else if(rangePeakVisualisationEnum[rangePeakVisualisation] !== undefined) {
            settings.globalSettings.setOption("range_peak_logarithmic", rangePeakVisualisationEnum[rangePeakVisualisation]);
        }
    }

    readonly property bool pagesGridViewDisplay: parseInt(settings.globalSettings.getOption("pages_grid_view", "1"))
    function setPagesGridViewDisplay(isGridView) {
        settings.globalSettings.setOption("pages_grid_view", isGridView ? 1 : 0);
    }

    readonly property int screenResolution: parseInt(settings.globalSettings.getOption("screen_resolution", "0"))
    function setScreenResolution(resolution) {
        settings.globalSettings.setOption("screen_resolution", resolution);
    }

    readonly property bool showVirtualKeyboard: parseInt(settings.globalSettings.getOption("show_virtual_keyboard", "1"))
    function setShowVirtualKeyboard(show) {
        settings.globalSettings.setOption("show_virtual_keyboard", show ? 1 : 0);
    }


    /////////////////////////////////////////////////////////////////////////////
    // Common standard margins

    readonly property real standardMarginWithMin: 1
    readonly property real standardTextHorizMargin: 8
    readonly property real standardTextBottomMargin: 8
    readonly property real standardComboContentScale: 1.2
    property real vkeyboardHeight: 0

    /////////////////////////////////////////////////////////////////////////////
    // Color settings...

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
    readonly property real currentBrightness: parseFloat(settings.globalSettings.getOption("currentBrightness", defaultCurrentBrightness))
    function setCurrentBrigtness(brightness) {
        settings.globalSettings.setOption("currentBrightness", brightness);
    }
    readonly property real defaultBlackBrightness: 1
    readonly property real blackBrightness: parseFloat(settings.globalSettings.getOption("blackBrightness", defaultBlackBrightness))
    function setBlackBrigtness(brightness) {
        settings.globalSettings.setOption("blackBrightness", brightness);
    }
    function restoreDefaultBrighnesses() {
        setCurrentBrigtness(defaultCurrentBrightness)
        setBlackBrigtness(defaultBlackBrightness)
    }

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
        settings.globalSettings.setOption(arrayJsonColorNames[index-1], color);
    }

    function setSystemDefaultColors(defaultEntry) {
        for(let index=0; index<initialColorTable.length; ++index) {
            setSystemColorByIndex(index+1, defaultColorsTableArray[defaultEntry][index])
        }
    }

    readonly property color colorUL1: settings.globalSettings.getOption(arrayJsonColorNames[0], initialColorTable[0])
    readonly property color colorUL2: settings.globalSettings.getOption(arrayJsonColorNames[1], initialColorTable[1])
    readonly property color colorUL3: settings.globalSettings.getOption(arrayJsonColorNames[2], initialColorTable[2])
    readonly property color colorIL1: settings.globalSettings.getOption(arrayJsonColorNames[3], initialColorTable[3])
    readonly property color colorIL2: settings.globalSettings.getOption(arrayJsonColorNames[4], initialColorTable[4])
    readonly property color colorIL3: settings.globalSettings.getOption(arrayJsonColorNames[5], initialColorTable[5])
    readonly property color colorUAux1: settings.globalSettings.getOption(arrayJsonColorNames[6], initialColorTable[6])
    readonly property color colorIAux1: settings.globalSettings.getOption(arrayJsonColorNames[7], initialColorTable[7])

    readonly property color groupColorVoltage: settings.globalSettings.getOption("groupColor1", "lightskyblue")
    readonly property color groupColorCurrent: settings.globalSettings.getOption("groupcurrentColor", "lawngreen")
    readonly property color groupColorReference: settings.globalSettings.getOption("groupColor3", "darkorange")

    readonly property color tableShadeColor: "#003040"

    /////////////////////////////////////////////////////////////////////////////
    // Auto scale

    /* Settings/autoScaleLimit: A float number to set at which limit the value
     changes and unit is prefixed e.g for autoScaleLimit=1.2 value >= 1200 is
     changed to 1.2k */

    readonly property real autoScaleLimit: parseFloat(settings.globalSettings.getOption("auto_scale_limit", "1.0"))
    function setAutoScaleLimit(limit) {
        if(typeof limit === "string") {
            settings.globalSettings.setOption("auto_scale_limit", limit);
        }
        else  {
            settings.globalSettings.setOption("auto_scale_limit", formatNumber(limit, 3));
        }
    }



    /////////////////////////////////////////////////////////////////////////////
    // This is the central place to distitibute locale change
    function setLocale(newLocaleStr, writeSettings) {
        Z.changeLanguage(newLocaleStr);
        VirtualKeyboardSettings.locale = newLocaleStr
        ZLocale.localeName = newLocaleStr
        if(writeSettings) {
            settings.globalSettings.setOption("locale", newLocaleStr);
        }
    }

    /////////////////////////////////////////////////////////////////////////////
    // GUI context settings (TODO replace getter functions?)
    readonly property var guiContextEnum: { // Note the sequence is used in some places
        "GUI_ACTUAL_VALUES"             : { value: 0,  name: "ZeraGuiActualValues" },
        "GUI_VECTOR_DIAGRAM"            : { value: 1,  name: "ZeraGuiVectorDiagramm" },
        "GUI_POWER_VALUES"              : { value: 2,  name: "ZeraGuiPowerValues" },
        "GUI_RMS_VALUES"                : { value: 3,  name: "ZeraGuiRMSValues" },

        "GUI_HARMONIC_TABLE"            : { value: 4,  name: "ZeraGuiHarmonicTable" },
        "GUI_HARMONIC_CHART"            : { value: 5,  name: "ZeraGuiHarmonicChart" },
        "GUI_CURVE_DISPLAY"             : { value: 6,  name: "ZeraGuiCurveDisplay" },

        "GUI_HARMONIC_POWER_TABLE"      : { value: 7,  name: "ZeraGuiHarmonicPowerTable" },
        "GUI_HARMONIC_POWER_CHART"      : { value: 8,  name: "ZeraGuiHarmonicPowerChart" },

        "GUI_METER_TEST"                : { value: 9,  name: "ZeraGuiMeterTest" },
        "GUI_ENERGY_COMPARISON"         : { value: 10, name: "ZeraGuiEnergyComparison" },
        "GUI_ENERGY_REGISTER"           : { value: 11, name: "ZeraGuiEnergyRegister" },
        "GUI_POWER_REGISTER"            : { value: 12, name: "ZeraGuiPowerRegister" },

        "GUI_VOLTAGE_BURDEN"            : { value: 13, name: "ZeraGuiVoltageBurden" },
        "GUI_CURRENT_BURDEN"            : { value: 14, name: "ZeraGuiCurrentBurden" },

        "GUI_INSTRUMENT_TRANSFORMER"    : { value: 15, name: "ZeraGuiInstrumentTransformer" },

        "GUI_CED_POWER"                 : { value: 16, name: "ZeraGuiCEDPower" },
        "GUI_DC_REFERENCE"              : { value: 17, name: "ZeraGuiDCReference" },
    }
    readonly property var contentTypeEnum: {
        "CONTENT_TYPE_CONTEXT": 0,
        "CONTENT_TYPE_ALL": 1,
        "CONTENT_TYPE_CUSTOM": 2
    }

    property var currentGuiContext
    /*onCurrentGuiContextChanged: { // uncomment for test
        console.info(currentGuiContext.name)
    }*/

    function getDefaultDbContentSet(guiContext) {
        var contentSetLists = getDefaultDbContentSetLists(guiContext)
        return contentSetLists.length > 0 ? contentSetLists[0] : ""
    }
    // return list of matching db
    function getDefaultDbContentSetLists(guiContext) {
        var dbContentSetList = []
        switch(guiContext) {
        case guiContextEnum.GUI_ACTUAL_VALUES:
        case guiContextEnum.GUI_VECTOR_DIAGRAM:
        case guiContextEnum.GUI_POWER_VALUES:
        case guiContextEnum.GUI_RMS_VALUES:
        case guiContextEnum.GUI_CED_POWER:
            if(addDbContentSet(dbContentSetList, "ZeraActualValues") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
            break
        case guiContextEnum.GUI_HARMONIC_TABLE:
        case guiContextEnum.GUI_HARMONIC_CHART:
        case guiContextEnum.GUI_HARMONIC_POWER_TABLE:
        case guiContextEnum.GUI_HARMONIC_POWER_CHART:
            if(addDbContentSet(dbContentSetList, "ZeraHarmonics") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
            break
        case guiContextEnum.GUI_CURVE_DISPLAY:
            if(addDbContentSet(dbContentSetList, "ZeraCurves") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
            break
        case guiContextEnum.GUI_METER_TEST:
        case guiContextEnum.GUI_ENERGY_COMPARISON:
        case guiContextEnum.GUI_ENERGY_REGISTER:
        case guiContextEnum.GUI_POWER_REGISTER:
            if(addDbContentSet(dbContentSetList, "ZeraComparison") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
            break
        case guiContextEnum.GUI_VOLTAGE_BURDEN:
        case guiContextEnum.GUI_CURRENT_BURDEN:
            if(addDbContentSet(dbContentSetList, "ZeraBurden") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
            break
        case guiContextEnum.GUI_INSTRUMENT_TRANSFORMER:
            if(addDbContentSet(dbContentSetList, "ZeraTransformer") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
            break
        case guiContextEnum.GUI_DC_REFERENCE:
            // For DC reference other values do not make sense
            addDbContentSet(dbContentSetList, "ZeraDCReference")
            break
        }
        return dbContentSetList
    }
    function dbContentSetsFromContext(guiContext) {
        var contentSets = ""
        if(guiContext !== undefined) {
            switch(loggerContentType) {
            case contentTypeEnum.CONTENT_TYPE_CONTEXT:
                contentSets = getDefaultDbContentSet(guiContext)
                break;
            case contentTypeEnum.CONTENT_TYPE_ALL:
                contentSets = "ZeraAll"
                break;
            case contentTypeEnum.CONTENT_TYPE_CUSTOM:
                contentSets = getLoggerCustomContentSets()
                break;
            }
        }
        return contentSets
    }
    readonly property int loggerContentType: parseInt(settings.globalSettings.getOption("logger_content_type", contentTypeEnum.CONTENT_TYPE_CONTEXT))
    function setLoggerContentType(contentType) {
        settings.globalSettings.setOption("logger_content_type", contentType);
    }

    // custom contentSets
    readonly property string loggerCustomContentSets: settings.globalSettings.getOption("logger_custom_content_sets", "")
    function setLoggerCustomContentSets(customContentSets) {
        settings.globalSettings.setOption("logger_custom_content_sets", customContentSets)
    }
    function getLoggerCustomContentSets(addDefaultFormGui=true) {
        var contentSets = loggerCustomContentSets
        if(addDefaultFormGui) {
            var defaultGuiContentSet = getDefaultDbContentSet(currentGuiContext)
            if(defaultGuiContentSet !== '' && !contentSets.includes(defaultGuiContentSet)) {
                if(contentSets === '') {
                    contentSets = defaultGuiContentSet
                }
                else {
                    contentSets = defaultGuiContentSet + ',' + contentSets
                }
            }
        }
        return contentSets
    }

    // internal helper: append available only db-content-set
    function addDbContentSet(dbContentSetList, dbContentSet) {
        var added = false
        var availableDBContentSets = VeinEntity.hasEntity("_LoggingSystem") ? VeinEntity.getEntity("_LoggingSystem").availableContentSets : []
        if(dbContentSet === "ZeraCustom" || availableDBContentSets.includes(dbContentSet)) {
            dbContentSetList.push(dbContentSet)
            added = true
        }
        return added
    }

    /////////////////////////////////////////////////////////////////////////////
    // Inform entities periodically, that they have a GUI currently visible
    // Background: Entities not visible can e.g slow down their actualize timers
    // to save processing time/energy
    Timer {
        id: topmostNotifier
        repeat: true
        triggeredOnStart: true

        property string currentNotifyEntities

        // internal
        readonly property var guiContext: currentGuiContext
        onGuiContextChanged: {
            stop()
            currentNotifyEntities = ""
            switch(guiContext) {
            case guiContextEnum.GUI_METER_TEST:
                currentNotifyEntities = "SEC1Module1"
                interval = 1000
                break;
            case guiContextEnum.GUI_ENERGY_COMPARISON:
                currentNotifyEntities = "SEC1Module2"
                interval = 1000
                break;
            case guiContextEnum.GUI_ENERGY_REGISTER:
                currentNotifyEntities = "SEM1Module1"
                interval = 1000
                break;
            case guiContextEnum.GUI_POWER_REGISTER:
                currentNotifyEntities = "SPM1Module1"
                interval = 1000
                break;
            }
            if(currentNotifyEntities !== "") {
                start()
            }
            //console.info("Notify:", currentNotifyEntities)
        }
        onTriggered: {
            var entityNames = currentNotifyEntities.split(',')
            for(var idx=0; idx<entityNames.length; ++idx) {
                var entity = VeinEntity.getEntity(entityNames[idx])
                ++entity.PAR_ClientActiveNotify
            }
        }
    }


    /////////////////////////////////////////////////////////////////////////////
    // Database persistance settings TODO: let vein handle this
    property bool dbPersitenceDone: false
    property string currDatabaseFileName: settings.globalSettings.getOption("logger_db_filename", "")
    function setCurrDatabaseFileName(databaseFileName) {
        settings.globalSettings.setOption("logger_db_filename", databaseFileName)
    }
    property string currDatabaseSessionName: settings.globalSettings.getOption("logger_db_sessionname", "")
    function setCurrDatabaseSessionName(databaseSessionName) {
        settings.globalSettings.setOption("logger_db_sessionname", databaseSessionName)
    }

    /////////////////////////////////////////////////////////////////////////////
    // Logger settings

    // Logger session name macro helpers
    function loggerSessionNameReplace(strRaw) {
        var customerdataEntity = VeinEntity.hasEntity("CustomerData") ? VeinEntity.getEntity("CustomerData") : null
        var strRet = strRaw
        var dateTime = new Date();
        var customerID = customerdataEntity ? customerdataEntity.PAR_DatasetIdentifier : Z.tr("[customer data is not available]")
        var customerNumber = customerdataEntity ? customerdataEntity.PAR_CustomerNumber : Z.tr("[customer data is not available]")
        var replacementModel = {
            "$YEAR": Qt.formatDate(dateTime, "yyyy"),
            "$MONTH": Qt.formatDate(dateTime, "MM"),
            "$DAY": Qt.formatDate(dateTime, "dd"),
            "$TIME": Qt.formatDateTime(dateTime, "hh:mm"),
            "$SECONDS": Qt.formatDateTime(dateTime, "ss"),
            "$CUST_ID" : customerID.length>0 ? customerID : Z.tr("[customer id is not set]"),
            "$CUST_NUM" : customerID.length>0 ? customerNumber : Z.tr("[customer number is not set]")
        }
        for(var replaceIndex in replacementModel) {
            var tmpRegexp = new RegExp("\\"+replaceIndex, 'g') //the $ is escaped as \$
            strRet = strRet.replace(tmpRegexp, replacementModel[replaceIndex]);
        }
        if(strRet.length > 255) {
            strRet = strRet.substring(0, 255)
        }
        return strRet;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Misc settings / status

    readonly property string serverIpAddress: settings.globalSettings.getOption("modulemanagerIp", "127.0.0.1");
    // not saved to settings
    property string currentSelectedStoragePath: "/home/operator/logger"; //default


    /////////////////////////////////////////////////////////////////////////////
    // Vein global status

    // Vein components can be used only after vein is initialized otherwise
    // we get nul-errors accessing components. To get around we wrap components
    // in properties and bind them once vein is up. The property
    // 'entityInitializationDone' is set from main.qml...
    property bool entityInitializationDone: false;
    onEntityInitializationDoneChanged: {
        if(entityInitializationDone) {
            adjustmentStatusText = Qt.binding(function() {
                return VeinEntity.getEntity("StatusModule1").INF_Adjusted;
            });
            var statusEntity = VeinEntity.getEntity("StatusModule1")
            // this is static - no binding necessary
            deviceName = "zera-" + statusEntity.INF_DeviceType + '-' + statusEntity.PAR_SerialNr
        }
    }
    property string deviceName: "zera-undef"

    // adjustment status helpers
    property string adjustmentStatusText: "0"
    readonly property bool adjustmentStatusOk : {
        // To avoid confusion we assume adjusted state as long as vein is not up
        return !entityInitializationDone || parseInt(adjustmentStatusText) === 0
    }

    readonly property string adjustmentStatusDescription : {
        var status = parseInt(adjustmentStatusText)
        var strStatus = "OK"
        if(status !== 0) {
            strStatus = ""
            // see mt310s2d/com5003d / adjustment.h for flags definition
            if(status & 1) {
                strStatus += Z.tr("Not adjusted")
            }
            if(status & 2) {
                if(strStatus !== "") {
                    strStatus += " / "
                }
                strStatus += Z.tr("Wrong version")
            }
            if(status & 4) {
                if(strStatus !== "") {
                    strStatus += " / "
                }
                strStatus += Z.tr("Wrong serial number")
            }
        }
        return strStatus;
    }


    /////////////////////////////////////////////////////////////////////////////
    // Startup jobs
    // * establish ZeraComponents settings bindings
    // * distribute locale from settings
    Component.onCompleted: {
        // ZeraComponents
        ZCC.standardTextHorizMargin = Qt.binding(function() { return globalConfig.standardTextHorizMargin })
        ZCC.standardTextBottomMargin = Qt.binding(function() { return globalConfig.standardTextBottomMargin })
        // locale
        setLocale(settings.globalSettings.getOption("locale", "en_GB"), false)
    }
}
