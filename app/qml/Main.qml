import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import SessionState 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import ZeraThemeConfig 1.0

import "controls"
import "helpers"
import "controls/api"

Window {
    id: displayWindow

    visible: true
    visibility: {
        console.info("Desktop Session:", DESKTOP_SESSION)
        if(String(DESKTOP_SESSION) === "Zera GUI session")
            return Window.FullScreen
        return Window.Windowed
    }

    DevelWinSizeChanger { id: resolutionChanger }
    width: resolutionChanger.winWidth
    height: resolutionChanger.winHeight

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

        function onSigSystemEntityAvailable() {
            SessionState.currentSession = Qt.binding(function() {
                return VeinEntity.getEntity("_System").Session
            });
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
                source: "qrc:/qml/controls/ranges/RangeMModePage.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutRangeIndex
            }
            Loader {
                id: loggerSettingsLoader
                source: "qrc:/qml/controls/logger/LoggerSettingsStack.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutLoggerIndex
            }
            Loader {
                source: "qrc:/qml/controls/settings/Settings.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutSettingsIndex
            }
            Loader {
                source: "qrc:/qml/controls/appinfo/StatusView.qml"
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutStatusIndex
            }
            Loader {
                sourceComponent: SplashView { }
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutSplashIndex
            }
            ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
        }

        MainToolBar {
            id: controlsBar
            anchors { bottom: parent.bottom; left: parent.left }
            implicitHeight: parent.height / 16
            implicitWidth: parent.width

            layoutStackObj: layoutStack
            loggerSettingsStackObj: loggerSettingsLoader.item
        }

        // Note: The only way to pass complex stuff ListModel below is to pass
        // ids of items. So for running active we pass in either neverRunHelper
        // or isRunning
        Item {
            id: neverRunHelper
            function isRunning() { return false }
        }
        EntityErrorMeasHelper {
            id: errMeasRunHelper
            function isRunning() { return oneOrMoreRunning }
        }
        ListModel {
            id: dynamicPageModel
            property int countActiveSources: 0
            function updateSourceView() {
                if((ASWGL.isServer && !ASWGL.sourceEnabled))
                    return
                var sourceViewQml = "SourceModuleTabPage.qml"
                // search source view currently added
                var sourceViewPosition = -1
                if(count > 0) {
                    for(var viewNum=count-1; viewNum>=0; --viewNum) {
                        var view = get(viewNum)
                        if(view.elementValue.endsWith(sourceViewQml)) {
                            sourceViewPosition = viewNum
                            break;
                        }
                    }
                }
                // add view?
                if(countActiveSources > 0 && sourceViewPosition === -1)
                    appendItem("Source control", "source.png", sourceViewQml)
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

            function appendItem(title, iconBase, qmlFileBase, isRunningItem = neverRunHelper) {
                var iconPath = "qrc:/data/staticdata/resources/"
                var iconDark = iconPath + iconBase
                var iconLight = iconDark.replace('.png', '_light.png')
                var qmlFile = 'qrc:/qml/pages/' + qmlFileBase
                append( { name: title,
                          icon: iconDark, iconLight: iconLight,
                          elementValue: qmlFile,
                          isRunningItem: isRunningItem });
            }

            function initModel() {
                var hasEntity = VeinEntity.hasEntity
                clear()

                if(SessionState.emobSession) {
                    let emobTitle = "Actual values & Meter tests"
                    if(SessionState.currentSession.includes('-ac'))
                        appendItem(emobTitle, "act_values.png", "EMOBActualValueTabsPageAC.qml", errMeasRunHelper)
                    else if(SessionState.dcSession)
                        appendItem(emobTitle, "act_values.png", "EMOBActualValueTabsPageDC.qml", errMeasRunHelper)
                }
                else if(SessionState.dcSession)
                    appendItem("Actual values DC", "act_values.png", "DCActualValueTabsPage.qml")
                else if(hasEntity("RMSModule1") &&
                        hasEntity("LambdaModule1") &&
                        hasEntity("THDNModule1") &&
                        hasEntity("DFTModule1") &&
                        hasEntity("POWER1Module1") &&
                        hasEntity("POWER1Module2") &&
                        hasEntity("POWER1Module3") &&
                        hasEntity("RangeModule1"))
                    appendItem("Actual values", "act_values.png", "ActualValueTabsPage.qml")

                if(!SessionState.dcSession && (hasEntity("FFTModule1") || hasEntity("OSCIModule1")))
                    appendItem("Harmonics & Curves", "osci.png", "FftTabPage.qml")

                if(hasEntity("Power3Module1"))
                    appendItem("Harmonic power values", "hpower.png", "HarmonicPowerTabPage.qml")

                if(!SessionState.refSession) {
                    if(!SessionState.emobSession) {
                        if(hasEntity("SEC1Module1") ||
                           hasEntity("SEC1Module2") ||
                           hasEntity("SEM1Module1") ||
                           hasEntity("SPM1Module1"))
                            appendItem("Comparison measurements", "error_calc.png", "ComparisonTabsView.qml", errMeasRunHelper)
                    }
                }
                else if(hasEntity("SEC1Module1"))
                    appendItem("Quartz reference measurement", "error_calc.png", "QuartzModulePage.qml", errMeasRunHelper)

                if(hasEntity("Burden1Module1") || hasEntity("Burden1Module2"))
                    appendItem("Burden values", "burden.png", "BurdenModulePage.qml")

                if(hasEntity("Transformer1Module1"))
                    appendItem("Transformer values", "transformer.png", "TransformerModulePage.qml")

                if(hasEntity("POWER2Module1"))
                    appendItem("CED power values", "ced_power_values.png", "CEDModulePage.qml")

                if(hasEntity("REFERENCEModule1") && hasEntity("DFTModule1"))
                    appendItem("DC reference values", "ref_values.png", "RefModulePage.qml")
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
        Keys.onPressed: (event)=> {
            if(event.key === Qt.Key_Print)
                screenShooter.handlePrintPressed()
        }

        ApiConfirmationPopup { }
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

    VirtualKeyboard { }
}
