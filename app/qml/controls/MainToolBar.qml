import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import AccumulatorState 1.0
import SchnubbelState 1.0
import AdjustmentState 1.0
import VeinEntity 1.0
import FontAwesomeQml 1.0
import ZeraComponents 1.0
import "ranges"
import "logger"

ToolBar {
    id: root
    property alias rotaryFieldDependenciesReady: rotaryFieldIndicatorLoader.active;
    property alias rangeIndicatorDependenciesReady: rangeIndicator.active;

    readonly property bool entityInitializationDone: GC.entityInitializationDone
    onEntityInitializationDoneChanged: {
        if(entityInitializationDone) {
            measurementPaused = Qt.binding(function() {
                return VeinEntity.getEntity("_System").ModulesPaused;
            });
            if(VeinEntity.hasEntity("_LoggingSystem")) {
                loggingActive = Qt.binding(function() {
                    return VeinEntity.getEntity("_LoggingSystem").LoggingEnabled;
                });
            }
            ttyCount = Qt.binding(function() {
                return Object.keys(VeinEntity.getEntity("_Files").Ttys).length
            });
        }
        else
            // avoid warnings on improper bindings
            menuLoader.active = false
    }

    property bool measurementPaused: false
    property bool loggingActive: false

    property int ttyCount: 0
    onTtyCountChanged: {
        settingsButtonRipple.startFlash()
    }
    property bool pageViewVisible: false     // PageView.visible is bound to pageViewVisible
    property QtObject layoutStackObj         // bound to main.qml / layoutStack
    property QtObject loggerSettingsStackObj // bound to LoggerSettingsStack

    function goHomeToPages() {
        root.layoutStackObj.currentIndex = entityInitializationDone ? GC.layoutStackEnum.layoutPageIndex : GC.layoutStackEnum.layoutSplashIndex
    }

    background: Rectangle { color: "#206040" } /// @todo: replace with some color name??
    //provide more contrast
    Material.accent: Material.Amber

    property real pointSize: {
        var pHeight = parent.height
        return pHeight > 0 ? pHeight * 0.038 : 18
    }

    Component {
        id: rotaryFieldCmp
        RotaryFieldIndicator {}
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 0.0

        ToolButton {
            id: pageSelectorButton
            implicitHeight: parent.height
            font.pointSize: pointSize
            text: FAQ.fa_columns
            highlighted: root.layoutStackObj.currentIndex===GC.layoutStackEnum.layoutPageIndex
            enabled: root.entityInitializationDone === true
            onClicked: {
                goHomeToPages()
                root.pageViewVisible = true;
            }
        }
        ToolButton {
            id: rangeButton
            implicitHeight: parent.height
            implicitWidth: rangeIndicator.width
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutRangeIndex
            enabled: root.entityInitializationDone === true
            onClicked: {
                if(rangeIndicator.active === true) {
                    // Already in range view?
                    if(root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutRangeIndex) {
                        goHomeToPages()
                    }
                    else {
                        // show range menu
                        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutRangeIndex;
                    }
                }
            }
            RangeIndicator {
                id: rangeIndicator
                width: Math.ceil(root.width/1.8)
                height: root.height
                pointSize: root.pointSize * 0.77
                active: false
                highlighted: rangeButton.highlighted
            }
        }
        ToolButton {
            id: rotaryFieldIndicator
            implicitHeight: parent.height
            implicitWidth: height*1.5
            highlighted: false;
            enabled: false
            visible: rotaryFieldIndicatorLoader.active
            //needs to be in a ToolButton to be correctly positioned in the ToolBar, but is not actually an interactive button
            Loader {
                id: rotaryFieldIndicatorLoader
                sourceComponent: rotaryFieldCmp
                height: parent.height
                width: parent.width
                active: false;
            }
        }
        Item {
            Layout.fillWidth: true
        }
        ToolButton {
            id: pauseButton
            implicitHeight: parent.height
            font.pointSize: pointSize * 0.77
            text: root.measurementPaused ? FAQ.fa_play : FAQ.fa_pause
            enabled: root.entityInitializationDone === true
            highlighted: root.measurementPaused
            onClicked: {
                //pause button
                VeinEntity.getEntity("_System").ModulesPaused = !root.measurementPaused;
            }
        }
        ToolButton {
            id: logStartButton
            implicitHeight: parent.height
            implicitWidth: root.width/16
            font.pointSize: pointSize
            text: FAQ.fa_download
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutLoggerIndex;
            enabled: root.entityInitializationDone === true
            visible: root.entityInitializationDone === true && VeinEntity.hasEntity("_LoggingSystem")
            AnimationActivity {
                targetItem: logStartButton
                running: loggingActive
            }
            Loader {
                id: menuLoader
                active: false
                function openMenu() {
                    menuLoader.active = true
                    menuLoader.item.open()
                }
                sourceComponent: LoggerMenu {
                    onLoggerSettingsMenu: {
                        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        loggerSettingsStackObj.showSettings()
                    }
                    onLoggerSessionsMenu: {
                        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        loggerSettingsStackObj.showSessionNameSelector(false)
                    }
                    onLoggerCustomDataMenu: {
                        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        loggerSettingsStackObj.showCustomDataSelector()
                    }
                    onLoggerExportMenu: {
                        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        loggerSettingsStackObj.showExportView()
                    }
                    Connections {
                        target: loggerSettingsStackObj
                        function onPleaseCloseMe(butOpenMenu) {
                            goHomeToPages()
                            if(butOpenMenu)
                                menuLoader.openMenu()
                        }
                    }
                }
            }
            onClicked: {
                // we are already in logger settings
                if(root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutLoggerIndex) {
                    goHomeToPages()
                    // seems we were presses in logger settings without database selected
                    // let's assume user wants to get out of settings then and do not re.open
                    // logger settings
                    if(VeinEntity.getEntity("_LoggingSystem").DatabaseReady)
                        menuLoader.openMenu()
                }
                else {
                    // are we somewhere but pages?
                    if(root.layoutStackObj.currentIndex !== GC.layoutStackEnum.layoutPageIndex) {
                        goHomeToPages()
                    }
                    menuLoader.openMenu()
                }
            }
        }
        ToolButton {
            id: settingsButton
            implicitHeight: parent.height
            implicitWidth: root.width/16
            font.pointSize: pointSize
            text: FAQ.fa_cogs
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutSettingsIndex;
            onClicked: {
                // already in Settings?
                if(root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutSettingsIndex) {
                    goHomeToPages()
                }
                else {
                    // show settings
                    root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutSettingsIndex;
                }
            }
            ZFlashingRipple {
                id: settingsButtonRipple
                anchor: settingsButton
                ignoreFirst: false
            }
        }
        BatteryToolButton {
            implicitHeight: parent.height
            implicitWidth: parent.width / 22
            highlighted: false;
            enabled: false
            visible: AccuState.accuAvail
        }
        ToolButton {
            id: infoButton
            implicitHeight: parent.height
            implicitWidth: root.width/16
            font.pointSize: pointSize
            text: FAQ.fa_info_circle
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutStatusIndex
            Material.foreground: { // Note: highligted overrifdes Material.foreground
                var _opacity = 1
                var _color = Material.White
                if (!AdjState.adjusted) {
                    if (SchnubbState.inserted)
                        _color = blinker.show ? Material.Blue : Material.Red
                    else {
                        if (!highlighted)
                            _opacity = blinker.show ? 1 : 0
                        _color = Material.Red
                    }
                }
                else if (SchnubbState.inserted)
                    _color = blinker.show ? Material.Blue : Material.White

                infoButton.opacity = _opacity
                return _color
            }
            Timer {
                id: blinker
                interval: 300
                repeat: true
                running: true
                property bool show: true
                onTriggered: {
                    show = !show
                }
            }
            onClicked: {
                // Already in appinfo?
                if(root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutStatusIndex) {
                    goHomeToPages()
                }
                else {
                    // shows appinfo
                    root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutStatusIndex
                }
            }
        }
    }
}
