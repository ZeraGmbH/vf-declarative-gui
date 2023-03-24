import QtQuick 2.12
import QtQuick.Window 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard 2.4
import QtQuick.VirtualKeyboard.Settings 2.2
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import AccumulatorState 1.0
import ZeraSettings 1.0
import ZeraFa 1.0
import Notifications 1.0

import "controls"
import "helpers"

import "controls/range_module"
import "controls/logger"
import "controls/appinfo"
import "controls/settings"

ApplicationWindow {
    id: displayWindow


    // used to display the fps and other debug infos
    property bool debugBypass: false;
    // used to notify about the com5003 meas/CED/REF session change
    property string currentSession;
    // for development: current resolution
    property int screenResolution: GC.screenResolution

    readonly property bool dcSession : String(currentSession).includes('dc-session')
    readonly property bool emobSession : String(currentSession).includes('emob-session')

    visible: true
    width: getScreenWidth()
    height: getScreenHeight()
    flags: Qt.FramelessWindowHint
    title: "ZeraGUI"
    Material.theme: Material.Dark
    Material.accent: "#339966"

    Component.onCompleted: {
        currentSession = Qt.binding(function() {
            return VeinEntity.getEntity("_System").Session;
        })
        GC.currentSession = Qt.binding(function() {
            return currentSession
        });
    }

    onCurrentSessionChanged: {
        var availableEntityIds = VeinEntity.getEntity("_System")["Entities"];

        var oldIdList = VeinEntity.getEntityList();
        for(var oldIdIterator in oldIdList) {
            VeinEntity.entityUnsubscribeById(oldIdList[oldIdIterator]);
        }

        if(availableEntityIds !== undefined) {
            availableEntityIds.push(0);
        }
        else {
            availableEntityIds = [0];
        }

        for(var newIdIterator in availableEntityIds) {
            VeinEntity.entitySubscribeById(availableEntityIds[newIdIterator]);
        }
    }
    function getScreenWidth() {
        var width = Screen.desktopAvailableWidth
        if(BUILD_TYPE === "debug") {
            switch(displayWindow.screenResolution) {
            case 0:
                width=750;
                break
            case 1:
                width=1024;
                break
            case 2:
                width = Screen.desktopAvailableWidth
                break
            }
        }
        return width
    }
    function getScreenHeight() {
        var height = Screen.desktopAvailableHeight
        if(BUILD_TYPE === "debug") {
            switch(displayWindow.screenResolution) {
            case 0:
                height=480;
                break
            case 1:
                height=600;
                break
            case 2:
                height = Screen.desktopAvailableHeight
                break
            }
        }
        return height
    }

    //  FontLoader {
    //    //init fontawesome
    //    source: "qrc:/data/3rdparty/font-awesome-4.6.1/fonts/fontawesome-webfont.ttf"
    //  }

    Connections {
        target: VeinEntity
        function onSigStateChanged(t_state) {
            if(t_state === VeinEntity.VQ_LOADED) {
                dynamicPageModel.initModel();
                pageView.model = dynamicPageModel;

                console.log("Loaded session: ", currentSession);
                ModuleIntrospection.reloadIntrospection();

                // rescue dyn sources binding over session change
                dynamicPageModel.countActiveSources = Qt.binding(function() {
                    if(ModuleIntrospection.hasDependentEntities(["SourceModule1"])) {
                        return VeinEntity.getEntity("SourceModule1").ACT_CountSources
                    } else {
                        return 0
                    }
                });

                pageLoader.active = true;
                controlsBar.rangeIndicatorDependenciesReady = true;
                let lastPageSelected = GC.lastPageViewIndexSelected
                if(lastPageSelected >= pageView.model.count) {
                    lastPageSelected = 0
                }
                if(pageView.model.count) {
                    pageView.pageLoaderSource = pageView.model.get(lastPageSelected).elementValue;
                }
                loadingScreen.close();
                GC.entityInitializationDone = true
                controlsBar.pageViewVisible = false
            }
        }

        function onSigEntityAvailable(t_entityName) {
            var checkRequired = false;
            var entId = VeinEntity.getEntity(t_entityName).entityId()
            if(entId === 0) {
                currentSession = Qt.binding(function() {
                    return VeinEntity.getEntity("_System").Session;
                });
                GC.currentSession = Qt.binding(function() {
                    return currentSession;
                });
                pageView.sessionComponent = Qt.binding(function() {
                    return currentSession;
                });
            }
        }
    }

    Shortcut {
        enabled: BUILD_TYPE === "debug"
        sequence: "F11"
        autoRepeat: false
        onActivated: {
            debugBypass = !debugBypass;
        }
    }

    Shortcut {
        enabled: BUILD_TYPE === "debug"
        sequence: "F3"
        autoRepeat: false
        onActivated: {
            screenResolution = (screenResolution+1) % 3
            GC.setScreenResolution(screenResolution)
        }
    }

    NotificationManager {
        id: notificationManager
        window: displayWindow
        ySpacing: 20
        notificationWidth: 300
        maxOnScreen: 20
        property bool accuDown: AccuState.accuDown
        onAccuDownChanged: {
            if(accuDown)
                notificationManager.notify("Message", Z.tr("Battery low !\nPlease charge the device before it turns down"));
            else
                    notificationManager.close();
        }
        property bool accuCharging: AccuState.accuCharging
        onAccuChargingChanged: {
            if(accuCharging)
                notificationManager.close();
        }
    }
    Flickable {
        // main view displaying pages and other stuff - (flickable for virtual keyboard)
        id: flickable
        anchors.fill: parent
        enabled: GC.entityInitializationDone === true
        contentWidth: parent.width;
        contentHeight: parent.height
        boundsBehavior: Flickable.StopAtBounds
        interactive: false
        NumberAnimation on contentY {
            duration: 300
            id: flickableAnimation
        }

        StackLayout {
            id: layoutStack
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: controlsBar.top
            anchors.margins: 8
            currentIndex: GC.entityInitializationDone ? GC.layoutStackEnum.layoutPageIndex : GC.layoutStackEnum.layoutSplashIndex

            ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
            //DefaultProperty: [
            Loader {
                id: pageLoader
                source: pageView.pageLoaderSource
                asynchronous: true
            }
            Loader {
                sourceComponent: rangePeak
                active: layoutStack.currentIndex===GC.layoutStackEnum.layoutRangeIndex
                onActiveChanged: {
                    if(!active && pageLoader.item) {
                        pageLoader.item.forceActiveFocus()
                    }
                }
            }
            Loader {
                id: loggerSettingsLoader
                sourceComponent: LoggerSettingsStack { }
                active: layoutStack.currentIndex===GC.layoutStackEnum.layoutLoggerIndex
                onActiveChanged: {
                    if(!active && pageLoader.item) {
                        pageLoader.item.forceActiveFocus()
                    }
                }
            }
            Loader {
                sourceComponent: settingsCmp
                active: layoutStack.currentIndex===GC.layoutStackEnum.layoutSettingsIndex
                onActiveChanged: {
                    if(!active && pageLoader.item) {
                        pageLoader.item.forceActiveFocus()
                    }
                }
            }
            Loader {
                sourceComponent: statusCmp
                active: layoutStack.currentIndex===GC.layoutStackEnum.layoutStatusIndex
                onActiveChanged: {
                    if(!active && pageLoader.item) {
                        pageLoader.item.forceActiveFocus()
                    }
                }
            }
            Loader {
                sourceComponent: splashCmp
                active: layoutStack.currentIndex===GC.layoutStackEnum.layoutSplashIndex
            }
            ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
        }

        Component {
            id: rangePeak
            Item {
                RangeMenu {
                    id: rangeMenu
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
//                    anchors.rightMargin: parent.width
                }
            }
        }


        Component {
            id: statusCmp
            StatusView {}
        }
        Component {
            id: settingsCmp
            Settings {}
        }
        Component {
            id: splashCmp
            Image {
                anchors.fill: parent
                anchors.margins: parent.height / 4
                source: "qrc:/data/staticdata/resources/ZERA-old-school-large.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        MainToolBar {
            id: controlsBar
            height: parent.height/16
            anchors.bottom: parent.bottom
            width: displayWindow.width

            entityInitializationDone: GC.entityInitializationDone;
            layoutStackObj: layoutStack
            loggerSettingsStackObj: loggerSettingsLoader.item
        }

        // Note: The only way to pass complex stuff ListModel below is to pass
        // ids of items.

        // running state items
        EntityErrorMeasHelper {
            id: errMeasHelper
        }

        ListModel {
            id: dynamicPageModel
            property int countActiveSources: 0
            function updateSourceView() {
                if((ASWGL.isServer && !ASWGL.sourceEnabled)) {
                    return
                }
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
                if(countActiveSources > 0 && sourceViewPosition === -1) {
                    let iconName = ""
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/source.png"
                    }
                    append({name: "Source control", icon: iconName, elementValue: sourceViewQml});
                }
                // remove view?
                else if(countActiveSources === 0 && sourceViewPosition >= 0) {
                    remove(sourceViewPosition)
                    if(GC.lastPageViewIndexSelected === sourceViewPosition) {
                        if(pageView.model.count) {
                            pageView.pageLoaderSource = pageView.model.get(0).elementValue
                        }
                        else {
                            pageView.pageLoaderSource = ""
                        }
                        GC.setLastPageViewIndexSelected(0)
                    }
                }
            }
            onCountActiveSourcesChanged: {
                updateSourceView()
            }

            function initModel() {
                clear()
                let dftAvail = ModuleIntrospection.hasDependentEntities(["DFTModule1"])
                let isReference = ModuleIntrospection.hasDependentEntities(["REFERENCEModule1"])
                controlsBar.rotaryFieldDependenciesReady = dftAvail && !isReference && !dcSession
                let iconName = ""
                if(emobSession) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/act_values.png"
                    }
                    append({name: "Actual values", icon: iconName, elementValue: "qrc:/qml/pages/EMOBActualValueTabsPage.qml"});
                }
                else if(dcSession) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/act_values.png"
                    }
                    append({name: "Actual values DC", icon: iconName, elementValue: "qrc:/qml/pages/DCActualValueTabsPage.qml"});
                }
                else {
                    if(ModuleIntrospection.hasDependentEntities(["RMSModule1", "LambdaModule1", "THDNModule1", "DFTModule1", "POWER1Module1", "POWER1Module2", "POWER1Module3", "RangeModule1"])) {
                        if(!ASWGL.isServer) {
                            iconName = "qrc:/data/staticdata/resources/act_values.png"
                        }
                        append({name: "Actual values", icon: iconName, elementValue: "qrc:/qml/pages/ActualValueTabsPage.qml"});
                    }
                }

                if(ModuleIntrospection.hasDependentEntities(["FFTModule1"]) || ModuleIntrospection.hasDependentEntities(["OSCIModule1"])) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/osci.png"
                    }
                    append({name: "Harmonics & Curves", icon: iconName, elementValue: "qrc:/qml/pages/FftTabPage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["Power3Module1"])) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/hpower.png"
                    }
                    append({name: "Harmonic power values", icon: iconName, elementValue: "qrc:/qml/pages/HarmonicPowerTabPage.qml"});
                }
                if(!String(currentSession).includes('ref-session')) {
                    if(ModuleIntrospection.hasDependentEntities(["SEC1Module1"]) || ModuleIntrospection.hasDependentEntities(["SEC1Module2"]) || ModuleIntrospection.hasDependentEntities(["SEM1Module1"]) || ModuleIntrospection.hasDependentEntities(["SPM1Module1"])) {
                        if(!ASWGL.isServer) {
                            iconName = "qrc:/data/staticdata/resources/error_calc.png"
                        }
                        append({name: "Comparison measurements", icon: iconName, elementValue: "qrc:/qml/pages/ComparisonTabsView.qml", activeItem: errMeasHelper});
                    }
                }
                else {
                    if(ModuleIntrospection.hasDependentEntities(["SEC1Module1"])) {
                        if(!ASWGL.isServer) {
                            iconName = "qrc:/data/staticdata/resources/error_calc.png"
                        }
                        append({name: "Quartz reference measurement", icon: iconName, elementValue: "qrc:/qml/pages/QuartzModulePage.qml", activeItem: errMeasHelper});
                    }
                }
                if(ModuleIntrospection.hasDependentEntities(["Burden1Module1"]) || ModuleIntrospection.hasDependentEntities(["Burden1Module2"])) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/burden.png"
                    }
                    append({name: "Burden values", icon: iconName, elementValue: "qrc:/qml/pages/BurdenModulePage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["Transformer1Module1"])) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/transformer.png"
                    }
                    append({name: "Transformer values", icon: iconName, elementValue: "qrc:/qml/pages/TransformerModulePage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["POWER2Module1"])) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/ced_power_values.png"
                    }
                    append({name: "CED power values", icon: iconName, elementValue: "qrc:/qml/pages/CEDModulePage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["REFERENCEModule1", "DFTModule1"])) {
                    if(!ASWGL.isServer) {
                        iconName = "qrc:/data/staticdata/resources/ref_values.png"
                    }
                    append({name: "DC reference values", icon: iconName, elementValue: "qrc:/qml/pages/RefModulePage.qml"});
                }
            }
        }

        PageView {
            id: pageView
            anchors.fill: parent
            ///@note do not break binding by setting visible directly
            visible: controlsBar.pageViewVisible;
            onCloseView: controlsBar.pageViewVisible = false;
            onSessionChanged: {
                layoutStack.currentIndex=0;
                controlsBar.rangeIndicatorDependenciesReady = false;
                pageLoader.active = false;
                GC.entityInitializationDone = false;
                loadingScreen.open();
            }
        }
    }

    Loader {
        active: debugBypass === true
        sourceComponent: Item {
            height: 100
            Label {
                id: windowSize
                text: String("Window size: %1x%2").arg(displayWindow.width).arg(displayWindow.height)
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 32
            }
            FpsItem {
                anchors.left: windowSize.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    InputPanel {
        id: inputPanel
        parent: Overlay.overlay
        z:100
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        property bool textEntered: Qt.inputMethod.visible
        onHeightChanged: GC.vkeyboardHeight = height
        opacity: 0
        NumberAnimation on opacity {
            id: keyboardAnimation
            onStarted: {
                if(to === 1) {
                    inputPanel.visible = GC.showVirtualKeyboard
                }
            }
            onFinished: {
                if(to === 0) {
                    inputPanel.visible = false
                }
            }
        }
        // keyboard is an Overlay child. Overlay is shifted if keyboard is over textelement.
        // Animation shifts keyboard in opposite direction of Overlay to keep absolute position static.
        NumberAnimation on anchors.bottomMargin {
            duration: 300
            id: keyboardAnimation2
        }

        onTextEnteredChanged: {
            var rectInput = Qt.inputMethod.anchorRectangle
            if(inputPanel.textEntered) {
                if(GC.showVirtualKeyboard) {
                    if(rectInput.bottom > inputPanel.y) {
                        // shift flickable (normal elements)
                        flickableAnimation.to = rectInput.bottom - inputPanel.y + 10
                        // shift overlay (Popup)
                        overlayAnimation.to = -(rectInput.bottom - inputPanel.y + 10)
                        // shift keyboard (keep static)
                        keyboardAnimation2.to = -(rectInput.bottom - inputPanel.y + 10)

                        overlayAnimation.start()
                        keyboardAnimation2.start()
                        flickableAnimation.start()
                    }
                    keyboardAnimation.to = 1
                    keyboardAnimation.duration = 500
                    keyboardAnimation.start()
                }
            }
            else {
                if(flickable.contentY !== 0) {
                    // shift everything back
                    overlayAnimation.to = 0
                    keyboardAnimation2.to = 0
                    flickableAnimation.to = 0
                    overlayAnimation.start()
                    keyboardAnimation2.start()
                    flickableAnimation.start()
                }
                keyboardAnimation.to = 0
                keyboardAnimation.duration = 0
                keyboardAnimation.start()
            }
        }
    }

    // Overlay animation. Shift overlay if textfield is under keyboard (for popups)
    NumberAnimation on Overlay.overlay.y {
        duration: 300
        id: overlayAnimation
    }

    Popup {
        //is shown when switching sessions
        id: loadingScreen
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
