import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root

  readonly property int rowHeight: Math.floor(height/8)
  readonly property int basicRowWidth: width*0.05
  readonly property int wideRowWidth: width*0.2

  readonly property QtObject power1Module1: VeinEntity.getEntity("POWER1Module1")
  readonly property QtObject power1Module2: VeinEntity.getEntity("POWER1Module2")
  readonly property QtObject power1Module3: VeinEntity.getEntity("POWER1Module3")

  //the function exists because it is impossible to use scripted value in ListModel
  function getModule(index) {
    var retVal;
    switch(index) {
    case 0:
      retVal = power1Module1;
      break;
    case 1:
      retVal = power1Module2;
      break;
    case 2:
      retVal = power1Module3;
      break;
    }
    return retVal;
  }

  //the function exists because it is impossible to use scripted value in ListModel
  function getMetadata(index) {
    var retVal;
    switch(index) {
    case 0:
      retVal = ModuleIntrospection.p1m1Introspection;
      break;
    case 1:
      retVal = ModuleIntrospection.p1m2Introspection;
      break;
    case 2:
      retVal = ModuleIntrospection.p1m3Introspection;
      break;
    }
    return retVal
  }

  Row {
    id: heardersRow
    CCMP.GridRect {
      width: basicRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor
      //spacer
    }
    CCMP.GridItem {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor
      text: ZTR["L1"]
      textColor: GC.system1ColorDark
      font.bold: true
      font.pixelSize: height*0.4
    }
    CCMP.GridItem {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor
      text: ZTR["L2"]
      textColor: GC.system2ColorDark
      font.bold: true
      font.pixelSize: height*0.4
    }
    CCMP.GridItem {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor
      text: ZTR["L3"]
      textColor: GC.system3ColorDark
      font.bold: true
      font.pixelSize: height*0.4
    }
    CCMP.GridItem {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor
      text: "Σ"
      font.bold: true
      font.pixelSize: height*0.4
    }
    CCMP.GridItem {
      width: basicRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor
      text: "[ ]"
      font.bold: true
      font.pixelSize: height*0.3
    }
    CCMP.GridRect {
      //mode switch has no header
      width: basicRowWidth*2
      height: root.rowHeight
      color: GC.tableShadeColor
    }
  }

  ListView {
    anchors.top: heardersRow.bottom
    height: root.rowHeight*count
    width: parent.width
    //used number as model since the ListModel cannot use scripted values
    model: 3
    boundsBehavior: ListView.StopAtBounds
    interactive: false

    delegate: Component {
      Row {
        CCMP.GridItem {
          width: basicRowWidth
          height: root.rowHeight
          color: GC.tableShadeColor
          text: (root.getMetadata(index).ComponentInfo.ACT_PQS1.ChannelName).slice(0,1); //(P/Q/S)1 -> (P/Q/S)
          font.bold: true
          font.pixelSize: height*0.4

        }
        CCMP.GridItem {
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          text: GC.formatNumber(root.getModule(index).ACT_PQS1);
          textColor: GC.system1ColorDark
          font.pixelSize: height*0.4
        }
        CCMP.GridItem {
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          text: GC.formatNumber(root.getModule(index).ACT_PQS2);
          textColor: GC.system2ColorDark
          font.pixelSize: height*0.4
        }
        CCMP.GridItem {
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          text: GC.formatNumber(root.getModule(index).ACT_PQS3);
          textColor: GC.system3ColorDark
          font.pixelSize: height*0.4
        }
        CCMP.GridItem {
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          text: GC.formatNumber(root.getModule(index).ACT_PQS4);
          font.pixelSize: height*0.4
        }
        CCMP.GridItem {
          width: basicRowWidth
          height: root.rowHeight
          clip: true
          text: root.getMetadata(index).ComponentInfo.ACT_PQS1.Unit
          font.bold: true
          font.pixelSize: height*0.3
        }
        CCMP.GridRect {
          //mode switch
          width: basicRowWidth*2
          height: root.rowHeight
          VFControls.VFComboBox {
            anchors.fill: parent
            arrayMode: true
            entity: root.getModule(index)
            controlPropertyName: "PAR_MeasuringMode"
            model: root.getMetadata(index).ComponentInfo.PAR_MeasuringMode.Validation.Data
            fontSize: Math.min(18, height/1.5, width/4);
          }
        }
      }
    }
  }
}
