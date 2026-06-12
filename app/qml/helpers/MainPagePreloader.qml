import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0

Item {
    // public
    function startPreloadPages() {
        stopRequested = false
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
            {
                'type': 'block',
                'callFunction': () => {
                    initPageLoaders()
                    return true
                }
            },
            {   // settingsLoader takes longest => load it first
                'type': 'block',
                'callFunction': () => { return tryActivatePageLoader(settingsLoader, "SettingsPage") }
            },
            {
                'type': 'block',
                'callFunction': () => { return tryActivatePageLoader(rangeMModePageLoader, "RangeMModePage") }
            },
            {
                'type': 'block',
                'callFunction': () => { return tryActivatePageLoader(pageViewLoader, "PageView") }
            },
            {
                'type': 'block',
                'callFunction': () => {
                    console.info("All on demand pages preloaded.")
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
    function initPageLoaders() {
        console.info("Establish temporary fallback to open pages before loaded.")
        bindPageLoaderForShowBeforeActivate(pageViewLoader)
        bindPageLoaderForShowBeforeActivate(rangeMModePageLoader)
        bindPageLoaderForShowBeforeActivate(settingsLoader)
    }
    function bindPageLoaderForShowBeforeActivate(pageLoader) {
        // ensure user show request is handled before preload finished - binding will be broken
        pageLoader.active = Qt.binding(function() { return pageLoader.pageVisible })
    }
    function tryActivatePageLoader(loader, loaderLoggedName) {
        if (stopRequested) {
            Qt.callLater(doStopPreloadPages)
            return false
        }
        return doActivatePageLoader(loader, loaderLoggedName)
    }
    function doActivatePageLoader(loader, loaderLoggedName) {
        if (loader.status === Loader.Ready) {
            console.info(loaderLoggedName + " is already loaded - continue with next.")
            return true
        }
        console.info("Preload " + loaderLoggedName + "...")
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
