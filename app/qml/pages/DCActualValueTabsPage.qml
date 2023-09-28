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
            text:Z.tr("Actual values DC")
            font.pointSize: root.height/40
            height: root.height/15
        }
    }

    // Pages
    Component {
        id: pageTable
        // just temp
        DCActualValuesPage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ACTUAL_VALUES
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(tabTable.createObject(tabBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        finishInit()
    }
}
