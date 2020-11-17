import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0

StackLayout {
    id: menuStackLayout

    signal pleaseCloseMe(bool butOpenMenu)

    function showSettings() { currentIndex = 0 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerSettings { }
        active: menuStackLayout.currentIndex === 0
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showSessionNameSelector() {
        // In case no sessions were created yet: Move to sessions new
        var loggerEntity = VeinEntity.getEntity("_LoggingSystem")
        if(loggerEntity && loggerEntity.ExistingSessions.length === 0) {
            showSessionNew()
        }
        else {
            currentIndex = 1
        }
    }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerSessionNameSelector { }
        active: menuStackLayout.currentIndex === 1
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showSessionNew() { currentIndex = 2 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerSessionNew{ }
        active: menuStackLayout.currentIndex === 2
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showCustomDataSelector() { currentIndex = 3 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerCustomDataSelector{ }
        active: menuStackLayout.currentIndex === 3
    }

    function showExportView() { currentIndex = 4 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerExport { }
        active: menuStackLayout.currentIndex === 4
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showCustomerDataBrowser() { currentIndex = 5 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: CustomerDataBrowser { }
        active: menuStackLayout.currentIndex === 5
        onLoaded: {
            item.menuStackLayout = menuStackLayout
            // In case no customer-data were created yet: open new-popup
            var filesEntity = VeinEntity.getEntity("_Files")
            if(filesEntity && filesEntity.AvailableCustomerData.length === 0) {
                item.openNewCustomerDataPopup()
            }
        }
    }

    function showCustomerDataEditor() { currentIndex = 6 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: CustomerDataEditor { }
        active: menuStackLayout.currentIndex === 6
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }
}
