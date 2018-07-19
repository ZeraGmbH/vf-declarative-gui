import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0


Item {
  id: root

  property QtObject errorDataModel;

  Component.onCompleted: lvJournalView.positionViewAtEnd();

  ListView {
    id: lvJournalView
    anchors.fill: parent
    model: errorDataModel
    boundsBehavior: ListView.StopAtBounds
    clip: true
    delegate: Label {
      id: currentElement
      width: root.width
      textFormat: Label.RichText
      font.pointSize: 8
      font.family: "Monospace"
      //wrapMode: Label.WordWrap
      //text: String("<small>%1</small> <b>%2:</b> %3").arg(model.Time).arg(model.ModuleName).arg(ZTR[model.Error] !== undefined ? ZTR[model.Error] : model.Error);
      text: String("<small>%1/%2/%3 %4</small> %5 %6").arg(logDate.getFullYear()).arg(("0"+logDate.getMonth()).slice(-2)).arg(("0"+logDate.getDay()).slice(-2)).arg(logDate.toTimeString()).arg(systemdUnit).arg(MESSAGE)
      property var logDate: new Date(parseInt(__REALTIME_TIMESTAMP)/1000) //ts is in microseconds
      readonly property string systemdUnit: String(_SYSTEMD_UNIT).indexOf("undefined") === -1 ? String(_SYSTEMD_UNIT).replace(".service", ":") : ""; //we need more screen real estate
    }
    ScrollBar.vertical: ScrollBar {
      width: 16
      visible: lvJournalView.contentHeight>lvJournalView.height
      Component.onCompleted: {
        if(QT_VERSION >= 0x050900) //policy was added after 5.7
        {
          policy = ScrollBar.AlwaysOn;
        }
      }
    }
  }
}
