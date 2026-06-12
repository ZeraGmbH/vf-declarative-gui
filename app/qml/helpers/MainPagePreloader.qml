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

    // Why is the code in here so complicated:
    // We have:
    // * Deactivating loaders during session change accelerates session change significantly => we want that
    // * ATOW qtdeclarative (5.14) can cause crashers unloading unfished async loaders. Attempts to backport
    //   patches failed whole system with later versions is a huge task...
    // * autobuilder-dut-testsuite hammers session change at high rate by SCPI => sporadic crashers
    //
    // => The workaround is to avoid decativation of loaders which have not finished loading by waiting on
    //    activation/loading to finish before starting deactivation

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
