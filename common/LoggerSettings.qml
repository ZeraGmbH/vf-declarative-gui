import QtQuick 2.5
import QtQuick.Controls 2.0
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
  rowHeight: height/12

  function msToTime(s) {
    var ms = s % 1000;
    s = (s - ms) / 1000;
    var secs = s % 60;
    s = (s - secs) / 60;
    var mins = s % 60;
    var hrs = (s - mins) / 60;

    return ("0"+hrs).slice(-2) + ':' + ("0"+mins).slice(-2) + ':' + ("0"+secs).slice(-2);// + '.' + ("00"+ms).slice(-3);
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
          text: ZTR["Database file:"]
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
        }
        VF.VFTextInput {
          id: dbPathInput
          entity: root.loggerEntity
          controlPropertyName: "DatabaseFile"

          Layout.fillWidth: true
          height: root.rowHeight
          validator: RegExpValidator {
            //disallow \ space : ? * " < > | /.. \0 //
            regExp: /(?!.*(\\|\s|:|\?|\*|"|<|>|\||\/\.\.|\0|\/\/))^(\/)([^/\0]+(\/)?)+/
          }
          fontSize: 18
        }
        Button {
          text: FA.fa_eject
          font.family: "FontAwesome"
          font.pixelSize: 20
          implicitHeight: root.rowHeight
          enabled: root.loggerEntity.DatabaseFile.length > 0 && dbPathInput.m_alteredValue === false
          onClicked: root.loggerEntity.DatabaseFile = "";
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
      visible: loggerEntity.DatabaseFile.length > 0
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
          entity: root.loggerEntity
          controlPropertyName: "ScheduledLoggingDuration"
          placeholderText: "00:00:00"
          validator: RegExpValidator { regExp: /(?!^00:00:00$)[0-9][0-9]:[0-5][0-9]:[0-5][0-9]/ }
          height: root.rowHeight
          width: root.width/2.9
          visible: loggerEntity.LoggingEnabled === false

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
    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      visible: false; //VeinEntity.hasEntity("CustomerData")
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
