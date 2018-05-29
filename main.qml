import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import FPSCounter 1.0
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
  property var errorMessages: [];
  property bool measuringPaused: false;

  onErrorMessagesChanged: {
    if(errorMessages && errorMessages.length > 0)
    {
      GC.tmpStatusNewErrors = true;
    }
  }
  visible: true
  width: 1024
  height: 600
  title: "COM5003"
  Material.theme: Material.Dark
  Material.accent: "#339966"


  onClosing: {
    settings.globalSettings.saveToFile(settings.globalSettings.getCurrentFilePath(), true);
  }

  Component.onCompleted: {
    currentSession = Qt.binding(function() {
      return VeinEntity.getEntity("_System").Session;
    })

    if(VeinEntity.hasEntity("_System"))
    {
      errorMessages = Qt.binding(function() {
        return JSON.parse(VeinEntity.getEntity("_System").Error_Messages);
      })
    }
  }

  onCurrentSessionChanged: {
    switch(currentSession)
    {
    case "com5003-meas-session.json":
    {
      displayWindow.title = "COM5003"
      requiredIds = [0, 2, 1020, 1030, 1040, 1050, 1060, 1070, 1071, 1072, 1100, 1110, 1120, 1130, 1140, 1150];
      break;
    }
    case "com5003-ref-session.json":
    {
      displayWindow.title = "COM5003"
      requiredIds = [0, 2, 1001, 1020, 1050, 1150];
      break;
    }
    case "com5003-ced-session.json":
    {
      displayWindow.title = "COM5003"
      requiredIds = [0, 2, 1020, 1030, 1040, 1050, 1060, 1070, 1071, 1072, 1090, 1110, 1120, 1130, 1140, 1150];
      break;
    }
    case "mt310s2-meas-session.json":
    {
      displayWindow.title = "MT310S2"
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

  Timer {
    id: entityTimeout
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
        if(currentSession === "com5003-meas-session.json")
        {
          pageView.model = com5003MeasModel
        }
        else if(currentSession === "com5003-ref-session.json")
        {
          pageView.model = com5003RefModel
        }
        else if(currentSession === "com5003-ced-session.json")
        {
          pageView.model = com5003CedModel
        }
        else if(currentSession === "mt310s2-meas-session.json")
        {
          pageView.model = mt310s2MeasModel
        }

        console.log("Loaded session: ", currentSession);
        ModuleIntrospection.reloadIntrospection();
        pageLoader.active = true;
        rangeIndicator.active = true;
        pageView.currentValue = pageView.model.firstElement;
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
        errorMessages = Qt.binding(function() {
          return JSON.parse(VeinEntity.getEntity("_System").Error_Messages);
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

  /// @todo remove debugging code
  Shortcut {
    property bool cLang: false
    enabled: BUILD_TYPE === "debug"
    sequence: "F2"
    autoRepeat: false
    onActivated: {
      cLang = !cLang;
      if(cLang)
      {
        ZTR.changeLanguage("C");
      }
      else
      {
        ZTR.changeLanguage("de");
      }
    }
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

  FPSCounter {
    property bool originalState: false
    //needs to stay in the foreground
    z: 100
    anchors.right: parent.right
    //the calculated width*height must be >0 to trigger the paint() function call in c++
    width: 100
    height: 40


    Component.onCompleted: {
      originalState = fpsEnabled===1 ///integer evaluation
      if(fpsEnabled !==1) //enable debugging control if disabled
      {
        fpsEnabled = Qt.binding(function(){
          return (debugBypass ? 1 : 0 )
        })
      }
    }

    CCMP.DebugRectangle {
      anchors.fill: parent
      visible: debugBypass && parent.originalState==false
    }

    Label {
      property real fps: parent.currentFPS.toFixed(2)
      visible: parent.fpsEnabled
      anchors.right: parent.right
      anchors.rightMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text:  fps + " FPS";
      color: fps > 29 ? ( fps > 49 ? "lawngreen" : "yellow" ) : "red";
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
      currentIndex: (displayWindow.entitiesInitialized || displayWindow.errorMessages.length === 0) ? layoutStackEnum.layoutPageIndex : layoutStackEnum.layoutStatusIndex

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
    Component {
      id: statusCmp
      CCMP.StatusView { errorDataModel: displayWindow.errorMessages }
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
          font.pointSize: 14
          text: FA.icon(FA.fa_columns) + ZTR["Pages"]
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

        Item { Layout.fillWidth: true }
        ToolButton {
          implicitHeight: parent.height
          font.family: "FontAwesome"
          font.pointSize: 14
          text: displayWindow.measuringPaused ? FA.fa_play : FA.fa_pause
          enabled: displayWindow.entitiesInitialized === true
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
          highlighted: layoutStack.currentIndex===layoutStackEnum.layoutLoggerIndex;
          enabled: displayWindow.entitiesInitialized === true
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


    StaticData.MeasurementPageModel {
      id: com5003MeasModel
    }
    StaticData.ReferencePageModel {
      id: com5003RefModel
    }
    StaticData.CEDPageModel {
      id: com5003CedModel
    }
    StaticData.MT310S2MeasurementPageModel {
      id: mt310s2MeasModel
    }



    CCMP.PagePathView {
      id: pageView

      property string currentValue;

      visible: false
      onModelChanged: {
        if(model)
        {
          currentValue = model.firstElement;
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
