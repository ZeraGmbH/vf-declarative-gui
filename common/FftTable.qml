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
  readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")
  readonly property int channelCount: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount;
  readonly property int fftOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder;
  property int rowHeight: Math.floor(height/20)
  property int columnWidth: width/13

  Item {
    width: root.columnWidth*13
    height: root.height
    anchors.centerIn: parent

    ScrollBar {
      z: 1
      id: vBar
      anchors.right: parent.right
      anchors.top: fftFlickable.top
      anchors.topMargin: root.rowHeight*2
      anchors.bottom: fftFlickable.bottom
      orientation: Qt.Vertical
      Component.onCompleted: {
        if(QT_VERSION >= 0x050900) //policy was added after 5.7
        {
          policy = ScrollBar.AlwaysOn
        }
      }
    }
    ScrollBar {
      id: hBar
      anchors.top: fftFlickable.bottom
      anchors.left: fftFlickable.left
      anchors.right: fftFlickable.right
      orientation: Qt.Horizontal
      Component.onCompleted: {
        if(QT_VERSION >= 0x050900) //policy was added after 5.7
        {
          policy = Qt.binding(function (){ return fftFlickable.contentWidth > fftFlickable.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff; });
        }
      }
    }

    Flickable {
      id: fftFlickable
      anchors.fill: parent
      anchors.bottomMargin: parent.height%root.rowHeight
      anchors.rightMargin: 16
      contentWidth: root.columnWidth*(1+root.channelCount*2)-16
      clip: true
      interactive: false

      ScrollBar.horizontal: hBar

      Row {
        id: titleRow
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.rowHeight

        Rectangle {
          color: Material.backgroundColor //hide item below
          x: fftFlickable.contentX //keep item visible
          z: 1
          width: root.columnWidth-16
          height: root.rowHeight
        }

        Repeater {
          model: root.channelCount
          delegate:CCMP.GridRect {
            width: root.columnWidth*2
            height: root.rowHeight
            color: GC.tableShadeColor
            Label {
              text: ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+(index+1)].ChannelName
              anchors.centerIn: parent
              anchors.rightMargin: 8
              font.pixelSize: rowHeight
              font.family: "Droid Sans Mono"
              font.bold: true
              color: GC.getColorByIndex(index+1)
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              textFormat: Text.PlainText
            }
          }
        }
      }

      Row {
        id: harmonicHeaders
        anchors.top: titleRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.rowHeight

        CCMP.GridItem {
          border.color: "#444" //disable border transparency
          x: fftFlickable.contentX //keep item visible
          z: 1
          width: root.columnWidth-16
          height: root.rowHeight
          color: GC.tableShadeColor
          text: "n"
          textColor: Material.primaryTextColor
          font.bold: true
        }

        Repeater {
          model: root.channelCount
          delegate: Row {
            width: root.columnWidth*2
            height: root.rowHeight
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              color: GC.tableShadeColor
              text: ZTR["Amp"]
              textColor: GC.getColorByIndex(index+1)
              font.bold: true
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              color: GC.tableShadeColor
              text: ZTR["Phase"]
              textColor: GC.getColorByIndex(index+1)
              font.bold: true
            }
          }
        }
      }

      ListView {
        id: lvHarmonics
        anchors.top: harmonicHeaders.bottom
        width: root.columnWidth*17
        height: root.rowHeight*18//root.rowHeight*fftOrder

        model: glueLogic.FFTTableModel
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: root.fftOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"
        clip: true

        ScrollBar.vertical: vBar

        delegate: Component {
          Row {
            height: root.rowHeight

            CCMP.GridItem {
              border.color: "#444" //disable border transparency
              x: fftFlickable.contentX //keep item visible
              z: 1
              width: root.columnWidth-16
              height: root.rowHeight
              color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
              text: index
              font.bold: true
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL1 ? GC.formatNumber(AmplitudeL1, 3) : ""
              textColor: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL1 ? GC.formatNumber(VectorL1, 3) : ""
              textColor: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL2 ? GC.formatNumber(AmplitudeL2, 3) : ""
              textColor: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL2 ? GC.formatNumber(VectorL2, 3) : ""
              textColor: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL3 ? GC.formatNumber(AmplitudeL3, 3) : ""
              textColor: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL3 ? GC.formatNumber(VectorL3, 3) : ""
              textColor: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL4 ? GC.formatNumber(AmplitudeL4, 3) : ""
              textColor: GC.system1ColorBright
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL4 ? GC.formatNumber(VectorL4, 3) : ""
              textColor: GC.system1ColorBright
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL5 ? GC.formatNumber(AmplitudeL5, 3) : ""
              textColor: GC.system2ColorBright
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL5 ? GC.formatNumber(VectorL5, 3) : ""
              textColor: GC.system2ColorBright
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL6 ? GC.formatNumber(AmplitudeL6, 3) : ""
              textColor: GC.system3ColorBright
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL6 ? GC.formatNumber(VectorL6, 3) : ""
              textColor: GC.system3ColorBright
              font.pixelSize: rowHeight*0.5
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL7 ? GC.formatNumber(AmplitudeL7, 3) : ""
              textColor: GC.system4ColorDark
              font.pixelSize: rowHeight*0.5
              visible: root.channelCount>6
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL7 ? GC.formatNumber(VectorL7, 3) : ""
              textColor: GC.system4ColorDark
              font.pixelSize: rowHeight*0.5
              visible: root.channelCount>6
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: AmplitudeL8 ? GC.formatNumber(AmplitudeL8, 3) : ""
              textColor: GC.system4ColorBright
              font.pixelSize: rowHeight*0.5
              visible: root.channelCount>6
            }
            CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL8 ? GC.formatNumber(VectorL8, 3) : ""
              textColor: GC.system4ColorBright
              font.pixelSize: rowHeight*0.5
              visible: root.channelCount>6
            }
          }
        }
      }
    }
  }
}
