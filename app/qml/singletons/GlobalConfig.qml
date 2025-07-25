pragma Singleton
import QtQuick 2.0
import QtQuick.VirtualKeyboard.Settings 2.2
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import ZeraSettings 1.0
import SessionState 1.0
import ZeraTranslation 1.0
import VeinEntity 1.0
import AppStarterForWebGLSingleton 1.0
import AppStarterForWebserverSingleton 1.0
import AppStarterForApi 1.0
import ZeraComponentsConfig 1.0
import ZeraLocale 1.0

Item {
    id: globalConfig
    /**
    * @b default configuration values and utility functions
    * @todo reimplement as QObject with Q_PROPERTY / Q_INVOKABLE to get QtCreator to code complete stuff...
    */

    /////////////////////////////////////////////////////////////////////////////
    // The JSON settings item
    //
    // IMPORTANT: ensure to wrap each call to Settings.getOption
    // by a specific property to avoid cross property change activities: settings
    // has just one single notification for ALL settings-entries

    readonly property string serverIp: Settings.getOption("modulemanagerIp", "127.0.0.1")

    readonly property string currentSession: SessionState.currentSession
    onCurrentSessionChanged: {
        lastPageViewIndexSelectedVolatile = -1
        lastTabSelectedVolatile = -1
    }
    readonly property string sessionNamePrefix: currentSession.replace(".json", "-")
    property int lastPageViewIndexSelectedVolatile: 0
    property int lastPageViewIndexSelected: {
        let index = lastPageViewIndexSelectedVolatile
        if(currentSession !== "")
            index = parseInt(Settings.getOption(sessionNamePrefix + "pageIndex", "0"))
        return index
    }
    function setLastPageViewIndexSelected(index) {
        if(currentSession !== "")
            Settings.setOption(sessionNamePrefix + "pageIndex", index);
        lastPageViewIndexSelectedVolatile = index
    }

    property int lastTabSelectedVolatile: 0
    property int lastTabSelected: {
        let tab = lastTabSelectedVolatile
        if(currentSession !== "")
            tab = parseInt(Settings.getOption(sessionNamePrefix + "page" + lastPageViewIndexSelected + "Tab", "0"))
        return tab
    }
    function setLastTabSelected(tabNo) {
        Settings.setOption(sessionNamePrefix + "page" + lastPageViewIndexSelected + "Tab", tabNo)
        lastTabSelectedVolatile = tabNo
    }

    property int lastSettingsTabSelected: parseInt(Settings.getOption("lastTabSettings", "0"))
    function setLastSettingsTabSelected(tabNo) {
        lastSettingsTabSelected = tabNo
        Settings.setOption("lastTabSettings", tabNo)
    }

    property int lastInfoTabSelected: parseInt(Settings.getOption("lastTabInfo", "0"))
    function setLastInfoTabSelected(tabNo) {
        lastInfoTabSelected = tabNo
        Settings.setOption("lastTabInfo", tabNo)
    }

    /////////////////////////////////////////////////////////////////////////////
    // Digit settings
    property int digitsTotal: parseInt(Settings.getOption("digitsTotal", "6"))
    function setDigitsTotal(digits) {
        digitsTotal = digits
        Settings.setOption("digitsTotal", digits);
    }

    property int decimalPlaces: parseInt(Settings.getOption("digits", "4"))
    function setDecimalPlaces(digits) {
        decimalPlaces = digits
        Settings.setOption("digits", digits);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Aux phases
    property bool showAuxPhases: parseInt(Settings.getOption("show_aux_phases", "0"))
    function setShowAuxPhases(showAux) {
        showAuxPhases = showAux
        var setValue = showAux ? 1 : 0
        Settings.setOption("show_aux_phases", setValue);
    }

    /////////////////////////////////////////////////////////////////////////////
    // FFT specials
    property int showFftTableAsRelative: parseInt(Settings.getOption("fft_table_as_relative", "0"))
    function setShowFftTableAsRelative(isRelative) {
        showFftTableAsRelative = isRelative
        var setValue = isRelative ? 1 : 0
        Settings.setOption("fft_table_as_relative", setValue);
    }

    property int showFftTableAngles: parseInt(Settings.getOption("fft_table_show_angle", "0"))
    function setShowFftTableAngle(showAngles) {
        showFftTableAngles = showAngles
        var setValue = showAngles ? 1 : 0
        Settings.setOption("fft_table_show_angle", setValue);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Vector settings
    property int vectorMode: parseInt(Settings.getOption("vector_mode", "0"))
    function setVectorMode(mode) {
        vectorMode = mode
        Settings.setOption("vector_mode", mode);
    }
    property bool vectorIecMode: parseInt(Settings.getOption("vector_iecmode", "0"))
    function setVectorIecMode(mode) {
        vectorIecMode = mode
        Settings.setOption("vector_iecmode", mode);
    }
    property bool vectorCircleMode: parseInt(Settings.getOption("vector_circlecmode", "1"))
    function setVectorCircleMode(mode) {
        vectorCircleMode = mode
        Settings.setOption("vector_circlecmode", mode);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Source settings
    property bool sourceSymmetric: parseInt(Settings.getOption("source_symmetric", "1"))
    function setSourceSymmetric(symmetric) {
        sourceSymmetric = symmetric
        var setValue = symmetric ? 1 : 0
        Settings.setOption("source_symmetric", setValue);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Graphics settings
    property bool showCurvePhaseOne: parseInt(Settings.getOption("show_curve_phase1", "1"))
    function setPhaseOne(phaseOne) {
        showCurvePhaseOne = phaseOne
        var setValue = phaseOne ? 1 : 0
        Settings.setOption("show_curve_phase1", setValue);
    }
    property bool showCurvePhaseTwo: parseInt(Settings.getOption("show_curve_phase2", "1"))
    function setPhaseTwo(phaseTwo) {
        showCurvePhaseTwo = phaseTwo
        var setValue = phaseTwo ? 1 : 0
        Settings.setOption("show_curve_phase2", setValue);
    }
    property bool showCurvePhaseThree: parseInt(Settings.getOption("show_curve_phase3", "1"))
    function setPhaseThree(phaseThree) {
        showCurvePhaseThree = phaseThree
        var setValue = phaseThree ? 1 : 0
        Settings.setOption("show_curve_phase3", setValue);
    }
    property bool showCurveSum: parseInt(Settings.getOption("show_curve_sum", "1"))
    function setSum(sum) {
        showCurveSum = sum
        var setValue = sum ? 1 : 0
        Settings.setOption("show_curve_sum", setValue);
    }
    /////////////////////////////////////////////////////////////////////////////
    // Pinch settings
    property real osciPinchScale: Number(Settings.getOption("osci_pinch_scale", "3"))
    function setOsciPinchScale(scale) {
        osciPinchScale = scale
        Settings.setOption("osci_pinch_scale", scale);
    }
    property real fftChartsPinchScale: Number(Settings.getOption("fft_charts_pinch_scale", "3"))
    function setFftChartsPinchScale(scale) {
        fftChartsPinchScale = scale
        Settings.setOption("fft_charts_pinch_scale", scale);
    }
    property real harmonicPowerChartPinchScale: Number(Settings.getOption("harm_power_charts_pinch_scale", "3"))
    function setHarmonicPowerChartPinchScale(scale) {
        harmonicPowerChartPinchScale = scale
        Settings.setOption("harm_power_charts_pinch_scale", scale);
    }


    property int energyScaleSelection: parseInt(Settings.getOption("energy_scale_selection", "1")) // 1 -> kWh
    function setEnergyScaleSelection(selection) {
        energyScaleSelection = selection
        Settings.setOption("energy_scale_selection", selection);
    }

    readonly property var layoutStackEnum: {
        "layoutPageIndex": 0,
        "layoutRangeIndex": 1,
        "layoutLoggerIndex": 2,
        "layoutSettingsIndex": 3,
        "layoutStatusIndex": 4,
        "layoutSplashIndex": 5
    }


    property bool pagesGridViewDisplay: parseInt(Settings.getOption("pages_grid_view", ASWGL.isServer ? "1" : "0"))
    function setPagesGridViewDisplay(isGridView) {
        pagesGridViewDisplay = isGridView
        Settings.setOption("pages_grid_view", isGridView ? 1 : 0);
    }

    property int screenResolution: parseInt(Settings.getOption("screen_resolution", "0"))
    function setScreenResolution(resolution) {
        screenResolution = resolution
        Settings.setOption("screen_resolution", resolution);
    }

    property bool showVirtualKeyboard: parseInt(Settings.getOption("show_virtual_keyboard", "1"))
    function setShowVirtualKeyboard(show) {
        showVirtualKeyboard = show
        Settings.setOption("show_virtual_keyboard", show ? 1 : 0);
    }


    /////////////////////////////////////////////////////////////////////////////
    // Web remote
    property bool webRemoteOn: parseInt(Settings.getOption("web_remote", "0"))
    function setWebRemoteOn(on) {
        webRemoteOn = on
        Settings.setOption("web_remote", on ? 1 : 0);
    }

    /////////////////////////////////////////////////////////////////////////////
    // remote API
    property bool remoteApiOn: parseInt(Settings.getOption("remote_api", "0"))
    function setRemoteApiOn(on) {
        webRemoteOn = on
        Settings.setOption("remote_api", on ? 1 : 0);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Common standard margins

    readonly property real standardMarginWithMin: 1
    readonly property real standardTextHorizMargin: 8
    readonly property real standardTextBottomMargin: 8
    property real vkeyboardHeight: 0

    /////////////////////////////////////////////////////////////////////////////
    // Auto scale

    /* Settings/autoScaleLimit: A float number to set at which limit the value
     changes and unit is prefixed e.g for autoScaleLimit=1.2 value >= 1200 is
     changed to 1.2k */

    readonly property real autoScaleLimit: parseFloat(Settings.getOption("auto_scale_limit", "1.0"))


    /////////////////////////////////////////////////////////////////////////////
    // This is the central place to distitibute locale change
    function setLocale(newLocaleStr, writeSettings) {
        Z.changeLanguage(newLocaleStr);
        VirtualKeyboardSettings.locale = newLocaleStr
        ZLocale.localeName = newLocaleStr
        if(writeSettings) {
            Settings.setOption("locale", newLocaleStr);
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
        "GUI_QUARTZ_REFERENCE"          : { value: 18, name: "ZeraGuiQuartzReference" },
        "GUI_SOURCE_CONTROL"            : { value: 19, name: "ZeraGuiSourceControl" },
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
        // Although DC/quartz reference reside in same session,
        // they are orthogonal and simultaneous operation is most
        // unlikely. So do not offer content set All/Custom for them.
        // As side-effect, the MTVis export should be happy about
        // this decision...
        case guiContextEnum.GUI_DC_REFERENCE:
            addDbContentSet(dbContentSetList, "ZeraDCReference")
            break
        case guiContextEnum.GUI_QUARTZ_REFERENCE:
            addDbContentSet(dbContentSetList, "ZeraQuartzReference")
            break
        case guiContextEnum.GUI_SOURCE_CONTROL:
            if(addDbContentSet(dbContentSetList, "ZeraSourceControl") /*mandatory*/) {
                addDbContentSet(dbContentSetList, "ZeraAll")
                addDbContentSet(dbContentSetList, "ZeraCustom")
            }
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

    property int loggerContentType: parseInt(Settings.getOption("logger_content_type", contentTypeEnum.CONTENT_TYPE_CONTEXT))
    function setLoggerContentType(contentType) {
        loggerContentType = contentType
        Settings.setOption("logger_content_type", contentType);
    }

    // custom contentSets
    property string loggerCustomContentSets: Settings.getOption("logger_custom_content_sets", "")
    function setLoggerCustomContentSets(customContentSets) {
        loggerCustomContentSets = customContentSets
        Settings.setOption("logger_custom_content_sets", customContentSets)
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
            case guiContextEnum.GUI_QUARTZ_REFERENCE:
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
                if(VeinEntity.hasEntity(entityNames[idx])) {
                    var entity = VeinEntity.getEntity(entityNames[idx])
                    if(entity.hasComponent(["PAR_ClientActiveNotify"])) {
                        ++entity.PAR_ClientActiveNotify
                    }
                }
            }
        }
    }


    /////////////////////////////////////////////////////////////////////////////
    // Database persistance settings TODO: let vein handle this
    property bool dbPersitenceDone: false
    property string currDatabaseFileName: Settings.getOption("logger_db_filename", "")
    function setCurrDatabaseFileName(databaseFileName) {
        currDatabaseFileName = databaseFileName
        Settings.setOption("logger_db_filename", databaseFileName)
    }
    property string currDatabaseSessionName: Settings.getOption("logger_db_sessionname", "")
    function setCurrDatabaseSessionName(databaseSessionName) {
        currDatabaseSessionName = databaseSessionName
        Settings.setOption("logger_db_sessionname", databaseSessionName)
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
            var statusEntity = VeinEntity.getEntity("StatusModule1")
            // this is static - no binding necessary
            deviceName = "zera-" + statusEntity.INF_DeviceType + '-' + statusEntity.PAR_SerialNr
        }
    }
    property string deviceName: "zera-undef"

    /////////////////////////////////////////////////////////////////////////////
    // Startup jobs
    // * establish ZeraComponents settings bindings
    // * distribute locale from settings
    // * auto webgl remote
    Component.onCompleted: {
        ZCC.standardTextHorizMargin = Qt.binding(function() { return globalConfig.standardTextHorizMargin })
        ZCC.standardTextBottomMargin = Qt.binding(function() { return globalConfig.standardTextBottomMargin })
        setLocale(Settings.getOption("locale", "en_GB"), false)
        if(!ASWGL.isServer && webRemoteOn ) {
            ASWGL.running = true
            ASWS.run = true
        }
        if(remoteApiOn) {
            ASAPI.running = true
        }
    }
}
