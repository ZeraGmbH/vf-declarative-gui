import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import VeinEntity 1.0

import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/range_module" as RangeControls
import "qrc:/data/staticdata/FontAwesome.js" as FA

ToolBar {
  id: root
  property alias rotaryFieldDependenciesReady: rotaryFieldIndicatorLoader.active;
  property alias rangeIndicatorDependenciesReady: rangeIndicator.active;
  property bool entityInitializationDone: false;
  onEntityInitializationDoneChanged: {
    if(entityInitializationDone)
    {
      measurementPaused = Qt.binding(function() {
        return VeinEntity.getEntity("_System").ModulesPaused;
      });
    }
  }

  property bool measurementPaused: false;
  property bool pageViewVisible: false;
  property QtObject layoutStackObj;



  background: Rectangle { color: "#206040" } /// @todo: replace with some color name??
  //provide more contrast
  Material.accent: Material.Amber

  Component {
    id: rotaryFieldCmp
    CCMP.RotaryFieldIndicator {}
  }


  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 4
    anchors.rightMargin: 4

    ToolButton {
      implicitHeight: parent.height
      font.family: "FontAwesome"
      font.pointSize: 18
      text: FA.fa_columns
      highlighted: root.layoutStackObj.currentIndex===GC.layoutStackEnum.layoutPageIndex
      enabled: root.entityInitializationDone === true
      onClicked: {
        //shows the selection of available pages, or returns to the current page when in (range / settings / logger / appinfo) view
        if(root.layoutStackObj.currentIndex===GC.layoutStackEnum.layoutPageIndex)
        {
          root.pageViewVisible=true;
        }
        else
        {
          root.layoutStackObj.currentIndex=GC.layoutStackEnum.layoutPageIndex;
        }
      }
    }
    ToolButton {
      implicitHeight: parent.height
      implicitWidth: rangeIndicator.width
      highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutRangeIndex
      enabled: root.entityInitializationDone === true
      onClicked: {
        //show range menu
        if(rangeIndicator.active === true)
        {
          root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutRangeIndex;
        }
      }

      RangeControls.RangeIndicator {
        id: rangeIndicator
        width: Math.ceil(root.width/2)
        height: root.height
        active: false
      }
    }

    ToolButton {
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

    ToolButton {
      implicitHeight: parent.height
      font.family: "FontAwesome"
      font.pointSize: 14
      text: root.measurementPaused ? FA.fa_play : FA.fa_pause
      enabled: root.entityInitializationDone === true
      highlighted: root.measurementPaused
      onClicked: {
        //pause button
        VeinEntity.getEntity("_System").ModulesPaused = !root.measurementPaused;
      }
    }
    ToolButton {
      implicitHeight: parent.height
      implicitWidth: root.width/16
      font.family: "FontAwesome"
      font.pointSize:  18
      text: FA.fa_download
      highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutLoggerIndex;
      enabled: root.entityInitializationDone === true;
      visible: root.entityInitializationDone === true && VeinEntity.hasEntity("_LoggingSystem")
      onClicked: {
        //shows the logger
        root.layoutStackObj.currentIndex=GC.layoutStackEnum.layoutLoggerIndex;
      }
    }
    ToolButton {
      implicitHeight: parent.height
      implicitWidth: root.width/16
      font.family: "FontAwesome"
      font.pointSize:  18
      text: FA.fa_cogs
      highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutSettingsIndex;
      enabled: root.entityInitializationDone === true
      onClicked: {
        //shows the settings
        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutSettingsIndex;
      }
    }
    ToolButton {
      implicitHeight: parent.height
      implicitWidth: root.width/16
      font.family: "FontAwesome"
      font.pointSize:  18
      text: FA.fa_info_circle
      highlighted: root.layoutStackObj.currentIndex === GC.layoutStackEnum.layoutStatusIndex
      onClicked: {
        //shows the appinfo
        root.layoutStackObj.currentIndex = GC.layoutStackEnum.layoutStatusIndex;
      }
    }
    /*
      //placeholder for managing Connections to different servers in android
    ToolButton {
      implicitHeight: parent.height
      font.family: "FontAwesome"
      font.pointSize: 14
      text: FA.icon(FA.fa_server) + ZTR["Remotes"]
      highlighted: root.currentLayoutIndex===layoutStackEnum.layout<...>Index
      visible: OS_TYPE==="android" || debugBypass
      CCMP.DebugRectangle {
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
