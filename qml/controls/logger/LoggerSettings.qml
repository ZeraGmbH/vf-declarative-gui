import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/customerdata" as CDataControls
import "qrc:/qml/controls/settings" as SettingsControls
import "qrc:/qml/vf-controls" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA


SettingsControls.SettingsView {
  id: root
  viewAnchors.bottomMargin: buttonContainer.height
  readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
  property bool snapshotTrigger: false;
  readonly property bool logEnabled: loggerEntity.LoggingEnabled

  property string completeDBPath: (dbLocationSelector.storageList.length > 0 && fileNameField.acceptableInput) ? dbLocationSelector.storageList[dbLocationSelector.currentIndex]+"/"+fileNameField.text+".db" : "";

  horizMargin: GC.standardTextHorizMargin
  rowHeight: (height-footerHeight)/8

  readonly property double footerHeight: height/10
  readonly property double fontScale: 0.3

  onLogEnabledChanged: {
    if(snapshotTrigger === true && logEnabled === true)
    {
      snapshotTrigger = false;
      //causes wrong warning about property loop so use the timer as workaround
      //loggerEntity.LoggingEnabled = false;
      propertyLoopAvoidingLoggingEnabledTimer.start();
    }
  }

  Timer {
    id: propertyLoopAvoidingLoggingEnabledTimer
    interval: 0
    repeat: false
    onTriggered: {
      loggerEntity.LoggingEnabled = false;
    }
  }

  function msToTime(t_mSeconds) {
    if(t_mSeconds === undefined) {
      t_mSeconds = 0
    }
    var ms = t_mSeconds % 1000
    t_mSeconds = (t_mSeconds - ms) / 1000
    var secs = t_mSeconds % 60;
    t_mSeconds = (t_mSeconds - secs) / 60
    var mins = t_mSeconds % 60;
    var hours = (t_mSeconds - mins) / 60;

    return ("0"+hours).slice(-2) + ':' + ("0"+mins).slice(-2) + ':' + ("0"+secs).slice(-2);// + '.' + ("00"+ms).slice(-3);
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

  Loader {
    id: loggerSearchPopup
    active: false
    sourceComponent: LoggerDbSearchDialog {
      width: root.width
      height: Qt.inputMethod.visible ? root.height/2 : root.height
      visible: true
      onClosed: loggerSearchPopup.active = false;
      onFileSelected: {
        root.loggerEntity.DatabaseFile = t_file;
      }
    }
  }

  Loader {
    id: loggerDataSelection
    active: false
    sourceComponent: LoggerDatasetSelector {
      width: root.width
      height: root.height-GC.vkeyboardHeight
      closePolicy: Popup.NoAutoClose
      visible: true
      onClosed: loggerDataSelection.active = false;
    }
  }

  Connections {
    target: customerDataEntry.item
    onOk: {
        // TODO: extra activity?
        customerDataEntry.active=false;
    }
    onCancel: {
        customerDataEntry.active=false;
    }
  }

  Loader {
    id: customerDataEntry
    active: false
    sourceComponent: CDataControls.CustomerDataEntry {
      width: root.width
      height: root.height
      visible: true
    }
  }

  LoggerRecordNamePopup {
    id: recordNamePopup
    onSigAccepted: {
      if(loggerEntity.LoggingEnabled !== true)
      {
        loggerEntity.recordName = t_resultText;
        loggerEntity.LoggingEnabled=true;
      }
    }
    onSigCanceled: {
      if(loggerEntity.LoggingEnabled !== true)
      {
        snapshotTrigger = false;
      }
    }
  }

  model: VisualItemModel {
    Label {
      text: ZTR["Database Logging"]
      width: root.rowWidth;
      horizontalAlignment: Text.AlignHCenter
      font.pointSize: root.rowHeight*fontScale
    }

    Item {
      height: root.rowHeight;
      width: root.rowWidth;

      RowLayout {
        anchors.fill: parent
        Label {
          textFormat: Text.PlainText
          text: ZTR["Logger status:"]
          font.pointSize: root.rowHeight*fontScale
          Layout.fillWidth: true
        }
        Label { // exclamation mark if no database selected
          font.family: "FontAwesome"
          font.pointSize: root.rowHeight*fontScale
          text: FA.fa_exclamation_triangle
          color: Material.color(Material.Yellow)
          visible: loggerEntity.DatabaseReady === false
        }
        Label {
          text: ZTR[loggerEntity.LoggingStatus]
          font.pointSize: root.rowHeight*fontScale
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
      enabled: dbLocationSelector.storageList.length > 0
      height: root.rowHeight;
      width: root.rowWidth;

      RowLayout {
        anchors.fill: parent

        Label {
          textFormat: Text.PlainText
          text: ZTR["Database filename:"]
          font.pointSize: root.rowHeight*fontScale
        }
        Item {
          //spacer
          width: 24
        }
        CCMP.ZLineEdit {
          id: fileNameField
          Layout.fillWidth: true
          Layout.fillHeight: true
          textField.font.pointSize: root.rowHeight*fontScale
          placeholderText: ZTR["<directory name>/<filename>"]
          text: String(root.loggerEntity.DatabaseFile).replace(dbLocationSelector.storageList[dbLocationSelector.currentIndex]+"/", "").replace(".db", "");
          validator: RegExpValidator {
            regExp: /[-_a-zA-Z0-9]+(\/[-_a-zA-Z0-9]+)*/
          }
        }
        Label {
          textFormat: Text.PlainText
          text: ".db"
          font.pointSize: root.rowHeight*fontScale
          horizontalAlignment: Text.AlignLeft
        }
        Item {
          //spacer
          width: GC.standardMarginWithMin
        }
        Button {
          font.family: "FontAwesome"
          implicitHeight: root.rowHeight
          font.pointSize: root.rowHeight*fontScale
          text: FA.fa_search
          enabled: dbLocationSelector.storageList.length > 0
          onClicked: {
            loggerSearchPopup.active = true;
          }
        }
        Button {
          text: (enabled ? "<font color=\"lawngreen\">" : "<font color=\"grey\">") + FA.fa_check
          font.family: "FontAwesome"
          font.pointSize: root.rowHeight*fontScale
          implicitHeight: root.rowHeight
          enabled: fileNameField.acceptableInput && loggerEntity.DatabaseFile !== root.completeDBPath
          onClicked: {
            root.loggerEntity.DatabaseFile = root.completeDBPath
          }
        }
        Button {
          text: (enabled ? "<font color=\"#EEff0000\">" : "<font color=\"grey\">") + FA.fa_eject  // darker red
          font.family: "FontAwesome"
          font.pointSize: root.rowHeight*fontScale
          implicitHeight: root.rowHeight
          enabled: root.loggerEntity.DatabaseFile.length > 0
          onClicked: {
            root.loggerEntity.DatabaseFile = "";
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
        Label {
          textFormat: Text.PlainText
          text: ZTR["DB size:"]
          font.pointSize: root.rowHeight*fontScale
          Layout.fillWidth: true
        }
        Label {
          readonly property string mountPoint: GC.currentSelectedStoragePath === "/home/operator/logger" ? "/" : GC.currentSelectedStoragePath;
          readonly property double available: loggerEntity.FilesystemInfo[mountPoint] ? loggerEntity.FilesystemInfo[mountPoint].FilesystemFree : NaN
          readonly property double total: loggerEntity.FilesystemInfo[mountPoint] ? loggerEntity.FilesystemInfo[mountPoint].FilesystemTotal : NaN
          readonly property double percentAvail: total > 0 ? (available/total * 100).toFixed(2) : 0.0;
          text:  ZTR["<b>%1MB</b> (available <b>%2GB</b> of <b>%3GB</b> / %4%)"].arg((loggerEntity.DatabaseFileSize/Math.pow(1024, 2)).toFixed(2)).arg(available.toFixed(2)).arg(total.toFixed(2)).arg(percentAvail);
          font.pointSize: root.rowHeight*fontScale
        }
      }
    }
    Item {
      height: root.rowHeight;
      width: root.rowWidth;

      LoggerDbLocationSelector {
        id: dbLocationSelector
        anchors.fill: parent
        rowHeight: root.rowHeight
        pointSize: root.rowHeight*fontScale
        onNewIndexSelected: {
          if(byUser) {
            //the user switched the db storage location manually so unload the database
            root.loggerEntity.DatabaseFile = "";
          }
        }
      }
    }
    RowLayout {
      height: root.rowHeight;
      width: root.rowWidth;
      Label {
        textFormat: Text.PlainText
        text: ZTR["Select recorded values:"]
        font.pointSize: root.rowHeight*fontScale
        Layout.fillWidth: true
      }
      Button {
        text: FA.fa_cogs
        font.family: "FontAwesome"
        font.pointSize: root.rowHeight*fontScale
        implicitHeight: root.rowHeight
        enabled: loggerEntity.LoggingEnabled === false
        onClicked: loggerDataSelection.active=true;
      }
    }
    RowLayout {
      opacity: enabled ? 1.0 : 0.7
      height: root.rowHeight;
      width: root.rowWidth;
      Label {
        textFormat: Text.PlainText
        text: ZTR["Logging Duration [hh:mm:ss]:"]
        font.pointSize: root.rowHeight*fontScale
        Layout.fillWidth: true
        enabled: loggerEntity.ScheduledLoggingEnabled === true
      }
      VFControls.VFLineEdit {
        id: durationField

        // overrides
        function doApplyInput(newText) {
          entity[controlPropertyName] = timeToMs(newText)
          // wait to be applied
          return false
        }
        function transformIncoming(t_incoming) {
          return msToTime(t_incoming);
        }
        function hasValidInput() {
          var regex = /(?!^00:00:00$)[0-9][0-9]:[0-5][0-9]:[0-5][0-9]/
          return regex.test(textField.text)
        }

        entity: root.loggerEntity
        controlPropertyName: "ScheduledLoggingDuration"
        inputMethodHints: Qt.ImhPreferNumbers
        height: root.rowHeight
        pointSize: root.rowHeight*fontScale
        width: 280
        enabled: loggerEntity.ScheduledLoggingEnabled === true
      }
      VFControls.VFSwitch {
        id: scheduledLogging
        height: parent.height
        entity: root.loggerEntity
        controlPropertyName: "ScheduledLoggingEnabled"
      }
      Label {
        visible: loggerEntity.LoggingEnabled === true
        font.pointSize: root.rowHeight*fontScale
        property string countDown: msToTime(loggerEntity.ScheduledLoggingCountdown);
        height: root.rowHeight

        text: countDown;
      }
    }
    Item {
      height: root.rowHeight
      width: root.rowWidth;
      RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        visible: VeinEntity.hasEntity("CustomerData")
        Label {
          textFormat: Text.PlainText
          text: ZTR["Manage customer data:"]
          font.pointSize: root.rowHeight*fontScale

          Layout.fillWidth: true
          Label {
            readonly property string customerId: (VeinEntity.hasEntity("CustomerData") ? VeinEntity.getEntity("CustomerData").PAR_DatasetIdentifier : "");
            visible: customerId.length>0
            text: FA.icon(FA.fa_file_text)+customerId
            font.family: "FontAwesome"
            anchors.right: parent.right
            anchors.rightMargin: 10
            Rectangle {
              color: Material.dropShadowColor
              radius: 3
              anchors.fill: parent
              anchors.margins: -8
            }
          }
        }
        Button {
          text: FA.fa_cogs
          font.family: "FontAwesome"
          font.pointSize: root.rowHeight*fontScale
          implicitHeight: root.rowHeight
          enabled: loggerEntity.LoggingEnabled === false
          onClicked: customerDataEntry.active=true;
        }
      }
    }
  }
  Item {
    id: buttonContainer
    height: root.footerHeight
    width: root.width;
    anchors.bottom: parent.bottom
    visible: !customerDataEntry.active

    Button {
      id: startButton
      text: ZTR["Start"]
      font.pointSize: root.rowHeight*fontScale
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      anchors.leftMargin: GC.standardTextHorizMargin
      width: root.rowWidth/4
      enabled: loggerEntity.LoggingEnabled === false && loggerEntity.DatabaseReady === true && !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )
      highlighted: true
      onClicked: {
        recordNamePopup.visible = true;
      }
    }

    Button {
      id: snapshotButton
      text: ZTR["Snapshot"]
      font.pointSize: root.rowHeight*fontScale
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      width: root.rowWidth/4
      enabled: loggerEntity.LoggingEnabled === false && loggerEntity.DatabaseReady === true && !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration === undefined )

      onClicked: {
        snapshotTrigger=true;
        recordNamePopup.visible = true;
      }
    }

    Button {
      id: stopButton
      text: ZTR["Stop"]
      font.pointSize: root.rowHeight*fontScale
      anchors.top: buttonContainer.top
      anchors.bottom: buttonContainer.bottom
      anchors.right: parent.right
      anchors.rightMargin: GC.standardTextHorizMargin
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
