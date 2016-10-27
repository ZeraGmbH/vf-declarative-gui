import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "qrc:/ccmp/common" as CCMP
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import Com5003Translation  1.0

Item {
  id: root

  readonly property QtObject statusEnt: VeinEntity.getEntity("StatusModule1");

  Column {
    width: parent.width*0.8
    anchors.centerIn: parent
    spacing: 20

    Label {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: ZTR["Device info"]
      font.pixelSize: 24
    }

    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["Serial number:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_SerialNr
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["Operating system version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_ReleaseNr
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["PCB server version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_PCBServerVersion
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["DSP server version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_DSPServerVersion
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["DSP firmware version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_DSPVersion
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["FPGA firmware version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_FPGAVersion
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["Microcontroller firmware version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_CTRLVersion
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["Adjustment status:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_Adjusted
      }
    }
    RowLayout {
      width: parent.width
      Label {
        font.pixelSize: 20
        text: ZTR["Adjustment checksum:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pixelSize: 20
        text: statusEnt.INF_AdjChksum
      }
    }

  }
}
