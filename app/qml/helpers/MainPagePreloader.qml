import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0

Item {
    // public
    function initPageLoaders() {
        bindPageLoaderForShowBeforeActivate(pageViewLoader)
        bindPageLoaderForShowBeforeActivate(rangeMModePageLoader)
        bindPageLoaderForShowBeforeActivate(settingsLoader)
    }
    function startPreloadPages() {
        tasksLoaderActivate.startRun()
    }
    function stopPreloadPages() {
        if (loaderLoading) {
            console.info("Postpone deactivate preloaded pages...")
            stopRequested = true
        }
        else
            doStopPreloadPages()
    }

    // private
    TaskList {
        id: tasksLoaderActivate
        taskArray: [
            {   // settingsLoader takes longest => load it first
                'type': 'block',
                'callFunction': () => tryActivatePageLoader(settingsLoader, "Preload SettingsPage...")
            },
            {
                'type': 'block',
                'callFunction': () => tryActivatePageLoader(rangeMModePageLoader, "Preload RangeMModePage...")
            },
            {
                'type': 'block',
                'callFunction': () => tryActivatePageLoader(pageViewLoader, "Preload PageView...")
            },
            {
                'type': 'block',
                'callFunction': () => {
                    console.info("All on demand pages preloaded")
                    return true
                }
            }
        ]
    }
    Connections {
        target: settingsLoader
        function onLoaded() { handleLoaded() }
    }
    Connections {
        target: pageViewLoader
        function onLoaded() { handleLoaded() }
    }
    Connections {
        target: rangeMModePageLoader
        function onLoaded() { handleLoaded() }
    }

    // Why is the following so complicated:
    // * ATOW we have qtdeclarative 5.14 which can cause crashers unloading an unfished async loader
    // * autobuilder-dut-testsuite hammers session change as fast as possible by SCPI
    // => Avoid decativating an unfished activation by
    //    waiting for loader to finish activate before deactivate
    //
    // Consequence: The original idea of deactivating loaders during session change was to avoid gazillions
    // of warnings complaing about missing entities/components as:
    // | No entity found with name: "RangeModule1"
    // or
    // | qrc:/qml/controls/ranges/RatioLine.qml:41: TypeError: Cannot read property '0' of undefined
    // By delaying loader deactivate they are back so we might consider fixing them...

    property bool loaderLoading: false
    property bool stopRequested: false
    function bindPageLoaderForShowBeforeActivate(pageLoader) {
        // ensure user show request is handled before preload finished - binding will be broken
        pageLoader.active = Qt.binding(function() { return pageLoader.pageVisible })
    }
    function tryActivatePageLoader(loader, msgText) {
        if (!stopRequested)
            return doActivatePageLoader(loader, msgText)

        Qt.callLater(doStopPreloadPages)
        return false
    }
    function doActivatePageLoader(loader, msgText) {
        console.info(msgText)
        if (loader.active)
            return true
        loaderLoading = true
        loader.active = true
        return false
    }
    function handleLoaded() {
        loaderLoading = false
        tasksLoaderActivate.startNextTask()
    }
    function doStopPreloadPages() {
        console.info("Deactivate preloaded pages.")
        stopRequested = false
        tasksLoaderActivate.stop()
        pageViewLoader.active = false
        rangeMModePageLoader.active = false
        settingsLoader.active = false
    }

}
