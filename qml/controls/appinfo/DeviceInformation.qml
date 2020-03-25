import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraTranslation  1.0
import "qrc:/qml/vf-controls" as VFControls

Item {
  id: root

  readonly property QtObject systemEnt: VeinEntity.getEntity("_System");
  readonly property QtObject statusEnt: VeinEntity.getEntity("StatusModule1");
  readonly property int rowHeight: Math.floor(height/20)

  VisualItemModel {
    id: statusModel

    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["Serial number:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_SerialNr
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["Operating system version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_ReleaseNr
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["PCB server version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_PCBServerVersion
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["DSP server version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_DSPServerVersion
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["DSP firmware version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_DSPVersion
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["FPGA firmware version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_FPGAVersion
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["Microcontroller firmware version:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_CTRLVersion
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Material.foreground: GC.adjustmentStatusOk ? Material.White : Material.Red
      Label {
        font.pointSize: 14
        text: ZTR["Adjustment status:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: GC.adjustmentStatusDescription
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["Adjustment checksum:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: statusEnt.INF_AdjChksum
      }
    }
    RowLayout {
      width: parent.width
      height: root.rowHeight
      Label {
        font.pointSize: 14
        text: ZTR["IP addresses:"]
      }
      Item {
        Layout.fillWidth: true
      }
      Label {
        font.pointSize: 14
        text: "["+systemEnt.ServerAddressList.join(", ")+"]";
      }
    }
  }

  ListView {
    id: statusListView
    anchors.fill: parent
    anchors.leftMargin: 16
    anchors.rightMargin: 16
    spacing: rowHeight/4
    model: statusModel
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: rightScrollbar
  }
  ScrollBar {
    id: rightScrollbar
    anchors.left: statusListView.right
    anchors.top: statusListView.top
    anchors.bottom: statusListView.bottom
    visible: statusListView.contentHeight>statusListView.height
    Component.onCompleted: {
      if(QT_VERSION >= 0x050900) //policy was added after 5.7
      {
        policy = ScrollBar.AlwaysOn;
      }
    }
  }
}
