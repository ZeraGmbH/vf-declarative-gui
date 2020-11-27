import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0

StackLayout {
    id: menuStackLayout

    signal pleaseCloseMe(bool butOpenMenu)

    // Some notes on auto-open views/popup that are intended to enhance
    // user-experience. We have 3 cases currently:
    //
    // 1. In case user clicks logStartButton in MainToolBar.qml,
    //    function open() in LoggerMenu.qml checks if a database is loaded.
    //    If not show LoggerSettings instead of LoggerMenu. This ist strongly
    //    coupled logStartButton.onClicked - that also makes some decisions
    //    which main page to show. Yeah that is a bit of a spaghetti-hack it
    //    was the only way to get the behaviour wanted without passing
    //    MainToolBar's internals to LoggerMenu.
    // 2. In case user wants to set-up sessions, showSessionNameSelector() (see
    //    below) checks if there are sessions already available. If not it
    //    passes over to showSessionNew() (see below either)


    property int lastIndex
    function goBack() {
        currentIndex = lastIndex
    }

    function showSettings() { lastIndex=currentIndex; currentIndex = 0 }
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
        lastIndex = currentIndex
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

    function showSessionNew() { lastIndex=currentIndex; currentIndex = 2 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerSessionNew{ }
        active: menuStackLayout.currentIndex === 2
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showCustomDataSelector() { lastIndex=currentIndex; currentIndex = 3 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerCustomDataSelector{ }
        active: menuStackLayout.currentIndex === 3
    }

    function showExportView() { lastIndex=currentIndex; currentIndex = 4 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: LoggerExport { }
        active: menuStackLayout.currentIndex === 4
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showCustomerDataBrowser() { lastIndex=currentIndex; currentIndex = 5 }
    Loader {
        height: parent.height
        width: parent.width
        sourceComponent: CustomerDataBrowser { }
        active: menuStackLayout.currentIndex === 5
        onLoaded: {
            item.menuStackLayout = menuStackLayout
        }
    }

    function showCustomerDataEditor() { lastIndex=currentIndex; currentIndex = 6 }
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
