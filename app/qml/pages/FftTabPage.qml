import QtQuick 2.0
import GlobalConfig 1.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.14
import ZeraTranslation  1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import AppStarterForWebGLSingleton 1.0
import "../controls/fft_module"

BaseTabPage {
    id: root
    readonly property bool hasFft: VeinEntity.hasEntity("FFTModule1")
    readonly property bool hasOsci: VeinEntity.hasEntity("OSCIModule1")

    // TabButtons
    Component {
        id: tabChart
        ZTabButton {
            text: Z.tr("Harmonic table")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabEnergy
        ZTabButton {
            text: Z.tr("Harmonic chart")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabOsc
        ZTabButton {
            text: Z.tr("Oscilloscope plot")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }

    // Pages
    Component {
        id: pageTable
        FftTable {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_HARMONIC_TABLE
                }
            }
        }
    }
    Component {
        id: pageChart
        FftCharts {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_HARMONIC_CHART
                }
            }
        }
    }
    Component {
        id: pageOsc
        OsciModulePage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_CURVE_DISPLAY
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        if(hasFft) {
            tabBar.addItem(tabChart.createObject(tabBar))
            swipeView.addItem(pageTable.createObject(swipeView))

            tabBar.addItem(tabEnergy.createObject(tabBar))
            swipeView.addItem(pageChart.createObject(swipeView))
        }
        /* OsciModulePage works properly only sometimes. It causes two possible
           error situation on remote WebGL
           1. The curve is drawn once but then the whole GUI freezes and the user
              has to reconnect. After that 2. is the result
           2. The curve is not drawn
           We tried hard not to disable OsciModulePage:
           * Disable useOpenGL for WebGL: This results in complete reddraw of
             screen once new values are to be drawn
           * OpneGL/OpenGLES: No change
           * Different versions of Qt: No change
          */
        if(hasOsci && !ASWGL.isServer) {
            tabBar.addItem(tabOsc.createObject(tabBar))
            swipeView.addItem(pageOsc.createObject(swipeView))
        }

        finishInit()
    }
}
