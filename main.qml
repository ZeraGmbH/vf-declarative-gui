import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import FPSCounter 1.0
import VeinEntity 1.0
import Com5003Translation  1.0

import "qrc:/pages" as Pages
import "qrc:/ccmp/common" as CCMP
import "qrc:/data/staticdata" as StaticData
import "qrc:/data/staticdata/FontAwesome.js" as FA
import JsonSettings 1.0

ApplicationWindow {
  id: displayWindow
  visible: true
  width: 1024
  height: 600

  title: "COM5003"

  Material.theme: Material.Dark
  Material.accent: "#339966"

  property bool debugBypass: false

  property string currentSession
  property var requiredIds
  property var resolvedIds: new Array()
  property var errorMessages: [];
  onErrorMessagesChanged: {
    messageNotificationIndicator.newErrors = true;
  }

  onClosing: {
    settings.globalSettings.saveToFile(settings.globalSettings.getCurrentFilePath(), true);
  }

  Component.onCompleted: {
    currentSession = Qt.binding(function() {
      return VeinEntity.getEntity("_System").Session;
    })

    if(VeinEntity.getEntity("_System"))
    {
      errorMessages = Qt.binding(function(){
        return JSON.parse(VeinEntity.getEntity("_System").Error_Messages);
      })
    }
  }

  Connections {
    target: VeinEntity
    onSigEntityAvailable: {
      var checkRequired = false;
      var entId = VeinEntity.getEntity(t_entityName).entityId()
      if(entId === 0)
      {
        currentSession = Qt.binding(function() {
          return VeinEntity.getEntity("_System").Session;
        });
        errorMessages = Qt.binding(function(){
          return JSON.parse(VeinEntity.getEntity("_System").Error_Messages);
        })
        pageView.sessionComponent = Qt.binding(function() {
          return currentSession
        });
      }

      if(requiredIds.indexOf(entId) > -1)
      {
        if(resolvedIds.indexOf(entId) < 0)
        {
          resolvedIds.push(entId);
          checkRequired = true;
        }
      }


      if(checkRequired) //in case of other entities being added when the session is already loaded
      {
        resolvedIds.sort(); //requiredIds is sorted once in onCurrentSessionChanged()
        if(JSON.stringify(requiredIds) == JSON.stringify(resolvedIds))
        {
          if(currentSession === "0_default-session.json")
          {
            console.log("loading default session")
            pageView.model = measModel
          }
          else if(currentSession === "1_ref-session.json")
          {
            console.log("loading ref session")
            pageView.model = refModel
          }
          else if(currentSession === "2_ced-session.json")
          {
            console.log("loading ref session")
            pageView.model = cedModel
          }
          ModuleIntrospection.reloadIntrospection();
          pageLoader.active = true;
          rangeIndicator.active = true;
          pageView.currentValue = pageView.model.firstElement;
          loadingScreen.close();
        }
      }
    }
  }

  onCurrentSessionChanged: {
    if(currentSession === "0_default-session.json")
    {
      requiredIds = [0, 50, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015];
    }
    else if(currentSession === "1_ref-session.json")
    {
      //no GlueLogic (50) required here
      requiredIds = [0, 2000, 2001, 2002, 2003, 2004, 2005];
    }
    else if(currentSession === "2_ced-session.json")
    {
      requiredIds = [0, 50, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014];
    }
    resolvedIds = [];

    requiredIds.sort();
    VeinEntity.setRequiredIds(requiredIds);
  }

  JsonGlobalSettings {
    id: settings
    Component.onCompleted: {
      if(globalSettings.loadFromStandardLocation("settings.json") === false)
      {
        console.log("Loading settings file: qrc://data/staticdata/settings.json");
        globalSettings.loadFromFile("://data/staticdata/settings.json");
      }
    }
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
    sequence: "F2"
    autoRepeat: false
    property bool cLang: false
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

  FPSCounter {
    //needs to stay in the foreground
    z: 100
    anchors.right: parent.right
    //the calculated width*height must be >0 to trigger the paint() function call in c++
    width: 100
    height: 40

    property bool originalState: false

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
      visible: parent.fpsEnabled
      anchors.right: parent.right
      anchors.rightMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      property real fps: parent.currentFPS.toFixed(2)
      text:  fps + " FPS";
      color: fps > 29 ? ( fps > 49 ? "lawngreen" : "yellow" ) : "red";
    }
  }

  CCMP.SwipeArea {
    anchors.fill: parent
    drag.axis: Drag.XAxis
    focus: true
    enabled: displayWindow.currentSession !== ""

    onHorizontalSwipe: {
      if(pageView.visible !== true)
      {
        layoutStack.currentIndex=0;
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
      currentIndex: displayWindow.currentSession !== "" ? 0 : 3

      Loader {
        id: pageLoader
        source: pageView.currentValue
      }
      Loader {
        sourceComponent: rangePeak
        active: layoutStack.currentIndex===1
      }
      Loader {
        sourceComponent: settingsCmp
        active: layoutStack.currentIndex===2
      }
      Loader {
        sourceComponent: notificationsCmp
        active: layoutStack.currentIndex===3
      }
      Loader {
        sourceComponent: statusCmp
        active: layoutStack.currentIndex===4
      }

      //Pages.RemoteSelection {}
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
      id: settingsCmp
      CCMP.Settings {}
    }
    Component {
      id: notificationsCmp
      CCMP.Notifications { errorDataModel: displayWindow.errorMessages }
    }
    Component {
      id: statusCmp
      CCMP.StatusView {}
    }



    ToolBar {
      id: controlsBar
      height: parent.height/16
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      background: Rectangle { color: "#206040" } /// @todo: replace with some color name??

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        ToolButton {
          implicitHeight: parent.height
          font.family: "FontAwesome"
          font.pixelSize: 18
          text: FA.icon(FA.fa_columns) + ZTR["Pages"]
          highlighted: layoutStack.currentIndex===0
          enabled: displayWindow.currentSession !== ""
          onClicked: {
            if(layoutStack.currentIndex===0)
            {
              pageView.visible=true;
            }
            else
            {
              layoutStack.currentIndex=0;
            }
          }
        }
        ToolButton {
          implicitHeight: parent.height
          font.family: "FontAwesome"
          font.pixelSize: 18
          text: FA.icon(FA.fa_align_justify) + ZTR["Range"]
          highlighted: layoutStack.currentIndex===1
          enabled: displayWindow.currentSession !== ""
          onClicked: {
            layoutStack.currentIndex=1;
          }
        }
        ToolButton {
          implicitHeight: parent.height
          width: controlsBar.width/3
          CCMP.RangeIndicator {
            width: controlsBar.width/3
            height: controlsBar.height
            id: rangeIndicator
            active: false
          }
        }

        Item { Layout.fillWidth: true }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: 64
          height: parent.height
          highlighted: layoutStack.currentIndex===3
          enabled: displayWindow.errorMessages !== undefined && displayWindow.errorMessages.length > 0

          onClicked: {
            layoutStack.currentIndex=3;
            messageNotificationIndicator.newErrors = false
          }

          Label {
            id: messageNotificationIndicator

            property bool newErrors: false

            text: FA.fa_exclamation_triangle
            font.family: "FontAwesome"
            font.pixelSize: 18
            anchors.left: parent.left
            anchors.leftMargin: parent.width/10
            anchors.verticalCenter: parent.verticalCenter
            color: newErrors ? Material.color(Material.Yellow) : Material.primaryTextColor
          }
          Label {
            text: displayWindow.errorMessages.length > 0 ? String("(%1)").arg(displayWindow.errorMessages.length) : ""
            font.family: "FontAwesome"
            font.pixelSize: 18
            anchors.right: parent.right
            anchors.rightMargin: parent.width/10
            anchors.verticalCenter: parent.verticalCenter
          }
        }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: 64
          font.family: "FontAwesome"
          font.pixelSize: 24
          text: FA.fa_cogs
          highlighted: layoutStack.currentIndex===2
          enabled: displayWindow.currentSession !== ""
          onClicked: {
            layoutStack.currentIndex=2;
          }
        }
        ToolButton {
          implicitHeight: parent.height
          implicitWidth: 64
          font.family: "FontAwesome"
          font.pixelSize: 24
          text: FA.fa_info_circle
          highlighted: layoutStack.currentIndex===4
          enabled: displayWindow.currentSession !== ""
          onClicked: {
            layoutStack.currentIndex=4;
          }
        }
        //        ToolButton {
        //          implicitHeight: parent.height
        //          font.family: "FontAwesome"
        //          font.pixelSize: 18
        //          text: FA.icon(FA.fa_server) + ZTR["Remotes"]
        //          highlighted: layoutStack.currentIndex===5
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
      id: measModel
    }
    StaticData.ReferencePageModel {
      id: refModel
    }
    StaticData.CEDPageModel {
      id: cedModel
    }



    CCMP.PagePathView {
      id: pageView
      visible: false
      onModelChanged: {
        if(model)
        {
          console.log("MODEL CHANGED", model.firstElement);
          currentValue = model.firstElement;
          pageLoader.source = currentValue
        }
      }

      property string currentValue;

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
