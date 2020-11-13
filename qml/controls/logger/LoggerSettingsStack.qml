import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

StackLayout {
    id: menuStackLayout

    signal pleaseCloseMe()

    function showSettings() { currentIndex = 0 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerSettings { }
        active: menuStackLayout.currentIndex === 0
    }

    function showSessionNameSelector() { currentIndex = 1 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerSessionNameSelector { }
        active: menuStackLayout.currentIndex === 1
    }

    function showCustomDataSelector() { currentIndex = 2 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerCustomDataSelector{ }
        active: menuStackLayout.currentIndex === 2
    }

    // Under loader control LoggerExport cannot acces menuStackLayout - sighh
    function showExportView() { currentIndex = 3 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerExport { id: loggerExport }
        active: menuStackLayout.currentIndex === 3
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }
}
