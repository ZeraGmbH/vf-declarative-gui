import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP

Item {
  id: root

  readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
  readonly property int channelCount: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount;
  readonly property int fftOrder: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTOrder;
  readonly property int rowHeight: Math.floor(height/14)
  readonly property int columnWidth: width/7
  readonly property bool hasHorizScroll: GC.showFftTablePhase ? channelCount > 3 : channelCount > 6

  readonly property bool relativeView: GC.showFftTableAsRelative > 0;

  ScrollBar {
    z: 1
    id: vBar
    anchors.right: parent.right
    anchors.top: fftFlickable.top
    anchors.topMargin: root.rowHeight*3
    anchors.bottom: fftFlickable.bottom
    orientation: Qt.Vertical
    policy: ScrollBar.AlwaysOn
  }
  ScrollBar {
    id: hBar
    anchors.top: fftFlickable.bottom
    anchors.left: fftFlickable.left
    anchors.leftMargin: root.columnWidth-16
    anchors.right: fftFlickable.right
    orientation: Qt.Horizontal
    policy: hasHorizScroll ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
  }

  Flickable {
    id: fftFlickable
    anchors.fill: parent
    anchors.bottomMargin: parent.height%root.rowHeight
    anchors.rightMargin: 16
    contentWidth: lvHarmonics.width
    contentHeight: root.rowHeight*(fftOrder+3)
    clip: true
    interactive: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: hasHorizScroll ? Flickable.HorizontalAndVerticalFlick : Flickable.VerticalFlick

    ScrollBar.horizontal: hBar
    ScrollBar.vertical: vBar
    // The following dance is necessary to improve swiping into next tab.
    onAtXBeginningChanged: {
      helperMouseArea.enabled = hasHorizScroll && atXBeginning
    }
    onAtXEndChanged: {
      helperMouseArea.enabled = hasHorizScroll && atXEnd
    }

    Row {
      id: titleRow
      anchors.left: parent.left
      anchors.right: parent.right
      height: root.rowHeight
      y: fftFlickable.contentY //keep item visible on y axis moves
      z: 1

      Rectangle {
        color: Material.backgroundColor //hide item below
        x: fftFlickable.contentX //keep item visible on x axis moves
        z: 1
        width: root.columnWidth-16
        height: root.rowHeight
      }

      Repeater {
        model: root.channelCount
        delegate: CCMP.GridRect {
          width: root.columnWidth*(GC.showFftTablePhase ? 2 : 1)
          height: root.rowHeight
          color: GC.tableShadeColor
          border.color: "#444" //disable border transparency
          Label {
            text: ZTR[ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+(index+1)].ChannelName]
            anchors.centerIn: parent
            anchors.rightMargin: 8
            font.pixelSize: rowHeight*0.5
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
      id: thdnHeaders
      anchors.top: titleRow.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: root.rowHeight

      CCMP.GridItem {
        border.color: "#444" //disable border transparency
        x: fftFlickable.contentX //keep item visible on x axis moves
        z: 1
        width: root.columnWidth-16
        textAnchors.rightMargin: 2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: ZTR["THDN:"]
        textColor: Material.primaryTextColor
        font.bold: true
      }

      Repeater {
        model: root.channelCount
        CCMP.GridItem {
          width: root.columnWidth* (GC.showFftTablePhase ? 2 : 1)
          height: root.rowHeight
          readonly property string componentName: String("ACT_THDN%1").arg(index+1);
          readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
          text: GC.formatNumber(thdnModule[componentName]) + unit
          textColor: GC.getColorByIndex(index+1)
          font.pixelSize: rowHeight*0.5
          border.color: "#444" //disable border transparency
        }
      }
    }

    Row {
      id: harmonicHeaders
      anchors.top: thdnHeaders.bottom
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
          width: root.columnWidth*(GC.showFftTablePhase ? 2 : 1)
          height: root.rowHeight
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: GC.tableShadeColor
            border.color: "#444" //disable border transparency
            text: ZTR["Amp"] + (relativeView ? " [%]" : " ["+ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(index+1)].Unit+"]");
            textColor: GC.getColorByIndex(index+1)
            font.pixelSize: rowHeight*0.5
            font.bold: true
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              color: GC.tableShadeColor
              border.color: "#444" //disable border transparency
              text: ZTR["Phase"] + " [°]"
              textColor: GC.getColorByIndex(index+1)
              font.pixelSize: rowHeight*0.5
              font.bold: true
            }
          }
        }
      }
    }

    ListView {
      id: lvHarmonics
      z: -1
      y: root.rowHeight*3
      width: root.columnWidth*(GC.showFftTablePhase ? channelCount*2+1 : channelCount+1) - 16
      height: root.rowHeight*(fftOrder+3)

      model: relativeView ? ZGL.FFTRelativeTableModel : ZGL.FFTTableModel
      boundsBehavior: Flickable.StopAtBounds
      cacheBuffer: root.fftOrder*root.rowHeight //prevents visual issue with index counter using "x: fftFlickable.contentX"

      clip: true

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
            text: (AmplitudeL1 !== undefined ? GC.formatNumber(AmplitudeL1, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT1.Unit : "")
            textColor: GC.system1ColorDark
            font.pixelSize: rowHeight*0.5
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: GC.showFftTablePhase && VectorL1 !== undefined ? GC.formatNumber(VectorL1, 3) : ""
              textColor: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
            }
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: (AmplitudeL2 !== undefined ? GC.formatNumber(AmplitudeL2, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT2.Unit : "")
            textColor: GC.system2ColorDark
            font.pixelSize: rowHeight*0.5
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: GC.showFftTablePhase && VectorL2 !== undefined ? GC.formatNumber(VectorL2, 3) : ""
              textColor: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
            }
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: (AmplitudeL3 !== undefined ? GC.formatNumber(AmplitudeL3, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT3.Unit : "")
            textColor: GC.system3ColorDark
            font.pixelSize: rowHeight*0.5
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: GC.showFftTablePhase && VectorL3 !== undefined ? GC.formatNumber(VectorL3, 3) : ""
              textColor: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
            }
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: (AmplitudeL4 !== undefined ? GC.formatNumber(AmplitudeL4, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT4.Unit : "")
            textColor: GC.system1ColorBright
            font.pixelSize: rowHeight*0.5
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: GC.showFftTablePhase && VectorL4 !== undefined ? GC.formatNumber(VectorL4, 3) : ""
              textColor: GC.system1ColorBright
              font.pixelSize: rowHeight*0.5
            }
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: (AmplitudeL5 !== undefined ? GC.formatNumber(AmplitudeL5, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT5.Unit : "")
            textColor: GC.system2ColorBright
            font.pixelSize: rowHeight*0.5
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: GC.showFftTablePhase && VectorL5 !== undefined ? GC.formatNumber(VectorL5, 3) : ""
              textColor: GC.system2ColorBright
              font.pixelSize: rowHeight*0.5
            }
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: (AmplitudeL6 !== undefined ? GC.formatNumber(AmplitudeL6, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT6.Unit : "")
            textColor: GC.system3ColorBright
            font.pixelSize: rowHeight*0.5
          }
          Loader {
            active: GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: GC.showFftTablePhase && VectorL6 !== undefined ? GC.formatNumber(VectorL6, 3) : ""
              textColor: GC.system3ColorBright
              font.pixelSize: rowHeight*0.5
            }
          }
          Loader {
            active: root.channelCount>6
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (AmplitudeL7 !== undefined ? GC.formatNumber(AmplitudeL7, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT7.Unit : "")
              textColor: GC.system4ColorDark
              font.pixelSize: rowHeight*0.5
            }
          }
          Loader {
            active: root.channelCount>6 && GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: VectorL7 !== undefined ? GC.formatNumber(VectorL7, 3) : ""
            textColor: GC.system4ColorDark
            font.pixelSize: rowHeight*0.5
            }
          }
          Loader {
            active: root.channelCount>7
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: (AmplitudeL8 !== undefined ? GC.formatNumber(AmplitudeL8, 3) : "") + (relativeView && index===1 ? ModuleIntrospection.fftIntrospection.ComponentInfo.ACT_FFT8.Unit : "")
              textColor: GC.system4ColorBright
              font.pixelSize: rowHeight*0.5
            }
          }
          Loader {
            active: root.channelCount>7 && GC.showFftTablePhase
            sourceComponent: CCMP.GridItem {
              width: root.columnWidth
              height: root.rowHeight
              text: VectorL8 !== undefined ? GC.formatNumber(VectorL8, 3) : ""
              textColor: GC.system4ColorBright
              font.pixelSize: rowHeight*0.5
            }
          }
        }
      }
    }
  }
  MouseArea {
    id: helperMouseArea
    anchors.fill: parent
    anchors.rightMargin: vBar.width
    anchors.bottomMargin: hBar.height
    enabled: false
    drag.axis: Drag.XAxis
    property real oldXPos: 0
    onPositionChanged: {
      // can we swipe contents left?
      if(mouse.x > oldXPos && fftFlickable.atXEnd)
        enabled = false
      // can we swipe contents right?
      if(mouse.x < oldXPos && fftFlickable.atXBeginning)
        enabled = false
      oldXPos = mouse.x
    }
  }
}
