import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0

BaseTabPage {
    id: root

    // TabButtons
    Component {
        id: tabTable
        TabButton {
            text:Z.tr("Actual values")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabVector
        TabButton {
            text: Z.tr("Vector diagram")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }

    // Pages
    Component {
        id: pageTable
        EMOBActualValuesPage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ACTUAL_VALUES
                }
            }
        }
    }
    Component {
        id: pageVector
        VectorModulePage {
            topMargin: 10
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_VECTOR_DIAGRAM
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(tabTable.createObject(tabBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        tabBar.addItem(tabVector.createObject(tabBar))
        swipeView.addItem(pageVector.createObject(swipeView))

        finishInit()
    }
}
