import QtQuick 2.12
import QtQuick.Window 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard 2.4
import QtQuick.VirtualKeyboard.Settings 2.2
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import AppStarterForWebserverSingleton 1.0
import VeinEntity 1.0
import SessionState 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0

import "controls"
import "helpers"

import "controls/ranges"
import "controls/logger"
import "controls/appinfo"
import "controls/settings"
import "controls/api"

ApplicationWindow {
    id: displayWindow

    // for development: current resolution
    property int screenResolution: GC.screenResolution

    visible: true
    visibility: {
        console.info("Desktop Session:", DESKTOP_SESSION)
        if(String(DESKTOP_SESSION) === "Zera GUI session")
            return "FullScreen"
        return "Windowed"
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
                width = 800-50
                break
            case 1:
                width = 1024-50
                break
            case 2:
                width = 1280-60
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
    Material.theme: Material.Dark
    Material.accent: "#339966"
    readonly property real pointSize: height > 0 ? height * 0.035 : 10

    Connections {
        target: VeinEntity
        function onSigStateChanged(t_state) {
            if(t_state === VeinEntity.VQ_LOADED) {
                dynamicPageModel.initModel();
                pageView.model = dynamicPageModel;

                ModuleIntrospection.reloadIntrospection();

                // rescue dyn sources binding over session change
                dynamicPageModel.countActiveSources = Qt.binding(function() {
                    if(ModuleIntrospection.hasDependentEntities(["SourceModule1"]))
                        return VeinEntity.getEntity("SourceModule1").ACT_CountSources
                    else
                        return 0
                })

                pageLoader.active = true;
                controlsBar.rangeIndicatorDependenciesReady = true;
                let lastPageSelected = GC.lastPageViewIndexSelected
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
            }
        }

        function onSigEntityAvailable(t_entityName) {
            const entId = VeinEntity.getEntity(t_entityName).entityId()
            if(entId === 0) {
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
            duration: 300
            id: flickableAnimation
        }

        StackLayout {
            id: layoutStack
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: controlsBar.top }
            anchors.margins: 8
            currentIndex: GC.entityInitializationDone ? GC.layoutStackEnum.layoutPageIndex : GC.layoutStackEnum.layoutSplashIndex

            ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
            //DefaultProperty: [
            Loader {
                id: pageLoader
                source: pageView.pageLoaderSource
                asynchronous: true
                onLoaded: console.info("Pages loaded")
            }
            Loader {
                sourceComponent: RangeMModePage {
                    enableRangeAutomaticAndGrouping: !SessionState.refSession
                    showRatioLines: !SessionState.refSession
                }
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutRangeIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                id: loggerSettingsLoader
                sourceComponent: LoggerSettingsStack { }
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutLoggerIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                sourceComponent: Settings {}
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutSettingsIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                sourceComponent: StatusView {}
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutStatusIndex
                onActiveChanged: {
                    if(!active && pageLoader.item)
                        pageLoader.item.forceActiveFocus()
                }
            }
            Loader {
                active: layoutStack.currentIndex === GC.layoutStackEnum.layoutSplashIndex
                sourceComponent: Item {
                    anchors.fill: parent
                    Label {
                        anchors.centerIn: parent
                        text: safeDelay.running ? Z.tr("Please wait...") : Z.tr("Something went wrong")
                        font.pointSize: parent.height * 0.08
                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.AlignVCenter
                    }
                    Button {
                        visible: !safeDelay.running
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: parent.width * 0.5
                        height: parent.height * 0.125
                        font.pointSize: parent.height * 0.04
                        text: Z.tr("Save/Send logs")
                        onClicked: {
                            GC.setLastInfoTabSelected(1)
                            layoutStack.currentIndex = GC.layoutStackEnum.layoutStatusIndex
                        }
                    }
                    Timer {
                        id: safeDelay
                        interval: 10000
                        repeat: false
                        running: true
                    }
                }
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
                let sourceViewQml = "qrc:/qml/pages/SourceModuleTabPage.qml"
                // search source view currently added
                let sourceViewPosition = -1
                if(count > 0) {
                    for(let viewNum=count-1; viewNum>=0; --viewNum) {
                        let view = get(viewNum)
                        if(view.elementValue === sourceViewQml) {
                            sourceViewPosition = viewNum
                            break;
                        }
                    }
                }
                // add view?
                if(countActiveSources > 0 && sourceViewPosition === -1)
                    append({name: "Source control", icon: "qrc:/data/staticdata/resources/source.png", elementValue: sourceViewQml});
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
                let dftAvail = ModuleIntrospection.hasDependentEntities(["DFTModule1"])
                let isReference = ModuleIntrospection.hasDependentEntities(["REFERENCEModule1"])

                controlsBar.rotaryFieldDependenciesReady = dftAvail && !isReference && !SessionState.dcSession

                let iconName = "qrc:/data/staticdata/resources/act_values.png"
                if(SessionState.emobSession) {
                    let emobTitle = "Actual values & Meter tests"
                    if(SessionState.currentSession.includes('-ac'))
                        append({name: emobTitle, icon: iconName, elementValue: "qrc:/qml/pages/EMOBActualValueTabsPageAC.qml"})
                    else if(SessionState.dcSession)
                        append({name: emobTitle, icon: iconName, elementValue: "qrc:/qml/pages/EMOBActualValueTabsPageDC.qml"})
                }
                else if(SessionState.dcSession)
                    append({name: "Actual values DC", icon: iconName, elementValue: "qrc:/qml/pages/DCActualValueTabsPage.qml"})
                else if(ModuleIntrospection.hasDependentEntities(["RMSModule1",
                                                                  "LambdaModule1",
                                                                  "THDNModule1",
                                                                  "DFTModule1",
                                                                  "POWER1Module1",
                                                                  "POWER1Module2",
                                                                  "POWER1Module3",
                                                                  "RangeModule1"]))
                    append({name: "Actual values", icon: "qrc:/data/staticdata/resources/act_values.png", elementValue: "qrc:/qml/pages/ActualValueTabsPage.qml"})

                if(ModuleIntrospection.hasDependentEntities(["FFTModule1"]) || ModuleIntrospection.hasDependentEntities(["OSCIModule1"]))
                    append({name: "Harmonics & Curves", icon: "qrc:/data/staticdata/resources/osci.png", elementValue: "qrc:/qml/pages/FftTabPage.qml"})

                if(ModuleIntrospection.hasDependentEntities(["Power3Module1"]))
                    append({name: "Harmonic power values", icon: "qrc:/data/staticdata/resources/hpower.png", elementValue: "qrc:/qml/pages/HarmonicPowerTabPage.qml"})

                if(!SessionState.refSession) {
                    if(!SessionState.emobSession) {
                        if(ModuleIntrospection.hasDependentEntities(["SEC1Module1"]) ||
                                ModuleIntrospection.hasDependentEntities(["SEC1Module2"]) ||
                                ModuleIntrospection.hasDependentEntities(["SEM1Module1"]) ||
                                ModuleIntrospection.hasDependentEntities(["SPM1Module1"]))
                            append({name: "Comparison measurements", icon: "qrc:/data/staticdata/resources/error_calc.png", elementValue: "qrc:/qml/pages/ComparisonTabsView.qml", activeItem: errMeasHelper});
                    }
                }
                else if(ModuleIntrospection.hasDependentEntities(["SEC1Module1"]))
                    append({name: "Quartz reference measurement", icon: "qrc:/data/staticdata/resources/error_calc.png", elementValue: "qrc:/qml/pages/QuartzModulePage.qml", activeItem: errMeasHelper});

                if(ModuleIntrospection.hasDependentEntities(["Burden1Module1"]) || ModuleIntrospection.hasDependentEntities(["Burden1Module2"]))
                    append({name: "Burden values", icon: "qrc:/data/staticdata/resources/burden.png", elementValue: "qrc:/qml/pages/BurdenModulePage.qml"})

                if(ModuleIntrospection.hasDependentEntities(["Transformer1Module1"]))
                    append({name: "Transformer values", icon: "qrc:/data/staticdata/resources/transformer.png", elementValue: "qrc:/qml/pages/TransformerModulePage.qml"})

                if(ModuleIntrospection.hasDependentEntities(["POWER2Module1"]))
                    append({name: "CED power values", icon: "qrc:/data/staticdata/resources/ced_power_values.png", elementValue: "qrc:/qml/pages/CEDModulePage.qml"})

                if(ModuleIntrospection.hasDependentEntities(["REFERENCEModule1", "DFTModule1"]))
                    append({name: "DC reference values", icon: "qrc:/data/staticdata/resources/ref_values.png", elementValue: "qrc:/qml/pages/RefModulePage.qml"})
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
                controlsBar.rangeIndicatorDependenciesReady = false;
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

        ScreenShooter { id: screenShooter }
        Keys.onPressed: {
            if(event.key === Qt.Key_Print) {
                screenShooter.handlePrintPressed()
            }
        }

        ApiConfirmationPopup{
        }
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
                    keyboardOpacityAnimation.duration = 500
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
