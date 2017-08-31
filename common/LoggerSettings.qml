import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import Com5003Translation  1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA


CCMP.SettingsView {
  id: root
  viewAnchors.bottomMargin: buttonContainer.height
  readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")

  LoggerDatasetSelector {
    id: loggerDataSelection
    width: root.width
    height: root.height
    closePolicy: Popup.NoAutoClose
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
          visible: loggerEntity.DatabaseReady === false
          font.family: "FontAwesome"
          font.pixelSize: 20
          text: FA.fa_exclamation_triangle
          color: Material.color(Material.Yellow)
        }
        VF.VFTextInput {
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
          text: ZTR["Database file info:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        Label {
          text: ZTR["Database size: <b>%1MB</b>"].arg((loggerEntity.DatabaseFileSize/1.0e6).toFixed(2));
        }
        Item {
          //spacer
          width: 8
        }
        Label {
          text: ZTR["Database mimetype: <b>%1</b>"].arg(loggerEntity.DatabaseFileMimeType);
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
        enabled: loggerEntity.LoggingEnabled === false
        onClicked: loggerDataSelection.visible=1;
      }
    }
    Item {
      height: loggerEntity.ScheduledLoggingEnabled === true ? root.rowHeight*2 : root.rowHeight;
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
        visible: loggerEntity.ScheduledLoggingEnabled === true
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Label {
          textFormat: Text.PlainText
          text: ZTR["Logging Duration:"]
          font.pixelSize: 20

          Layout.fillWidth: true
        }
        VF.VFTextInput {
          entity: root.loggerEntity
          controlPropertyName: "ScheduledLoggingDuration"
          placeholderText: "00:00:00"
          validator: RegExpValidator { regExp: /(?!^00:00:00$)(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]/ }
          height: root.rowHeight
          width: root.width/2.9
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
      enabled: loggerEntity.LoggingEnabled === false && loggerEntity.DatabaseReady === true && !(loggerEntity.ScheduledLoggingEnabled && loggerEntity.ScheduledLoggingDuration.length === 0 )
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
