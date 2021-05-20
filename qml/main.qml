import QtQuick 2.12
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.VirtualKeyboard 2.4
import QtQuick.VirtualKeyboard.Settings 2.2
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraSettings 1.0
import ZeraFa 1.0

import "controls"

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
        onStateChanged: {
            if(t_state === VeinEntity.VQ_LOADED) {
                dynamicPageModel.initModel();
                pageView.model = dynamicPageModel;

                console.log("Loaded session: ", currentSession);
                ModuleIntrospection.reloadIntrospection();
                pageLoader.active = true;
                controlsBar.rangeIndicatorDependenciesReady = true;
                let lastPageSelected = GC.lastPageViewIndexSelected
                if(lastPageSelected >= pageView.model.count) {
                    lastPageSelected = 0
                }
                pageView.pageLoaderSource = pageView.model.get(lastPageSelected).elementValue;
                loadingScreen.close();
                GC.entityInitializationDone = true;
            }
        }

        onSigEntityAvailable: {
            var checkRequired = false;
            var entId = VeinEntity.getEntity(t_entityName).entityId()
            if(entId === 0) {
                currentSession = Qt.binding(function() {
                    return VeinEntity.getEntity("_System").Session;
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
                    anchors.leftMargin: 40
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    anchors.rightMargin: parent.width/2
                }
                RangePeak {
                    anchors.fill: parent
                    anchors.rightMargin: 20
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    anchors.leftMargin: parent.width/2+50
                    rangeGrouping: rangeMenu.groupingActive
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

        ListModel {
            id: dynamicPageModel

            function initModel() {
                clear()
                controlsBar.rotaryFieldDependenciesReady = ModuleIntrospection.hasDependentEntities(["DFTModule1"]) && !ModuleIntrospection.hasDependentEntities(["REFERENCEModule1"])
                if(ModuleIntrospection.hasDependentEntities(["RMSModule1", "LambdaModule1", "THDNModule1", "DFTModule1", "POWER1Module1", "POWER1Module2", "POWER1Module3", "RangeModule1"])) {
                    append({name: "Actual values", icon: "qrc:/data/staticdata/resources/act_values.png", elementValue: "qrc:/qml/pages/ActualValueTabsPage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["FFTModule1"]) || ModuleIntrospection.hasDependentEntities(["OSCIModule1"])) {
                    append({name: "Harmonics & Curves", icon: "qrc:/data/staticdata/resources/osci.png", elementValue: "qrc:/qml/pages/FftTabPage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["Power3Module1"])) {
                    append({name: "Harmonic power values", icon: "qrc:/data/staticdata/resources/hpower.png", elementValue: "qrc:/qml/pages/HarmonicPowerTabPage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["SEC1Module1"]) || ModuleIntrospection.hasDependentEntities(["SEC1Module2"]) || ModuleIntrospection.hasDependentEntities(["SEM1Module1"]) || ModuleIntrospection.hasDependentEntities(["SPM1Module1"])) {
                    append({name: "Comparison measurements", icon: "qrc:/data/staticdata/resources/error_calc.png", elementValue: "qrc:/qml/pages/ComparisonTabsView.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["Burden1Module1"]) || ModuleIntrospection.hasDependentEntities(["Burden1Module2"])) {
                    append({name: "Burden values", icon: "qrc:/data/staticdata/resources/burden.png", elementValue: "qrc:/qml/pages/BurdenModulePage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["Transformer1Module1"])) {
                    append({name: "Transformer values", icon: "qrc:/data/staticdata/resources/transformer.png", elementValue: "qrc:/qml/pages/TransformerModulePage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["POWER2Module1"])) {
                    append({name: "CED power values", icon: "qrc:/data/staticdata/resources/ced_power_values.png", elementValue: "qrc:/qml/pages/CEDModulePage.qml"});
                }
                if(ModuleIntrospection.hasDependentEntities(["REFERENCEModule1", "DFTModule1"])) {
                    append({name: "Reference values", icon: "qrc:/data/staticdata/resources/ref_values.png", elementValue: "qrc:/qml/pages/RefModulePage.qml"});
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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
        onTextEnteredChanged: {
            var rectInput = Qt.inputMethod.anchorRectangle
            if(inputPanel.textEntered) {
                if(GC.showVirtualKeyboard) {
                    if(rectInput.bottom > inputPanel.y) {
                        flickableAnimation.to = rectInput.bottom - inputPanel.y + 10
                        flickableAnimation.start()
                    }
                    keyboardAnimation.to = 1
                    keyboardAnimation.duration = 500
                    keyboardAnimation.start()
                }
            }
            else {
                if(flickable.contentY !== 0) {
                    flickableAnimation.to = 0
                    flickableAnimation.start()
                }
                keyboardAnimation.to = 0
                keyboardAnimation.duration = 0
                keyboardAnimation.start()
            }
        }
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
