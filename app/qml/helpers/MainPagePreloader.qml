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
                'type': 'unblock',
                'callFunction': () => tryActivatePageLoader(settingsLoader, "SettingsPage")
            },
            {
                'type': 'unblock',
                'callFunction': () => tryActivatePageLoader(rangeMModePageLoader, "RangeMModePage")
            },
            {
                'type': 'unblock',
                'callFunction': () => tryActivatePageLoader(pageViewLoader, "PageView")
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
    // * ATTOW qtdeclarative (5.14) can cause crashers unloading unfished async loaders. Attempts to backport
    //   patches failed / whole system update with later versions is a huge task...
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
        if (stopRequested)
            Qt.callLater(doStopPreloadPages)
        doActivatePageLoader(loader, loaderLoggedName)
    }
    function doActivatePageLoader(loader, loaderLoggedName) {
        if (loader.status === Loader.Ready) {
            console.info(loaderLoggedName + " is already loaded - continue with next.")
            tasksLoaderActivate.startNextTask()
        }
        else {
            console.info("Preload " + loaderLoggedName + "...")
            loaderLoading = true
            loader.active = true
        }
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
