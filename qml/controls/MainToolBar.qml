import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Material.impl 2.14
import QtQuick.Dialogs 1.1
import GlobalConfig 1.0
import AccumulatorState 1.0
import VeinEntity 1.0
import ZeraFa 1.0
import FontAwesomeQml 1.0
import "range_module"
import "logger"

ToolBar {
    id: root
    property alias rotaryFieldDependenciesReady: rotaryFieldIndicatorLoader.active;
    property alias rangeIndicatorDependenciesReady: rangeIndicator.active;

    property bool entityInitializationDone: GC.entityInitializationDone
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
            if(VeinEntity.hasEntity("_Files")) {
                veinTtys = Qt.binding(function() {
                    return VeinEntity.getEntity("_Files").Ttys;
                });
            }
        }
    }

    property bool measurementPaused: false
    property bool loggingActive: false
    property var veinTtys
    onVeinTtysChanged: {
        settingsButtonRipple.startFlash()
    }
    property bool pageViewVisible: false     // PageView.visible is bound to pageViewVisible
    property QtObject layoutStackObj         // bound to main.qml / layoutStack
    property QtObject loggerSettingsStackObj // bound to LoggerSettingsStack

    function goHomeToPages() {
        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutPageIndex
    }

    background: Rectangle { color: "#206040" } /// @todo: replace with some color name??
    //provide more contrast
    Material.accent: Material.Amber

    property real pointSize: parent.height > 0 ? parent.height * 0.038 : 18

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
            font.family: FA.old
            font.pointSize: pointSize
            text: FA.fa_columns
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
            font.family: FA.old
            font.pointSize: pointSize * 0.77
            text: root.measurementPaused ? FA.fa_play : FA.fa_pause
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
            font.family: FA.old
            font.pointSize: pointSize
            text: FA.fa_download
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutLoggerIndex;
            enabled: root.entityInitializationDone === true
            visible: root.entityInitializationDone === true && VeinEntity.hasEntity("_LoggingSystem")
            ActivityAnimation {
                targetItem: logStartButton
                running: loggingActive
            }
            Loader { // menu requires vein initialized && logging system available
                id: menuLoader
                sourceComponent: LoggerMenu {
                    onLoggerSettingsMenu: {
                        if(root.layoutStackObj.currentIndex !== GC.layoutStackEnum.layoutLoggerIndex) {
                            root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        }
                        loggerSettingsStackObj.showSettings()
                    }
                    onLoggerSessionsMenu: {
                        if(root.layoutStackObj.currentIndex !== GC.layoutStackEnum.layoutLoggerIndex) {
                            root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        }
                        loggerSettingsStackObj.showSessionNameSelector(false)
                    }
                    onLoggerCustomDataMenu: {
                        if(root.layoutStackObj.currentIndex !== GC.layoutStackEnum.layoutLoggerIndex) {
                            root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        }
                        loggerSettingsStackObj.showCustomDataSelector()
                    }
                    onLoggerExportMenu: {
                        if(root.layoutStackObj.currentIndex !== GC.layoutStackEnum.layoutLoggerIndex) {
                            root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutLoggerIndex;
                        }
                        loggerSettingsStackObj.showExportView()
                    }
                    Connections {
                        target: loggerSettingsStackObj
                        function onPleaseCloseMe(butOpenMenu) {
                            goHomeToPages()
                            if(butOpenMenu) {
                                 menuLoader.item.open()
                            }
                        }
                    }
                }
                active: root.entityInitializationDone === true && VeinEntity.hasEntity("_LoggingSystem")
            }
            onClicked: {
                // we are already in logger settings
                if(root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutLoggerIndex) {
                    goHomeToPages()
                    // seems we were presses in logger settings without database selected
                    // let's assume user wants to get out of settings then and do not re.open
                    // logger settings
                    if(VeinEntity.getEntity("_LoggingSystem").DatabaseReady) {
                        menuLoader.item.open()
                    }
                }
                else {
                    // are we somewhere but pages?
                    if(root.layoutStackObj.currentIndex !== GC.layoutStackEnum.layoutPageIndex) {
                        goHomeToPages()
                    }
                    // show our menu
                    menuLoader.item.open()
                }
            }
        }
        ToolButton {
            id: settingsButton
            implicitHeight: parent.height
            implicitWidth: root.width/16
            font.family: FA.old
            font.pointSize: pointSize
            text: FA.fa_cogs
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutSettingsIndex;
            enabled: root.entityInitializationDone === true
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
            FlashingRipple {
                id: settingsButtonRipple
                anchor: settingsButton
            }
        }
        BatteryToolButton {
            implicitHeight: parent.height
            implicitWidth: parent.width / 22
            highlighted: false;
            enabled: false
            visible: AccuState.accumulatorStatus !== 0
        }
        ToolButton {
            id: infoButton
            implicitHeight: parent.height
            implicitWidth: root.width/16
            font.family: FA.old
            font.pointSize: pointSize
            text: FA.fa_info_circle
            highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutStatusIndex
            Material.foreground: { // Note: highligted overrifdes Material.foreground
                let _opacity = 1
                let _color = Material.White
                if (!GC.adjustmentStatusOk) {
                    if (GC.schnubbelInserted)
                        _color = blinker.show ? Material.Blue : Material.Red
                    else {
                        if (!highlighted)
                            _opacity = blinker.show ? 1 : 0
                        _color = Material.Red
                    }
                }
                else if (GC.schnubbelInserted)
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
        /*
      //placeholder for managing Connections to different servers in android
    ToolButton {
      implicitHeight: parent.height
      font.family: FA.old
      font.pointSize: pointSize * 0.77
      text: FA.icon(FA.fa_server) + Z.tr("Remotes")
      highlighted: root.currentLayoutIndex===layoutStackEnum.layout<...>Index
      visible: OS_TYPE==="android" || debugBypass
      DebugRectangle {
        anchors.fill: parent
        visible: debugBypass && OS_TYPE!=="android"
      }
      onClicked: {
        ;;
      }
    }
    */
    }
}
