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
        tasksLoaderActivate.loaderStarted = false
        tasksLoaderActivate.startRun()
    }
    function stopPreloadPages() {
        console.info("Deativate preloaded pages.")
        tasksLoaderActivate.loaderStarted = false
        tasksLoaderActivate.stop()
        deactivatePageLoader(pageViewLoader)
        deactivatePageLoader(rangeMModePageLoader)
        deactivatePageLoader(settingsLoader)
    }

    // private
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
                    console.info("Preload PageView...")
                    activatePageLoader(pageViewLoader)
                }
            },
            {
                'type': 'block',
                'callFunction': () => {
                    console.info("Preload RangeMModePage...")
                    activatePageLoader(rangeMModePageLoader)
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
            loaderStarted = true
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
