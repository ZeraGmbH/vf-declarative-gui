import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12
import VeinEntity 1.0
import ZeraLocale 1.0
import ZeraTranslation 1.0

ComboBox {
    id: root
    // external interface
    readonly property alias currentPath: privateKeeper.currentPath
    readonly property bool currentIsAutoMounted: model.length ? model[currentIndex].autoMount : false
    readonly property var mountedPaths: filesEntity ? filesEntity.AutoMountedPaths : []
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files") // can be overriden?
    // Depending on usage bind to Layout.minimumWidst or width
    property real contentMaxWidth: 0
    function resetFixedPaths() {
        fixedPathModelPrepend = []
        fixedPathModelAppend = []
    }
    function addFixedPath(pathDir, pathDirDisplay, prepend) {
        // here all paths are handled without trailing '/'
        if(pathDir.endsWith('/')) {
            pathDir = pathDir.substring(0, pathDir.length-1)
        }
        if(prepend) {
            fixedPathModelPrepend.push( { value: pathDir, driveLabelFixed: pathDirDisplay, autoMount: false })
        }
        else {
            fixedPathModelAppend.push( { value: pathDir, driveLabelFixed: pathDirDisplay, autoMount: false })
        }
        updateModelsAndStartRPCs()
    }
    Item {
        id: privateKeeper
        property string currentPath: "" // We want public currentPath readonly
    }
    property string unsetRequestedPath: ""
    onCurrentIndexChanged: {
        // we have to set currentPath once things stabilized
        if(!ignoreIndexChange && model.length) {
            privateKeeper.currentPath = model[currentIndex].value
        }
    }
    function selectPath(pathToSelect) {
        if(model.length > 0) {
            // forget previous select attempts
            unsetRequestedPath = ""
            // here all paths are handled without trailing '/'
            if(pathToSelect.endsWith('/')) {
                pathToSelect = pathToSelect.substring(0, pathToSelect.length-1)
            }
            for(var loopEntry=0; loopEntry<model.length; ++loopEntry) {
                if(model[loopEntry].value === pathToSelect) {
                    currentIndex = loopEntry
                    break
                }
            }
            privateKeeper.currentPath = model[currentIndex].value
        }
        else {
            // due to unpredicatable sequence on setup due to property
            // bindings selectPath can be called when there is no model
            // yet. So keep it for later use in fillAndSelectCombo
            unsetRequestedPath = pathToSelect
        }
    }

    // internals
    FontMetrics {
        id: fontMetrics
        font: root.font
    }

    textRole: "label"

    // model groups
    property var fixedPathModelPrepend: []
    property var mountedPathModel: []
    property var fixedPathModelAppend: []

    // rpc helpers
    property var modelIndexArrayToGetInfo: []
    property var rpcIdGetDriveInfo
    property int currPathToCheck: 0
    property bool ignorePendingRpc: false
    property bool fancyFlashRequired: false

    property var oldModel: []
    property var nextModel: []
    // combo's model with following properties
    // * value: full path used for identification purpose
    // * label: text displayed
    // * driveLabelFixed: drive label displayed for fixed entries
    // * autoMount: false: fixed path / true: set by mountedPaths (auto-mount)
    model: [] // init valid type
    property bool ignoreIndexChange: false

    // calc contentMaxWidth / nextModel -> model / (re)select
    function fillAndSelectCombo() {
        // calc combo's width
        var maxWidth = 0
        for(var idx=0; idx<nextModel.length; ++idx) {
            maxWidth = Math.max(maxWidth, fontMetrics.advanceWidth(nextModel[idx].label))
        }
        // do populate
        contentMaxWidth = maxWidth + 1.2*implicitHeight /* approx for button down */
        ignoreIndexChange = true
        model = nextModel
        ignoreIndexChange = false

        // (re-)select current
        var pathToSelect = unsetRequestedPath !== "" ? unsetRequestedPath : currentPath
        selectPath(pathToSelect)
    }

    function checkAvailInfoAndKeepRpcsToCall() { // nextModel pre-populated
        modelIndexArrayToGetInfo = []
        for(var nextLoopIdx=0; nextLoopIdx<nextModel.length; ++nextLoopIdx) {
            // fixed entry
            if(!nextModel[nextLoopIdx].autoMount) {
                // were fixed entries not yet set? TODO: this is VERY static
                if(!( "label" in nextModel[nextLoopIdx]) ) {
                    modelIndexArrayToGetInfo.push(nextLoopIdx)
                }
            }
            // automount entry
            else {
                var foundPathInOld = false
                var loopMountDir = nextModel[nextLoopIdx]
                // To avoid calling rpc more often than necessary, check whose device info we have already
                for(var oldLoopIdx=0; oldLoopIdx<oldModel.length; ++oldLoopIdx) {
                    if(loopMountDir === oldModel[oldLoopIdx].value) {
                        foundPathInOld = true
                        nextModel[nextLoopIdx].label = oldModel[oldLoopIdx].label
                        break
                    }
                }
                // automount entry is new - we no device info yet
                if(!foundPathInOld) {
                    modelIndexArrayToGetInfo.push(nextLoopIdx)
                }
            }
        }
    }

    function updateModelsAndStartRPCs() {
        // prepare model transition
        oldModel = model
        nextModel = [...fixedPathModelPrepend, ...mountedPathModel, fixedPathModelAppend]
        nextModel.pop()

        checkAvailInfoAndKeepRpcsToCall()

        // do we need to get device info
        var rpcRequired = modelIndexArrayToGetInfo.length
        if(rpcRequired) {
            callInfoRpc()
        }
        else {
            fillAndSelectCombo()
        }
        return !rpcRequired // true: all work is done
    }

    onMountedPathsChanged: {
        // refill mounted path model
        mountedPathModel = []
        if(mountedPaths.length) {
            for(var loopMount=0; loopMount<mountedPaths.length; ++loopMount) {
                mountedPathModel.push( { value: mountedPaths[loopMount], label: "", autoMount: true })
            }
        }

        fancyFlashRequired = true
        if(updateModelsAndStartRPCs()) {
            comboRipple.startFlash()
        }
    }

    // RPC_GetDriveInfo handling
    function callInfoRpc() {
        // Note: modelIndexArrayToGetInfo is assumed not empty
        if(!rpcIdGetDriveInfo) {
            currPathToCheck = modelIndexArrayToGetInfo.pop()
            var pathToGetInfo = nextModel[currPathToCheck].value
            rpcIdGetDriveInfo = filesEntity.invokeRPC("RPC_GetDriveInfo(QString p_localeName,QString p_mountDir)", {
                                               "p_mountDir": pathToGetInfo,
                                               "p_localeName": ZLocale.localeName})
        }
        else {
            ignorePendingRpc = true
        }
    }
    Connections {
        target: filesEntity
        onSigRPCFinished: {
            if(t_identifier === rpcIdGetDriveInfo) {
                rpcIdGetDriveInfo = undefined
                if(!ignorePendingRpc) {
                    var resultStringCount = t_resultData["RemoteProcedureData::resultCode"] === 0 ?
                                t_resultData["RemoteProcedureData::Return"].length : 0
                    var driveName = ""
                    var memTotal = ""
                    var memFree = ""
                    if(resultStringCount) { // valid response -> extract info
                        for(var loopResult=0; loopResult<resultStringCount; ++loopResult) {
                            var partialInfo = t_resultData["RemoteProcedureData::Return"][loopResult]
                            if(partialInfo.startsWith("name:")) {
                                driveName = partialInfo.replace("name:", "").trim()
                            }
                            else if(partialInfo.startsWith("total:")) {
                                memTotal = partialInfo.replace("total:", "").trim()
                            }
                            else if(partialInfo.startsWith("percent_free:")) {
                                memFree = partialInfo.replace("percent_free:", "").trim()
                            }
                        }
                    }
                    // build label from info
                    var label = ""
                    if(!nextModel[currPathToCheck].autoMount) {
                        label = nextModel[currPathToCheck].driveLabelFixed
                        if(label === "") {
                            label = driveName
                        }
                    }
                    else {
                        label = driveName
                    }
                    if(label === "") {
                        label = Z.tr("unnamed")
                    }
                    // append size info
                    if(memTotal !== "") {
                        label += " / " + memTotal
                    }
                    if(memFree !== "") {
                        label += " (" + memFree + " " + Z.tr("free") +")"
                    }
                    // set entry
                    nextModel[currPathToCheck].label = label
                }
                if(modelIndexArrayToGetInfo.length) { // more? -> start next
                    callInfoRpc()
                }
                else if(!ignorePendingRpc) { // no more && this was not a pending -> show
                    fillAndSelectCombo()
                    if(fancyFlashRequired) {
                        comboRipple.startFlash()
                    }
                }
                ignorePendingRpc = false
            }
        }
    }

    // flash effect for user notification
    Ripple {
        id: comboRipple
        function startFlash() {
            if(!ignoreFirstMountChange) {
                active = true
                comboRippleTimer.start()
            }
            ignoreFirstMountChange = false
            fancyFlashRequired = false
        }
        property bool ignoreFirstMountChange: true
        clipRadius: 2
        anchors.fill: parent
        anchor: root
        color: Material.highlightedRippleColor // Material.rippleColor
        Timer {
            id: comboRippleTimer
            interval: 700
            onTriggered: { comboRipple.active = false }
        }
    }
}
