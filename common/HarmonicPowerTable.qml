import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0

Item {
  id: root

  readonly property QtObject glueLogic: ZGL;
  readonly property int channelCount: ModuleIntrospection.p3m1Introspection.ModuleInfo.HPWCount;
  readonly property int hpwOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder; //the power3module harmonic order depends on the fftmodule
  property int rowHeight: Math.floor(height/20)
  property int columnWidth: (width - vBar.width - width/20)/9

  readonly property bool relativeView: GC.showFftTableAsRelative > 0;
  readonly property string relativeUnit: relativeView ? " %" : "";

  Item {
    width: root.width
    height: root.height

    ScrollBar {
      z: 1
      id: vBar
      anchors.right: parent.right
      anchors.top: fftFlickable.top
      anchors.topMargin: harmonicHeaders.height
      anchors.bottom: fftFlickable.bottom
      orientation: Qt.Vertical
      Component.onCompleted: {
        if(QT_VERSION >= 0x050900) //policy was added after 5.7
        {
          policy = ScrollBar.AlwaysOn
        }
      }
    }

    Flickable {
      id: fftFlickable
      anchors.fill: parent
      anchors.bottomMargin: parent.height%root.rowHeight
      anchors.rightMargin: 16
      contentWidth: root.columnWidth*(1+root.channelCount*2)-16
      contentHeight: root.rowHeight*(hpwOrder+1)
      clip: true
      interactive: true
      boundsBehavior: Flickable.StopAtBounds

      ScrollBar.vertical: vBar

      Row {
        id: harmonicHeaders
        anchors.left: parent.left
        anchors.right: parent.right
        y: fftFlickable.contentY
        z: 1
        height: root.rowHeight

        CCMP.GridItem {
          border.color: "#444" //disable border transparency
          x: fftFlickable.contentX //keep item visible
          z: 1
          width: root.width/20
          height: root.rowHeight
          color: GC.tableShadeColor
          text: "n"
          textColor: Material.primaryTextColor
          font.bold: true
        }

        Repeater {
          model: root.channelCount
          delegate: Row {
            width: root.columnWidth*3
            height: root.rowHeight
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              color: GC.tableShadeColor
              border.color: "#444" //disable border transparency
              text: ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPP%1").arg(index+1)].ChannelName + relativeUnit; //P
              textColor: GC.getColorByIndex(index+1)
              font.bold: true
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              color: GC.tableShadeColor
              border.color: "#444" //disable border transparency
              text: ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPQ%1").arg(index+1)].ChannelName + relativeUnit; //Q
              textColor: GC.getColorByIndex(index+1)
              font.bold: true
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              color: GC.tableShadeColor
              border.color: "#444" //disable border transparency
              text: ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPS%1").arg(index+1)].ChannelName + relativeUnit; //S
              textColor: GC.getColorByIndex(index+1)
              font.bold: true
            }
          }
        }
      }

      ListView {
        id: lvHarmonics
        z: -1
        y: harmonicHeaders.height
        width: root.columnWidth*17
        height: root.rowHeight*(hpwOrder+1)

        model: relativeView ? glueLogic.HPWRelativeTableModel : glueLogic.HPWTableModel
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: root.hpwOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"
        clip: true

        //ScrollBar.vertical: vBar

        delegate: Component {
          Row {
            height: root.rowHeight

            CCMP.GridItem {
              border.color: "#444" //disable border transparency
              x: fftFlickable.contentX //keep item visible
              z: 1
              width: root.width/20
              height: root.rowHeight
              color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
              text: index
              font.bold: true
            }
            //S1
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS1P !== undefined ? GC.formatNumber(PowerS1P, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPP1.Unit : "")
              textColor: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS1Q !== undefined ? GC.formatNumber(PowerS1Q, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPQ1.Unit : "")
              textColor: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS1S !== undefined ? GC.formatNumber(PowerS1S, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPS1.Unit : "")
              textColor: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
            }
            //S2
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS2P !== undefined ? GC.formatNumber(PowerS2P, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPP2.Unit : "")
              textColor: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS2Q !== undefined ? GC.formatNumber(PowerS2Q, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPQ2.Unit : "")
              textColor: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS2S !== undefined ? GC.formatNumber(PowerS2S, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPS2.Unit : "")
              textColor: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
            }
            //S3
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS3P !== undefined ? GC.formatNumber(PowerS3P, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPP3.Unit : "")
              textColor: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS3Q !== undefined ? GC.formatNumber(PowerS3Q, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPQ3.Unit : "")
              textColor: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (PowerS3S !== undefined ? GC.formatNumber(PowerS3S, 3) : "") + (relativeView && index===1 ? " "+ModuleIntrospection.p3m1Introspection.ComponentInfo.ACT_HPS3.Unit : "")
              textColor: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
            }
          }
        }
      }
    }
  }
}
