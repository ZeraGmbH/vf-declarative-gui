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

import "qrc:/qml/pages" as Pages
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/range_module" as RangeControls
import "qrc:/qml/controls/logger" as LoggerControls
import "qrc:/qml/controls/appinfo" as AppInfoControls
import "qrc:/qml/controls/settings" as SettingsControls
import "qrc:/qml/singletons" as Singletons
import "qrc:/data/staticdata" as StaticData
import "qrc:/data/staticdata/FontAwesome.js" as FA

ApplicationWindow {
  id: displayWindow

  //is set to true when the required entities are available
  property bool entitiesInitialized: false;
  //used to display the fps and other debug infos
  property bool debugBypass: false;
  //used to notify about the com5003 meas/CED/REF session change
  property string currentSession;

  visible: true
  width: Screen.desktopAvailableWidth
  height: Screen.desktopAvailableHeight
  flags: Qt.FramelessWindowHint
  title: "ZeraGUI"
  Material.theme: Material.Dark
  Material.accent: "#339966"

  Component.onCompleted: {
    currentSession = Qt.binding(function() {
      return VeinEntity.getEntity("_System").Session;
    })
    VirtualKeyboardSettings.locale = GC.localeName
  }

  onCurrentSessionChanged: {
    var availableEntityIds = VeinEntity.getEntity("_System")["Entities"];

    var oldIdList = VeinEntity.getEntityList();
    for(var oldIdIterator in oldIdList)
    {
      VeinEntity.entityUnsubscribeById(oldIdList[oldIdIterator]);
    }

    if(availableEntityIds !== undefined)
    {
      availableEntityIds.push(0);
    }
    else
    {
      availableEntityIds = [0];
    }

    for(var newIdIterator in availableEntityIds)
    {
      VeinEntity.entitySubscribeById(availableEntityIds[newIdIterator]);
    }
  }

  FontLoader {
    //init fontawesome
    source: "qrc:/data/3rdparty/font-awesome-4.6.1/fonts/fontawesome-webfont.ttf"
  }

  CCMP.DebugRectangle {
    //show the current window size
    visible: debugBypass === true;
    Label {
      text: String("Window size: %1x%2").arg(displayWindow.width).arg(displayWindow.height)
      anchors.centerIn: parent
      Component.onCompleted: {
        parent.width=width + 8;
        parent.height=height + 2;
      }
    }
  }

  Connections {
    target: VeinEntity
    onStateChanged: {
      if(t_state === VeinEntity.VQ_LOADED)
      {
        dynamicPageModel.initModel();
        pageView.model = dynamicPageModel;
        //initialize the currentViewName to avoid "undefined" in the logger record name
        GC.currentViewName = dynamicPageModel.get(0).name

        console.log("Loaded session: ", currentSession);
        ModuleIntrospection.reloadIntrospection();
        pageLoader.active = true;
        controlsBar.rangeIndicatorDependenciesReady = true;
        pageView.pageLoaderSource = pageView.model.get(0).elementValue;
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

  CCMP.FpsItem {
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: 48
    height: 24
    width: 64
    z: Infinity
    visible: debugBypass === true
  }

  Shortcut {
    property bool smallResolution: false
    enabled: BUILD_TYPE === "debug"
    sequence: "F3"
    autoRepeat: false
    onActivated: {
      smallResolution = !smallResolution;
      if(smallResolution)
      {
        displayWindow.width=750;
        displayWindow.height=480;
      }
      else
      {
        displayWindow.width=1024;
        displayWindow.height=600;
      }
    }
  }

  Flickable {
    // main view displaying pages and other stuff - (flickable for virtual keyboard)
    id: flickable
    anchors.fill: parent
    enabled: displayWindow.entitiesInitialized === true
    contentWidth: parent.width;
    contentHeight: parent.height
    boundsBehavior: Flickable.StopAtBounds
    interactive: false
    NumberAnimation on contentY
    {
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
      currentIndex: displayWindow.entitiesInitialized ? GC.layoutStackEnum.layoutPageIndex : GC.layoutStackEnum.layoutStatusIndex

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
      }
      Loader {
        sourceComponent: loggerCmp
        active: layoutStack.currentIndex===GC.layoutStackEnum.layoutLoggerIndex
      }
      Loader {
        sourceComponent: settingsCmp
        active: layoutStack.currentIndex===GC.layoutStackEnum.layoutSettingsIndex
      }
      Loader {
        sourceComponent: statusCmp
        active: layoutStack.currentIndex===GC.layoutStackEnum.layoutStatusIndex
      }
      //Pages.RemoteSelection {...}
      // ]
      ///@note do not change the order of the Loaders unless you also change the layoutStackEnum index numbers
    }

    Component {
      id: rangePeak
      Item {
        RangeControls.RangeMenu {
          id: rangeMenu
          anchors.fill: parent
          anchors.leftMargin: 40
          anchors.topMargin: 20
          anchors.bottomMargin: 20
          anchors.rightMargin: parent.width/2
        }
        RangeControls.RangePeak {
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
      ///@todo remove the syslogModel and view in favor of a OS log viewer
      id: syslogModel

      onCountChanged:  {
        if(count>500) //prevent the log from getting too big
        {
          remove(0, count-500);
        }
      }

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
      AppInfoControls.StatusView { errorDataModel: syslogModel }
    }
    Component {
      id: loggerCmp
      LoggerControls.LoggerSettings {}
    }
    Component {
      id: settingsCmp
      SettingsControls.Settings {}
    }

    CCMP.MainToolBar {
      id: controlsBar
      height: parent.height/16
      anchors.bottom: parent.bottom
      width: displayWindow.width

      entityInitializationDone: displayWindow.entitiesInitialized;
      layoutStackObj: layoutStack
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
          append({name: "Harmonics & Curves", icon: "qrc:/data/staticdata/resources/harmonics.png", elementValue: "qrc:/qml/pages/FftModulePage.qml"});
        }
        if(ModuleIntrospection.hasDependentEntities(["Power3Module1"])) {
          append({name: "Harmonic power values", icon: "qrc:/data/staticdata/resources/hpower.png", elementValue: "qrc:/qml/pages/HarmonicPowerModulePage.qml"});
        }
        if(ModuleIntrospection.hasDependentEntities(["SEC1Module1"]) || ModuleIntrospection.hasDependentEntities(["SEM1Module1"]) || ModuleIntrospection.hasDependentEntities(["SPM1Module1"])) {
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

    CCMP.PageView {
      id: pageView
      anchors.fill: parent
      ///@note do not break binding by setting visible directly
      visible: controlsBar.pageViewVisible;
      onCloseView: controlsBar.pageViewVisible = false;
      onSessionChanged: {
        layoutStack.currentIndex=0;
        controlsBar.rangeIndicatorDependenciesReady = false;
        pageLoader.active = false;
        entitiesInitialized = false;
        loadingScreen.open();
      }
    }
  }
  InputPanel {
    id: inputPanel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    property bool textEntered: Qt.inputMethod.visible
    // Hmm - what is this magic factor?
    onHeightChanged: GC.vkeyboardHeight = height/1.17
    opacity: 0
    NumberAnimation on opacity {
      id: keyboardAnimation
      onStarted: {
      if(to === 1)
        inputPanel.visible = true
      }
      onFinished: {
        if(to === 0)
          inputPanel.visible = false
      }
    }
    onTextEnteredChanged: {
      var rectInput = Qt.inputMethod.anchorRectangle
      if (inputPanel.textEntered) {
        if(rectInput.bottom > inputPanel.y)
        {
          flickableAnimation.to = rectInput.bottom - inputPanel.y + 10
          flickableAnimation.start()
        }
        keyboardAnimation.to = 1
        keyboardAnimation.duration = 500
        keyboardAnimation.start()
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
