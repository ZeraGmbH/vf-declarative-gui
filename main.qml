import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0

import "qrc:/pages" as Pages
import "qrc:/components/common" as CCMP
import "qrc:/data/staticdata" as StaticData
import "qrc:/data/staticdata/FontAwesome.js" as FA
import ZeraSettings 1.0

ApplicationWindow {
  id: displayWindow

  property bool entitiesInitialized: false;
  property bool debugBypass: false;
  property string currentSession;
  property var requiredIds: [];
  property bool measuringPaused: false;

  visible: true
  width: 1024
  height: 600
  title: "ZeraGUI"
  Material.theme: Material.Dark
  Material.accent: "#339966"


//  onClosing: {
//    settings.globalSettings.saveToFile(settings.globalSettings.getCurrentFilePath(), true);
//  }

  Component.onCompleted: {
    currentSession = Qt.binding(function() {
      return VeinEntity.getEntity("_System").Session;
    })
  }

  onCurrentSessionChanged: {
    switch(currentSession)
    {
    case "com5003-meas-session.json":
    {
      requiredIds = [0, 2, 1020, 1030, 1040, 1050, 1060, 1070, 1071, 1072, 1100, 1110, 1120, 1130, 1140, 1150];
      break;
    }
    case "com5003-ref-session.json":
    {
      requiredIds = [0, 2, 1001, 1020, 1050, 1150];
      break;
    }
    case "com5003-ced-session.json":
    {
      requiredIds = [0, 2, 1020, 1030, 1040, 1050, 1060, 1070, 1071, 1072, 1090, 1110, 1120, 1130, 1140, 1150];
      break;
    }
    case "mt310s2-meas-session.json":
    {
      requiredIds = [0, 2, 200, 1020, 1030, 1040, 1050, 1060, 1070, 1071, 1072, 1100, 1110, 1120, 1130, 1140, 1150, 1160, 1161, 1170]; //1180
      break;
    }
    }

    for(var oldId in VeinEntity.getEntityList())
    {
      if(requiredIds.indexOf(oldId)<0) //not contained
      {
        VeinEntity.entityUnsubscribeById(oldId);
      }
    }

    requiredIds.sort();
    for(var subscriptionId in requiredIds)
    {
      VeinEntity.entitySubscribeById(requiredIds[subscriptionId]);
    }
  }

  Loader {
    active: HAS_QT_VIRTUAL_KEYBOARD
    Component.onCompleted: {
      setSource("qrc:/components/common/VirtualKeyboardConfigurator.qml", { "textPreviewMode": true });
    }
  }

  Timer {
    interval: 5000
    repeat: false
    running: VeinEntity.state !== VeinEntity.VQ_LOADED;
    onTriggered: {
      console.error("Could not load all required modules, given up after", interval/1000, "seconds\nRequired:", requiredIds.sort(), "\nResolved:", VeinEntity.getEntityList().sort());
    }
  }

  Connections {
    target: VeinEntity
    onStateChanged: {
      if(t_state === VeinEntity.VQ_LOADED)
      {
        dynamicPageModel.initModel();
        pageView.model = dynamicPageModel;

        console.log("Loaded session: ", currentSession);
        ModuleIntrospection.reloadIntrospection();
        pageLoader.active = true;
        rangeIndicator.active = true;
        pageView.currentValue = pageView.model.get(0).elementValue;
        loadingScreen.close();
        displayWindow.entitiesInitialized = true;
      }
    }

    onSigEntityAvailable: {
      var checkRequired = false;
      var entId = VeinEntity.getEntity(t_entityName).entityId()
      if(entId === 0)
      {
        currentSession = Qt.binding(function() {
          return VeinEntity.getEntity("_System").Session;
        });
        pageView.sessionComponent = Qt.binding(function() {
          return currentSession;
        });
        measuringPaused = Qt.binding(function() {
          return VeinEntity.getEntity("_System").ModulesPaused;
        });
      }
    }
  }

  ZeraGlobalSettings {
    id: settings
  }

  FontLoader {
    source: "qrc:/data/3rdparty/font-awesome-4.6.1/fonts/fontawesome-webfont.ttf"
  }

  Shortcut {
    enabled: BUILD_TYPE === "debug"
    sequence: "F11"
    autoRepeat: false
    onActivated: {
      debugBypass = !debugBypass;
    }
  }

  CCMP.FpsItem {
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: 48
    height: 24
    width: 64
    z: Infinity
    visible: debugBypass === true
  }

//  /// @todo remove debugging code
//  Shortcut {
//    property bool cLang: false
//    enabled: BUILD_TYPE === "debug"
//    sequence: "F2"
//    autoRepeat: false
//    onActivated: {
//      cLang = !cLang;
//      if(cLang)
//      {
//        ZTR.changeLanguage("en_US");
//      }
//      else
//      {
//        ZTR.changeLanguage("de_DE");
//      }
//    }
//  }

  Shortcut {
    property bool smallResolution: false
    enabled: BUILD_TYPE === "debug"
    sequence: "F3"
    autoRepeat: false
    onActivated: {
      smallResolution = !smallResolution;
      if(smallResolution)
      {
        displayWindow.width=800;
        displayWindow.height=480;
      }
      else
      {
        displayWindow.width=1024;
        displayWindow.height=600;
      }
    }
  }

  CCMP.SwipeArea {
    anchors.fill: parent
    drag.axis: Drag.XAxis
    focus: true
    enabled: displayWindow.entitiesInitialized === true
    triggerDistance: displayWindow.width/15

    onHorizontalSwipe: {
      if(pageView.visible !== true)
      {
        layoutStack.currentIndex=layoutStackEnum.layoutPageIndex;
        pageView.visible = true

        if(isLeftDirection)
        {
          pageView.decrementElement()
        }
        else
        {
          pageView.incrementElement()
        }
      }
    }

    StackLayout {
      id: layoutStack
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: controlsBar.top
      anchors.margins: 8
      currentIndex: displayWindow.entitiesInitialized ? layoutStackEnum.layoutPageIndex : layoutStackEnum.layoutStatusIndex

      QtObject {
        id: layoutStackEnum

        readonly property int layoutPageIndex: 0
        readonly property int layoutRangeIndex: 1
        readonly property int layoutLoggerIndex: 2
        readonly property int layoutSettingsIndex: 3
        readonly property int layoutStatusIndex: 4
      }

      ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
      //DefaultProperty: [
      Loader {
        id: pageLoader
        source: pageView.currentValue
        asynchronous: true
      }
      Loader {
        sourceComponent: rangePeak
        active: layoutStack.currentIndex===layoutStackEnum.layoutRangeIndex
      }
      Loader {
        sourceComponent: loggerCmp
        active: layoutStack.currentIndex===layoutStackEnum.layoutLoggerIndex
      }
      Loader {
        sourceComponent: settingsCmp
        active: layoutStack.currentIndex===layoutStackEnum.layoutSettingsIndex
      }
      Loader {
        sourceComponent: statusCmp
        active: layoutStack.currentIndex===layoutStackEnum.layoutStatusIndex
      }
      //Pages.RemoteSelection {}
      // ]
      ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
    }

    Component {
      id: rangePeak
      Item {
        CCMP.RangeMenu {
          id: rangeMenu
          anchors.fill: parent
          anchors.leftMargin: 40
          anchors.topMargin: 20
          anchors.bottomMargin: 20
          anchors.rightMargin: parent.width/2
        }
        CCMP.RangePeak {
          anchors.fill: parent
          anchors.rightMargin: 20
          anchors.topMargin: 20
          anchors.bottomMargin: 20
          anchors.leftMargin: parent.width/2+50
          rangeGrouping: rangeMenu.groupingActive
        }
      }
    }
    ListModel {
      id: syslogModel

      /**
       * @b loads json formatted log messages from systemd-journal-gatewayd at the same ip address as the modulemanager
       * Only the zera-services user (_UID=15000) is emitting relevant log messages for this case
       */
      Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
          var entryNum = 0;
          switch(xhr.readyState)
          {
//          case XMLHttpRequest.HEADERS_RECEIVED:
//            console.log("Headers -->", xhr.getAllResponseHeaders());
//            break;
          case XMLHttpRequest.LOADING:
            entryNum = syslogModel.count; //the response always contains the full data, but we need to parse only the new entries
            //[fallthrough]
          case XMLHttpRequest.DONE:
            var a = xhr.responseText.split("\n");
//            if(entryNum>0)
//            {
//              console.log("processing partial data for", a.length-entryNum-1, "entries")
//            }
            for(; entryNum<a.length; ++entryNum)
            {
              var jsonString = a[entryNum];
              if(jsonString.indexOf("{") === 0 && jsonString.lastIndexOf("}") === jsonString.length-1) //do not process partial json data
              {
                var jsonItem = JSON.parse(jsonString);
                //showProps(jsonItem);
                syslogModel.append(jsonItem);
              }
            }
            break;
          default:
            break;
          }
        }
        xhr.open("GET", "http://"+GC.serverIpAddress+":19531/entries?follow&boot&_UID=15000");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.send();
      }
    }

    Component {
      id: statusCmp
      CCMP.StatusView { errorDataModel: syslogModel }
    }
    Component {
      id: loggerCmp
      CCMP.LoggerSettings {}
    }
    Component {
      id: settingsCmp
      CCMP.Settings {}
    }


    ToolBar {
      id: controlsBar
      height: parent.height/16
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      background: Rectangle { color: "#206040" } /// @todo: replace with some color name??
      //provide more contrast
      Material.accent: Material.Amber

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        ToolButton {
          implicitHeight: parent.height
          font.family: "FontAwesome"
          font.pointSize: 18
          text: FA.fa_columns
          highlighted: layoutStack.currentIndex===layoutStackEnum.layoutPageIndex
          enabled: displayWindow.entitiesInitialized === true
          onClicked: {
            if(layoutStack.currentIndex===layoutStackEnum.layoutPageIndex)
            {
              pageView.visible=true;
            }
            else
            {
              layoutStack.currentIndex=layoutStackEnum.layoutPageIndex;
            }
          }
        }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: rangeIndicator.width
          highlighted: layoutStack.currentIndex===layoutStackEnum.layoutRangeIndex
          enabled: displayWindow.entitiesInitialized === true
          onClicked: {
            if(rangeIndicator.active === true)
            {
              layoutStack.currentIndex=layoutStackEnum.layoutRangeIndex;
            }
          }

          CCMP.RangeIndicator {
            id: rangeIndicator
            width: Math.ceil(displayWindow.width/1.8)
            height: controlsBar.height
            active: false
          }
        }

        ToolButton {
          implicitHeight: parent.height
          font.family: "FontAwesome"
          font.pointSize: 14
          text: displayWindow.measuringPaused ? FA.fa_play : FA.fa_pause
          enabled: displayWindow.entitiesInitialized === true
          highlighted: displayWindow.measuringPaused
          onClicked: {
            VeinEntity.getEntity("_System").ModulesPaused = !displayWindow.measuringPaused;
          }
        }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: displayWindow.width/16
          font.family: "FontAwesome"
          font.pointSize:  18
          text: FA.fa_download
          highlighted: layoutStack.currentIndex === layoutStackEnum.layoutLoggerIndex;
          enabled: displayWindow.entitiesInitialized === true;
          visible: displayWindow.entitiesInitialized === true && VeinEntity.hasEntity("_LoggingSystem")
          onClicked: {
            layoutStack.currentIndex=layoutStackEnum.layoutLoggerIndex;
          }
        }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: displayWindow.width/16
          font.family: "FontAwesome"
          font.pointSize:  18
          text: FA.fa_cogs
          highlighted: layoutStack.currentIndex===layoutStackEnum.layoutSettingsIndex;
          enabled: displayWindow.entitiesInitialized === true
          onClicked: {
            layoutStack.currentIndex=layoutStackEnum.layoutSettingsIndex;
          }
        }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: displayWindow.width/16
          font.family: "FontAwesome"
          font.pointSize:  18
          text: FA.fa_info_circle
          highlighted: layoutStack.currentIndex===layoutStackEnum.layoutStatusIndex
          onClicked: {
            layoutStack.currentIndex=layoutStackEnum.layoutStatusIndex;
          }
        }
        //        ToolButton {
        //          implicitHeight: parent.height
        //          font.family: "FontAwesome"
        //          font.pointSize: 14
        //          text: FA.icon(FA.fa_server) + ZTR["Remotes"]
        //          highlighted: layoutStack.currentIndex===layoutStackEnum.layout<...>Index
        //          visible: OS_TYPE==="android" || debugBypass
        //          CCMP.DebugRectangle {
        //            anchors.fill: parent
        //            visible: debugBypass && OS_TYPE!=="android"
        //          }
        //          onClicked: {
        //            ;;
        //          }
        //        }
      }
    }

    ListModel {
      id: dynamicPageModel

      function hasDependentEntities(t_list) {
        var retVal = false;
        if(t_list !== undefined)
        {
          if(t_list.length > 0)
          {
            var tmpEntityName;
            for(var tmpIndex in t_list)
            {
              tmpEntityName = t_list[tmpIndex];
              retVal = VeinEntity.hasEntity(tmpEntityName);

              if(retVal === false)
              {
                //exit loop
                break;
              }
            }
          }
          else
          {
            retVal = true;
          }
        }

        return retVal;
      }

      function initModel() {
        if(hasDependentEntities(["RMSModule1", "LambdaModule1", "THDNModule1", "DFTModule1", "POWER1Module1", "POWER1Module2", "POWER1Module3", "RangeModule1"]))
        {
          append({name: "Actual values", icon: "qrc:/data/staticdata/resources/act_values.png", elementValue: "qrc:/pages/ActualValuesPage.qml"});
        }
        if(hasDependentEntities(["OSCIModule1"]))
        {
          append({name: "Oscilloscope plot", icon: "qrc:/data/staticdata/resources/osci.png", elementValue: "qrc:/pages/OsciModulePage.qml"});
        }
        if(hasDependentEntities(["FFTModule1"]))
        {
          append({name: "Harmonics", icon: "qrc:/data/staticdata/resources/harmonics.png", elementValue: "qrc:/pages/FftModulePage.qml"});
        }
        if(hasDependentEntities(["POWER1Module1", "POWER1Module2", "POWER1Module3"]))
        {
          append({name: "Power values", icon: "qrc:/data/staticdata/resources/power.png", elementValue: "qrc:/pages/PowerModulePage.qml"});
        }
        if(hasDependentEntities(["Power3Module1"]))
        {
          append({name: "Harmonic power values", icon: "qrc:/data/staticdata/resources/hpower.png", elementValue: "qrc:/pages/HarmonicPowerModulePage.qml"});
        }
        if(hasDependentEntities(["Burden1Module1", "Burden1Module2"]))
        {
          append({name: "Burden values", icon: "qrc:/data/staticdata/resources/burden.png", elementValue: "qrc:/pages/BurdenModulePage.qml"});
        }
        if(hasDependentEntities(["Transformer1Module1"]))
        {
          append({name: "Transformer values", icon: "qrc:/data/staticdata/resources/transformer.png", elementValue: "qrc:/pages/TransformerModulePage.qml"});
        }
        if(hasDependentEntities(["SEC1Module1"]))
        {
          append({name: "Error calculator", icon: "qrc:/data/staticdata/resources/error_calc.png", elementValue: "qrc:/pages/ErrorCalculatorModulePage.qml"});
        }
        if(hasDependentEntities(["DFTModule1"]))
        {
          append({name: "Vector diagram", icon: "qrc:/data/staticdata/resources/dft_values.png", elementValue: "qrc:/pages/DFTModulePage.qml"});
        }
        if(hasDependentEntities(["RMSModule1"]))
        {
          append({name: "RMS values", icon: "qrc:/data/staticdata/resources/rms_values.png", elementValue: "qrc:/pages/RMS4PhasePage.qml"});
        }
        if(hasDependentEntities(["POWER2Module1"]))
        {
          append({name: "CED power values", icon: "qrc:/data/staticdata/resources/ced_power_values.png", elementValue: "qrc:/pages/CEDModulePage.qml"});
        }
        if(hasDependentEntities(["REFERENCEModule1", "DFTModule1"]))
        {
          append({name: "Reference values", icon: "qrc:/data/staticdata/resources/ref_values.png", elementValue: "qrc:/pages/RefModulePage.qml"});
        }
      }
    }

    CCMP.PagePathView {
      id: pageView

      property string currentValue;

      visible: false
      onModelChanged: {
        if(model)
        {
          currentValue = model.get(0).elementValue;
          pageLoader.source = currentValue
        }
      }

      anchors.fill: parent
      onElementSelected: {
        if(elementValue !== "")
        {
          currentValue = elementValue.value
          pageLoader.source = currentValue
          visible = false
        }
      }
      onCancelSelected: visible = false
    }
  }

  Popup {
    id: loadingScreen
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    closePolicy: Popup.NoAutoClose
    modal: true
    visible: false
    implicitWidth: parent.width/10
    implicitHeight: parent.width/10
    BusyIndicator {
      running: visible
      anchors.fill: parent
    }
  }
}
