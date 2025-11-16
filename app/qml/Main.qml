import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls.Material 2.14
import QtQuick.VirtualKeyboard 2.14
import QtQuick.VirtualKeyboard.Settings 2.14
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import SessionState 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import ZeraThemeConfig 1.0

import "controls"
import "helpers"

import "controls/ranges"
import "controls/api"

Window {
    id: displayWindow

    // for development: current resolution
    property int screenResolution: GC.screenResolution

    visible: true
    visibility: {
        console.info("Desktop Session:", DESKTOP_SESSION)
        if(String(DESKTOP_SESSION) === "Zera GUI session")
            return Window.FullScreen
        return Window.Windowed
    }

    // Notes on resolutions:
    // * for production we use desktop sizes: We have one monitor & bars
    // * for debug we use screen sizes for multi monitor environments
    width: {
        let width = Screen.desktopAvailableWidth
        if(BUILD_TYPE === "debug") {
            // Note: for some reasons, vertical XFCE bar scales automatically
            switch(displayWindow.screenResolution) {
            case 0:
                width = 800
                break
            case 1:
                width = 1024
                break
            case 2:
                width = 1280
                break
            default:
                width = Screen.width
                break;
            }
        }
        return width
    }
    height: {
        let height = Screen.desktopAvailableHeight
        if(BUILD_TYPE === "debug") {
            switch(displayWindow.screenResolution) {
            case 0:
                height = 480;
                break
            case 1:
                height = 600;
                break
            case 2:
                height = 800;
                break
            /*default:
                height = Screen.height
                break;*/
            }
        }
        return height
    }

    flags: Qt.FramelessWindowHint
    title: "ZeraGUI"
    Material.theme: ZTC.materialTheme
    Material.accent: ZTC.accentColor
    Material.background: ZTC.backgroundColor
    color: ZTC.backgroundColor
    readonly property real pointSize: height > 0 ? height * 0.035 : 10
    property bool setSessionNameForPersitence: false
    property QtObject loggerEntity
    property string databaseFile: ""
    onDatabaseFileChanged: {
        if(setSessionNameForPersitence && databaseFile !== "") {
            loggerEntity.sessionName = GC.currDatabaseSessionName
        }
        setSessionNameForPersitence = false
    }

    function setDatabase() {
        var oldPersitenceDone = GC.dbPersitenceDone
        GC.dbPersitenceDone = true
        if(loggerEntity.DatabaseReady !== true) {
            if(!oldPersitenceDone && loggerEntity.DatabaseFile === "" && GC.currDatabaseFileName !== "") {
                loggerEntity.DatabaseFile = GC.currDatabaseFileName
                if(GC.currDatabaseSessionName !== "") {
                    setSessionNameForPersitence = true
                }
                databaseFile = GC.currDatabaseFileName
            }
        }
    }

    Connections {
        target: VeinEntity
        function onSigStateChanged(t_state) {
            if(t_state === VeinEntity.VQ_LOADED) {
                dynamicPageModel.initModel();
                pageView.model = dynamicPageModel;

                ModuleIntrospection.reloadIntrospection();

                // rescue dyn sources binding over session change
                dynamicPageModel.countActiveSources = Qt.binding(function() {
                    if(VeinEntity.hasEntity("SourceModule1"))
                        return VeinEntity.getEntity("SourceModule1").ACT_CountSources
                    else
                        return 0
                })
                dynamicPageModel.updateSourceView()

                pageLoader.active = true;
                var lastPageSelected = GC.lastPageViewIndexSelected
                if(lastPageSelected >= pageView.model.count)
                    lastPageSelected = 0
                if(pageView.model.count)
                    pageView.pageLoaderSource = pageView.model.get(lastPageSelected).elementValue;
                loadingScreenLoader.item.close();
                sessionChangeTimeout.stop();
                layoutStack.currentIndex = GC.layoutStackEnum.layoutPageIndex
                GC.entityInitializationDone = true
                controlsBar.pageViewVisible = false
                console.info("Loaded session:", SessionState.currentSession);
                if(VeinEntity.hasEntity("_LoggingSystem")) {
                    loggerEntity = VeinEntity.getEntity("_LoggingSystem")
                    setDatabase()
                }
            }
        }

        function onSigEntityAvailable(t_entityName) {
            if (t_entityName === "_System") {
                SessionState.currentSession = Qt.binding(function() {
                    return VeinEntity.getEntity("_System").Session
                });
            }
        }
    }

    Shortcut {
        enabled: BUILD_TYPE === "debug"
        sequence: "F3"
        autoRepeat: false
        onActivated: {
            screenResolution = (screenResolution+1) % 4
            GC.setScreenResolution(screenResolution)
        }
    }

    Flickable {
        // main view displaying pages and other stuff - (flickable for virtual keyboard)
        id: flickable
        anchors.fill: parent
        enabled: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: false
        NumberAnimation on contentY {
            duration: 200
            id: flickableAnimation
        }

        StackLayout {
            id: layoutStack
            currentIndex: GC.entityInitializationDone ? GC.layoutStackEnum.layoutPageIndex : GC.layoutStackEnum.layoutSplashIndex
            anchors {
                left: parent.left;
                right: parent.right;
                top: parent.top;
                bottom: controlsBar.top;
            }

            ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
            //DefaultProperty: [
            Loader {
                id: pageLoader
                source: pageView.pageLoaderSource
                asynchronous: true
                onLoaded: console.info("Pages loaded")
            }
            Loader {
                sourceComponent: RangeMModePage { }
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutRangeIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                id: loggerSettingsLoader
                source: "qrc:/qml/controls/logger/LoggerSettingsStack.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutLoggerIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                source: "qrc:/qml/controls/settings/Settings.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutSettingsIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                source: "qrc:/qml/controls/appinfo/StatusView.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutStatusIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                sourceComponent: SplashView { }
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutSplashIndex
            }
            ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
        }

        MainToolBar {
            id: controlsBar
            height: parent.height/16
            anchors.bottom: parent.bottom
            width: displayWindow.width

            layoutStackObj: layoutStack
            loggerSettingsStackObj: loggerSettingsLoader.item
        }

        EntityErrorMeasHelper {
            id: errMeasHelper
        }

        // Note: The only way to pass complex stuff ListModel below is to pass
        // ids of items.
        ListModel {
            id: dynamicPageModel
            property int countActiveSources: 0
            function updateSourceView() {
                if((ASWGL.isServer && !ASWGL.sourceEnabled))
                    return
                var sourceViewQml = "qrc:/qml/pages/SourceModuleTabPage.qml"
                // search source view currently added
                var sourceViewPosition = -1
                if(count > 0) {
                    for(var viewNum=count-1; viewNum>=0; --viewNum) {
                        var view = get(viewNum)
                        if(view.elementValue === sourceViewQml) {
                            sourceViewPosition = viewNum
                            break;
                        }
                    }
                }
                // add view?
                if(countActiveSources > 0 && sourceViewPosition === -1) {
                    var iconPath = "qrc:/data/staticdata/resources/"
                    append({name: "Source control", icon: iconPath + "source.png", iconLight: iconPath + "source_light.png",
                               elementValue: sourceViewQml})
                }
                // remove view?
                else if(countActiveSources === 0 && sourceViewPosition >= 0) {
                    remove(sourceViewPosition)
                    if(GC.lastPageViewIndexSelected === sourceViewPosition) {
                        if(pageView.model.count)
                            pageView.pageLoaderSource = pageView.model.get(0).elementValue
                        else
                            pageView.pageLoaderSource = ""
                        GC.setLastPageViewIndexSelected(0)
                    }
                }
            }
            onCountActiveSourcesChanged: updateSourceView()

            function initModel() {
                clear()
                var hasEntity = VeinEntity.hasEntity
                var sessState = SessionState
                var dftAvail = hasEntity("DFTModule1")
                var isReferenceSession = sessState.refSession
                var isDcSession = sessState.dcSession
                var isEmobSession = sessState.emobSession

                controlsBar.rotaryFieldDependenciesReady = dftAvail && !isReferenceSession && !isDcSession

                var iconPath = "qrc:/data/staticdata/resources/"
                var actValueIcon = iconPath + "act_values.png"
                var actValueIconLight = iconPath + "act_values_light.png"
                if(isEmobSession) {
                    let emobTitle = "Actual values & Meter tests"
                    if(sessState.currentSession.includes('-ac'))
                        append({name: emobTitle, icon: actValueIcon, iconLight: actValueIconLight,
                                   elementValue: "qrc:/qml/pages/EMOBActualValueTabsPageAC.qml"})
                    else if(isDcSession)
                        append({name: emobTitle, icon: actValueIcon, iconLight: actValueIconLight,
                                   elementValue: "qrc:/qml/pages/EMOBActualValueTabsPageDC.qml"})
                }
                else if(isDcSession)
                    append({name: "Actual values DC", icon: actValueIcon, iconLight: actValueIconLight,
                               elementValue: "qrc:/qml/pages/DCActualValueTabsPage.qml"})
                else if(hasEntity("RMSModule1") &&
                        hasEntity("LambdaModule1") &&
                        hasEntity("THDNModule1") &&
                        hasEntity("DFTModule1") &&
                        hasEntity("POWER1Module1") &&
                        hasEntity("POWER1Module2") &&
                        hasEntity("POWER1Module3") &&
                        hasEntity("RangeModule1"))
                    append({name: "Actual values", icon: actValueIcon, iconLight: actValueIconLight,
                               elementValue: "qrc:/qml/pages/ActualValueTabsPage.qml"})

                if(!isDcSession && (hasEntity("FFTModule1") || hasEntity("OSCIModule1")))
                    append({name: "Harmonics & Curves", icon: iconPath + "osci.png", iconLight: iconPath + "osci_light.png",
                               elementValue: "qrc:/qml/pages/FftTabPage.qml"})

                if(hasEntity("Power3Module1"))
                    append({name: "Harmonic power values", icon: iconPath + "hpower.png", iconLight: iconPath + "hpower_light.png",
                               elementValue: "qrc:/qml/pages/HarmonicPowerTabPage.qml"})

                if(!isReferenceSession) {
                    if(!isEmobSession) {
                        if(hasEntity("SEC1Module1") ||
                           hasEntity("SEC1Module2") ||
                           hasEntity("SEM1Module1") ||
                           hasEntity("SPM1Module1"))
                            append({name: "Comparison measurements", icon: iconPath + "error_calc.png", iconLight: iconPath + "error_calc_light.png",
                                       elementValue: "qrc:/qml/pages/ComparisonTabsView.qml", activeItem: errMeasHelper});
                    }
                }
                else if(hasEntity("SEC1Module1"))
                    append({name: "Quartz reference measurement", icon: iconPath + "error_calc.png", iconLight: iconPath + "error_calc_light.png",
                               elementValue: "qrc:/qml/pages/QuartzModulePage.qml", activeItem: errMeasHelper});

                if(hasEntity("Burden1Module1") || hasEntity("Burden1Module2"))
                    append({name: "Burden values", icon: iconPath + "burden.png", iconLight: iconPath + "burden_light.png",
                               elementValue: "qrc:/qml/pages/BurdenModulePage.qml"})

                if(hasEntity("Transformer1Module1"))
                    append({name: "Transformer values", icon: iconPath + "transformer.png", iconLight: iconPath + "transformer_light.png",
                               elementValue: "qrc:/qml/pages/TransformerModulePage.qml"})

                if(hasEntity("POWER2Module1"))
                    append({name: "CED power values", icon: iconPath + "ced_power_values.png", iconLight: iconPath + "ced_power_values_light.png",
                               elementValue: "qrc:/qml/pages/CEDModulePage.qml"})

                if(hasEntity("REFERENCEModule1") && hasEntity("DFTModule1"))
                    append({name: "DC reference values", icon: iconPath+ "ref_values.png", iconLight: iconPath+ "ref_values_light.png",
                               elementValue: "qrc:/qml/pages/RefModulePage.qml"})
            }
        }

        PageView {
            id: pageView
            anchors.fill: parent
            ///@note do not break binding by setting visible directly
            visible: controlsBar.pageViewVisible;
            onCloseView: controlsBar.pageViewVisible = false;
            function prepareSessionChange() {
                layoutStack.currentIndex=0;
                pageLoader.active = false;
                GC.entityInitializationDone = false;
            }
            sessionComponent: SessionState.currentSession
            onSessionComponentChanged: {
                prepareSessionChange();
                loadingScreenLoader.item.open();
                sessionChangeTimeout.start();
            }
            Timer {
                id: sessionChangeTimeout
                interval: 10000
                repeat: false
                onTriggered: {
                    loadingScreenLoader.item.close();
                    layoutStack.currentIndex = GC.layoutStackEnum.layoutSplashIndex
                    controlsBar.pageViewVisible = false
                }
            }
        }

        Loader {
            id: screenShooter
            source: "qrc:/qml/controls/ScreenShooter.qml"
            active: false
            anchors.fill: parent
            function handlePrintPressed() {
                active = true
                item.handlePrintPressed()
            }
        }
        Keys.onPressed: {
            if(event.key === Qt.Key_Print)
                screenShooter.handlePrintPressed()
        }

        ApiConfirmationPopup { }
    }

    InputPanel {
        id: inputPanel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -parent.height * 0.035
        anchors.rightMargin: -parent.width * 0.035
        anchors.leftMargin: anchors.rightMargin
        property bool textEntered: Qt.inputMethod.visible
        onHeightChanged: GC.vkeyboardHeight = height
        opacity: 0
        NumberAnimation on opacity {
            id: keyboardOpacityAnimation
            onStarted: {
                if(to === 1)
                    inputPanel.visible = GC.showVirtualKeyboard
            }
            onFinished: {
                if(to === 0)
                    inputPanel.visible = false
            }
        }
        onTextEnteredChanged: {
            var rectInput = Qt.inputMethod.anchorRectangle
            if(inputPanel.textEntered) {
                if(GC.showVirtualKeyboard) {
                    if(rectInput.bottom > inputPanel.y) {
                        // shift flickable (normal elements)
                        flickableAnimation.to = rectInput.bottom - inputPanel.y + 10
                        flickableAnimation.start()
                        // shift overlay (Popup)
                        overlayAnimation.to = -(rectInput.bottom - inputPanel.y + 10)
                        overlayAnimation.start()
                    }
                    keyboardOpacityAnimation.to = 1
                    keyboardOpacityAnimation.duration = 300
                    keyboardOpacityAnimation.start()
                }
            }
            else {
                if(flickable.contentY !== 0) {
                    // shift everything back
                    overlayAnimation.to = 0
                    overlayAnimation.start()
                    flickableAnimation.to = 0
                    flickableAnimation.start()
                }
                keyboardOpacityAnimation.to = 0
                keyboardOpacityAnimation.duration = 0
                keyboardOpacityAnimation.start()
            }
        }
    }
    // Overlay animation. Shift overlay for popups (required: 'parent: Overlay.overlay')
    NumberAnimation on Overlay.overlay.y {
        duration: 300
        id: overlayAnimation
    }

    Loader {
        id: loadingScreenLoader
        asynchronous: true
        anchors.fill: parent
        sourceComponent: Popup {
            //is shown when switching sessions
            x: parent.width/2 - width/2
            y: parent.height/2 - height/2
            closePolicy: Popup.NoAutoClose
            modal: true
            implicitWidth: parent.width/10
            implicitHeight: parent.width/10
            BusyIndicator {
                running: true
                anchors.fill: parent
            }
        }
    }
}
