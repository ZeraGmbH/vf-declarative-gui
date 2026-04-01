import QtQuick 2.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0

BaseTabPage {
    id: root

    tabBar: tabBarItem
    swipeView: swipeViewItem

    BaseTabBar {
        id: tabBarItem
        height: tabHeight
        font.pointSize: tabPointSize
        ZTabButton {
            text: Z.tr("Actual values")
        }
        ZTabButton {
            text: Z.tr("Vector diagram")
        }
        ZTabButton {
            text: Z.tr("Power values")
        }
        ZTabButton {
            text: Z.tr("RMS values")
        }
    }
    BaseTabView {
        id: swipeViewItem
        ActualValuesPage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem)
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ACTUAL_VALUES
            }
        }
        VectorModulePage {
            topMargin: 10
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem)
                    GC.currentGuiContext = GC.guiContextEnum.GUI_VECTOR_DIAGRAM
            }
        }
        PowerModulePage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem)
                    GC.currentGuiContext = GC.guiContextEnum.GUI_POWER_VALUES
            }
        }
        RMS4PhasePage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem)
                    GC.currentGuiContext = GC.guiContextEnum.GUI_RMS_VALUES
            }
        }
    }

    Component.onCompleted: {
        finishInit()
    }
}
