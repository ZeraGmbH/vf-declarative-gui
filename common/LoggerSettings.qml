import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA


CCMP.SettingsView {
  id: root
  viewAnchors.bottomMargin: buttonContainer.height
  readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
  property bool snapshotTrigger: false;
  readonly property bool logEnabled: loggerEntity.LoggingEnabled
  property var listStorageTracer;
  property var storageList: [];
  property string completeDBPath: (storageList.length > 0 && fileNameField.acceptableInput) ? storageList[dbLocationSelector.currentIndex]+"/"+fileNameField.text+".db" : "";

  Component.onCompleted: updateStorageList();

  onLogEnabledChanged: {
    if(snapshotTrigger === true && logEnabled === true)
    {
      snapshotTrigger = false;
      loggerEntity.LoggingEnabled  = false;
    }
  }

  rowHeight: 48 //height/12

  function msToTime(t_mSeconds) {
    var retVal = "";
    if(t_mSeconds !== undefined)
    {
      var ms = t_mSeconds % 1000;
      t_mSeconds = (t_mSeconds - ms) / 1000;
      var secs = t_mSeconds % 60;
      t_mSeconds = (t_mSeconds - secs) / 60;
      var mins = t_mSeconds % 60;
      var hours = (t_mSeconds - mins) / 60;

      retVal = ("0"+hours).slice(-2) + ':' + ("0"+mins).slice(-2) + ':' + ("0"+secs).slice(-2);// + '.' + ("00"+ms).slice(-3);
    }
    return retVal;
  }
  function timeToMs(t_time) {
    var mSeconds = 0;
    var timeData = [];

    if((String(t_time).match(/:/g) || []).length === 2)
    {
      timeData = t_time.split(':');
      var hours = Number(timeData[0]);
      mSeconds += hours * 3600000;
      var minutes = Number(timeData[1]);
      mSeconds += minutes * 60000;
      var seconds = Number(timeData[2]);
      mSeconds += seconds * 1000;
    }

    return Number(mSeconds);
  }

  function updateStorageList() {
    if(!listStorageTracer)
    {
      console.log("Updating storage");
      listStorageTracer = loggerEntity.invokeRPC("listStorages()", ({}))
    }
    else
    {
      console.warn("Storage list update already in progress");
    }
  }

  Connections {
    target: loggerEntity
    onSigRPCFinished: {
      if(t_resultData["RemoteProcedureData::resultCode"] !== 0)
      {
        console.warn("RPC error:", t_resultData["RemoteProcedureData::errorMessage"]);
      }

      if(t_identifier === listStorageTracer)
      {
        storageList = t_resultData["ZeraDBLogger::storageList"];
        listStorageTracer = undefined;
        if(storageList.length>0)
        {
          var fileName = loggerEntity.DatabaseFile;
          for(var storageIdx in storageList)
          {
            if(fileName.indexOf(storageList[storageIdx]) === 0)
            {
              var fileNameNoExtension = fileName.replace(".db", "");
              dbLocationSelector.currentIndex = storageIdx;
              fileNameField.text = fileNameNoExtension.replace(storageList[storageIdx]+"/", "");
            }
          }
        }
      }
    }
  }

  Loader {
    id: loggerDataSelection
    active: false
    sourceComponent: LoggerDatasetSelector {
      width: root.width
      height: root.height
      closePolicy: Popup.NoAutoClose
      visible: true
      onClosed: loggerDataSelection.active = false
    }
  }

  Loader {
    id: cDataPopup
    active: false
    sourceComponent: CustomerDataEntry {
      width: root.width
      height: root.height
      closePolicy: Popup.NoAutoClose
      visible: true
      onClosed: cDataPopup.active = false
    }
  }



  model: VisualItemModel {
    Item {
      height: root.rowHeight;
      width: root.rowWidth;
      Label {
        text: ZTR["Database Logging"]
        font.pixelSize: 24
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.rowHeight
      }
    }
    Item {
      height: root.rowHeight;
      width: root.rowWidth;

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Logger status:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        Label {
          text: ZTR[loggerEntity.LoggingStatus]
          font.pixelSize: 16
        }
        BusyIndicator {
          id: busyIndicator

          implicitHeight: root.rowHeight
          implicitWidth: height
          visible: loggerEntity.LoggingEnabled
        }
      }
    }
    Item {
      height: root.rowHeight;
      width: root.rowWidth;

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Database location:"]
          font.pixelSize: 20
        }
        Item {
          //spacer
          width: 8
        }

        Item {
          height: root.rowHeight
          width: storageListIndicator.width
          visible: root.storageList.length === 0 && storageListIndicator.opacity === 0;
          Label {
            anchors.centerIn: parent
            id: storageListWarning
            font.family: "FontAwesome"
            font.pixelSize: 20
            text: FA.fa_exclamation_triangle
            color: Material.color(Material.Yellow)


            MouseArea {
              anchors.fill: parent
              anchors.margins: -8
              onClicked: console.log("tooltip")
            }
          }
        }
        BusyIndicator {
          id: storageListIndicator

          implicitHeight: root.rowHeight
          implicitWidth: height
          opacity: root.listStorageTracer !== undefined
          Behavior on opacity {
            NumberAnimation { from: 1; duration: 1000; }
          }
          visible: storageListWarning.visible === false
        }
        ComboBox {
          id: dbLocationSelector
          model: root.storageList;
          implicitWidth: root.width/2;
          height: root.rowHeight
          enabled: root.storageList.length > 0
          Layout.fillWidth: true
        }
        Button {
          font.family: "FontAwesome"
          font.pixelSize: 20
          text: FA.fa_refresh
          onClicked: {
            if(root.listStorageTracer === undefined)
            {
              root.updateStorageList();
            }
          }
        }
      }
    }
    Item {
      enabled: root.storageList.length > 0
      height: root.rowHeight;
      width: root.rowWidth;

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Database filename:"]
          font.pixelSize: 20
        }
        Item {
          //spacer
          width: 16
        }

        Label {
          font.family: "FontAwesome"
          font.pixelSize: 20
          text: FA.fa_exclamation_triangle
          color: Material.color(Material.Yellow)
          visible: loggerEntity.DatabaseReady === false

          MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            onClicked: console.log("tooltip")
          }
        }
        //        VF.VFTextInput {
        //          id: dbPathInput
        //          entity: root.loggerEntity
        //          controlPropertyName: "DatabaseFile"

        //          Layout.fillWidth: true
        //          height: root.rowHeight
        //          validator: RegExpValidator {
        //            //disallow \ space : ? * " < > | /.. \0 //
        //            regExp: /(?!.*(\\|\s|:|\?|\*|"|<|>|\||\/\.\.|\0|\/\/))^(\/)([^/\0]+(\/)?)+/
        //          }
        //          fontSize: 18
        //        }
        Item {
          //spacer
          width: 8
        }
        TextField {
          id: fileNameField
          height: root.rowHeight
          Layout.fillWidth: true
          placeholderText: "<directory name>/<filename>"
          validator: RegExpValidator {
            regExp: /[-_a-zA-Z0-9]+(\/[-_a-zA-Z0-9]+)*/
          }

          Rectangle {
            anchors.fill: parent
            visible: enabled && parent.acceptableInput === false && parent.text !== "";
            color: "#44FF0000";
          }
        }

        Label {
          textFormat: Text.PlainText
          text: ".db"
          font.pixelSize: 20
        }
        Button {
          text: FA.fa_check
          font.family: "FontAwesome"
          font.pixelSize: 20
          implicitHeight: root.rowHeight
          enabled: fileNameField.acceptableInput && loggerEntity.DatabaseFile !== root.completeDBPath
          onClicked: {
            console.log(completeDBPath);
            root.loggerEntity.DatabaseFile = root.completeDBPath
          }
        }
        Button {
          text: FA.fa_eject
          font.family: "FontAwesome"
          font.pixelSize: 20
          implicitHeight: root.rowHeight
          enabled: root.loggerEntity.DatabaseFile.length > 0
          onClicked: {
            root.loggerEntity.DatabaseFile = "";
            fileNameField.clear();
          }
        }
      }
    }
    Item {
      height: root.rowHeight;
      width: root.rowWidth;
      visible: loggerEntity.DatabaseReady === true
      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Database size:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        Label {
          text:  String("<b>%1MB</b>").arg((loggerEntity.DatabaseFileSize/Math.pow(1024, 2)).toFixed(2));
          font.pixelSize: 16
        }
      }
    }
    Item {
      height: root.rowHeight;
      width: root.rowWidth;
      visible: loggerEntity.DatabaseReady === true
      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Filesystem info:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        Label {
          readonly property double available: loggerEntity.FilesystemFree
          readonly property double total: loggerEntity.FilesystemTotal
          readonly property double percentAvail: total > 0 ? (available/total * 100).toFixed(2) : 0.0;
          text: ZTR["Space available: <b>%1GB</b> of <b>%2GB</b> (%3%)"].arg(available.toFixed(2)).arg(total.toFixed(2)).arg(percentAvail);
        }
        Item {
          //spacer
          width: 8
        }
        Label {
          text: ZTR["Filesystem type: <b>%1</b>"].arg(loggerEntity.FilesystemType);
        }
        Item {
          //spacer
          width: 8
        }
        Label {
          text: ZTR["Device name: <b>%1</b>"].arg(loggerEntity.FilesystemDevice);
        }
      }
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      Label {
        textFormat: Text.PlainText
        text: ZTR["Select recorded values:"]
        font.pixelSize: 20

        Layout.fillWidth: true
      }
      Button {
        text: FA.fa_cogs
        font.family: "FontAwesome"
        font.pixelSize: 20
        implicitHeight: root.rowHeight
        enabled: loggerEntity.LoggingEnabled === false
        onClicked: loggerDataSelection.active=true;
      }
    }
    Item {
      height: root.rowHeight*2
      width: root.rowWidth;

      RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Scheduled logging enabled:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        VF.VFSwitch {
          id: scheduledLogging
          height: parent.height
          entity: root.loggerEntity
          controlPropertyName: "ScheduledLoggingEnabled"
        }
      }
      RowLayout {
        enabled: loggerEntity.ScheduledLoggingEnabled === true
        opacity: enabled ? 1.0 : 0.5
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        height: root.rowHeight
        Label {
          textFormat: Text.PlainText
          text: ZTR["Logging Duration:"]
          font.pixelSize: 20
          height: root.rowHeight

          Layout.fillWidth: true
        }
        VF.VFTextInput {
          id: durationField

          function transformOutgoing (t_output) {
            return timeToMs(t_output);
          }
          function transformIncoming(t_incoming) {
            if(t_incoming !== undefined)
            {
              return msToTime(t_incoming);
            }
            else
            {
              return "";
            }
          }

          entity: root.loggerEntity
          controlPropertyName: "ScheduledLoggingDuration"
          placeholderText: "00:00:00"
          validator: RegExpValidator { regExp: /(?!^00:00:00$)[0-9][0-9]:[0-5][0-9]:[0-5][0-9]/ }
          height: root.rowHeight
          width: 280
          visible: loggerEntity.LoggingEnabled === false
        }
        Label {
          visible: loggerEntity.LoggingEnabled === true
          font.pixelSize: 20
          property var countDown: msToTime(loggerEntity.ScheduledLoggingCountdown);
          height: root.rowHeight

          text: countDown;
        }
      }
    }
    Item {
      height: root.rowHeight
      width: root.rowWidth;
      RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        visible: VeinEntity.hasEntity("CustomerData")
        Label {
          textFormat: Text.PlainText
          text: ZTR["Manage customer data:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        Button {
          text: FA.fa_cogs
          font.family: "FontAwesome"
          font.pixelSize: 20
          implicitHeight: root.rowHeight
          enabled: loggerEntity.LoggingEnabled === false
          onClicked: cDataPopup.active=true;
        }
      }
    }
  }
  Item {
    id: buttonContainer
    height: root.rowHeight*1.2;
    width: root.width;
    anchors.bottom: parent.bottom

    Button {
      id: startButton
      text: ZTR["Start"]
      font.pixelSize: 20
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      width: root.rowWidth/4
      enabled: loggerEntity.LoggingEnabled === false && loggerEntity.DatabaseReady === true && !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )
      highlighted: true

      onClicked: {
        if(loggerEntity.LoggingEnabled !== true)
        {
          loggerEntity.LoggingEnabled=true;
        }
      }
    }

    Button {
      id: snapshotButton
      text: ZTR["Snapshot"]
      font.pixelSize: 20
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      width: root.rowWidth/4
      enabled: loggerEntity.LoggingEnabled === false && loggerEntity.DatabaseReady === true && !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )

      onClicked: {
        if(loggerEntity.LoggingEnabled !== true)
        {
          snapshotTrigger = true;
          loggerEntity.LoggingEnabled=true;
        }
      }
    }

    Button {
      id: stopButton
      text: ZTR["Stop"]
      font.pixelSize: 20
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      anchors.right: parent.right
      width: root.rowWidth/4
      enabled: loggerEntity.LoggingEnabled === true

      onClicked: {
        if(loggerEntity.LoggingEnabled !== false)
        {
          loggerEntity.LoggingEnabled=false
        }
      }
    }
  }
}
