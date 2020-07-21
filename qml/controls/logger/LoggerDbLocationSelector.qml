import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP
import ZeraFa 1.0



RowLayout {
  id: root
  property alias currentIndex: dbLocationSelector.currentIndex

  property var storageList: [];
  property int rowHeight;
  property int pointSize: 20;
  readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
  property var listStorageTracer;

  signal newIndexSelected(bool byUser);

  Component.onCompleted: updateStorageList();

  function updateStorageList() {
    if(!listStorageTracer)
    {
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
        root.storageList = t_resultData["ZeraDBLogger::storageList"];
        listStorageTracer = undefined;
        if(storageList.length>0)
        {
          var selectedStorage = String(loggerEntity.DatabaseFile);
          if(selectedStorage.length === 0)
          {
            selectedStorage = GC.currentSelectedStoragePath;
          }

          for(var storageIdx in storageList)
          {
            if(selectedStorage.indexOf(storageList[storageIdx]) === 0)
            {
              root.currentIndex = storageIdx;
              root.newIndexSelected(false);
            }
          }
        }
      }
    }
  }

  Label {
    textFormat: Text.PlainText
    text: ZTR["DB location:"]
    height: rowHeight
    font.pointSize: root.pointSize
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
      id: storageListWarning
      anchors.centerIn: parent
      font.family: FA.old
      font.pointSize: root.pointSize
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
    font.pointSize: root.pointSize
    enabled: root.storageList.length > 0
    Layout.fillWidth: true
    Layout.fillHeight: true

    Connections {
      target: GC
      onCurrentSelectedStoragePathChanged: {
        currentIndex = storageList.indexOf(GC.currentSelectedStoragePath);
      }
    }

    onActivated: {
      GC.currentSelectedStoragePath = storageList[index];
      root.newIndexSelected(true);
    }
  }
  Button {
    font.family: FA.old
    height: root.rowHeight
    font.pointSize: root.pointSize
    text: FA.fa_refresh
    onClicked: {
      if(root.listStorageTracer === undefined)
      {
        root.updateStorageList();
      }
    }
  }
}
