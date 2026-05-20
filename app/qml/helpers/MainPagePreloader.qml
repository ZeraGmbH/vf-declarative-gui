import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0

Item {
    // public
    function resetPageLoaders() {
        console.info("Reset on demand page loaders")
        tasksLoaderActivate.loaderStarted = false
        tasksLoaderActivate.stop()
        // ensure user show request will be handle before preload finished
        pageViewLoader.active = Qt.binding(function() { return pageViewLoader.pageVisible })
        rangeMModePageLoader.active = Qt.binding(function() { return rangeMModePageLoader.pageVisible })
    }
    function startPreloadPages() {
        tasksLoaderActivate.loaderStarted = false
        delayTimer.start()
    }

    // private
    Timer {
        id: delayTimer
        interval: 2000
        repeat: false
        running: false
        onTriggered: { tasksLoaderActivate.startRun() }
    }
    Connections {
        target: pageViewLoader
        function onLoaded() { tasksLoaderActivate.startNextTask() }
    }
    Connections {
        target: rangeMModePageLoader
        function onLoaded() { tasksLoaderActivate.startNextTask() }
    }
    TaskList {
        id: tasksLoaderActivate
        property bool loaderStarted: false
        taskArray: [
            {
                'type': 'block',
                'callFunction': () => setActive(pageViewLoader)
            },
            {
                'type': 'block',
                'callFunction': () => setActive(rangeMModePageLoader)
            },
            {
                'type': 'block',
                'callFunction': () => {
                    if (tasksLoaderActivate.loaderStarted)
                        console.info("All on demand pages preloaded")
                    return true
                }
            }
        ]
        function setActive(loader) {
            if (loader.active)
                return true
            loader.active = true
            loaderStarted = true
            return false
        }
    }
}
