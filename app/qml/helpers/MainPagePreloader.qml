import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0

Item {
    // public
    function initPageLoaders() {
        bindPageLoaderForEarlyShow(pageViewLoader)
        bindPageLoaderForEarlyShow(rangeMModePageLoader)
        bindPageLoaderForEarlyShow(settingsLoader)
    }
    function startPreloadPages() {
        preloadStartDelay.start()
    }
    function stopPreloadPages() {
        if (tasksLoaderActivate.loaderStarted) {
            console.info("Deativate preloaded pages.")
            preloadStartDelay.stop()
            tasksLoaderActivate.stop()
            deactivatePageLoader(pageViewLoader)
            deactivatePageLoader(rangeMModePageLoader)
            deactivatePageLoader(settingsLoader)
            tasksLoaderActivate.loaderStarted = false
        }
    }

    // private
    Timer {
        id: preloadStartDelay
        // Background
        // * autobuilder-dut-testsuite hammers session change as fast as possible by SCPI
        // * session change calls stopPreloadPages() which deactivates all preloaded loaders
        // * ATOW we have qtdeclarative 5.14 which can cause crahsers unloading an unfished async loader
        // => To work around crasher, async loader activation is delayed to be started after session change is caused
        interval: 2000
        repeat: false
        onTriggered: {
            tasksLoaderActivate.loaderStarted = false
            tasksLoaderActivate.startRun()
        }
    }
    function bindPageLoaderForEarlyShow(pageLoader) {
        // ensure user show request is handled before preload finished - binding will be broken
        pageLoader.active = Qt.binding(function() { return pageLoader.pageVisible })
    }
    function deactivatePageLoader(pageLoader) {
        pageLoader.active = false
    }
    TaskList {
        id: tasksLoaderActivate
        taskArray: [
            {   // settingsLoader takes longest => load it first
                'type': 'block',
                'callFunction': () => {
                    console.info("Preload SettingsPage...")
                    activatePageLoader(settingsLoader)
                }
            },
            {
                'type': 'block',
                'callFunction': () => {
                    console.info("Preload RangeMModePage...")
                    activatePageLoader(rangeMModePageLoader)
                }
            },
            {   // pageViewLoader last: Consider fast user session change => possibe crasher - see preloadStartDelay
                // => delay session change by letting users wait for pageViewLoader up
                'type': 'block',
                'callFunction': () => {
                    console.info("Preload PageView...")
                    activatePageLoader(pageViewLoader)
                }
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
        property bool loaderStarted: false
        function activatePageLoader(loader) {
            if (loader.active)
                return true
            loader.active = true
            tasksLoaderActivate.loaderStarted = true
            return false
        }
    }
    Connections {
        target: settingsLoader
        function onLoaded() { tasksLoaderActivate.startNextTask() }
    }
    Connections {
        target: pageViewLoader
        function onLoaded() { tasksLoaderActivate.startNextTask() }
    }
    Connections {
        target: rangeMModePageLoader
        function onLoaded() { tasksLoaderActivate.startNextTask() }
    }
}
