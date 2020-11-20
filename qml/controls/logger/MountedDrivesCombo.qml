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
    readonly property var mountedPaths: filesEntity ? filesEntity.AutoMountedPaths : []
    /* currentValue does not work even when forcing QtQuickControls 2.14 */
    readonly property string currentPath: model.length ? model[currentIndex].value : ""
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files") // can be overriden?
    // Depending on usage bind to Layout.minimumWidst or width
    property real contentMaxWidth: 0
    function resetExtraPaths() {
        extraPathModelPrepend = []
        extraPathModelAppend = []
    }
    function addExtraPath(pathDir, pathDirDisplay, prepend) {
        if(prepend) {
            extraPathModelPrepend.push( { value: pathDir, labelRaw: pathDirDisplay })
        }
        else {
            extraPathModelAppend.push( { value: pathDir, labelRaw: pathDirDisplay })
        }
        updateModelsAndStartRPCs()
    }
    function selectPath(pathToSelect) {
        if(model.length > 0) {
            for(var loopEntry=0; loopEntry<model.length; ++loopEntry) {
                if(model[loopEntry].value === pathToSelect) {
                    currentIndex = loopEntry
                    return true
                }
            }
        }
        else {
            // due to unpredicatable sequence on setup due to property
            // bindings selectPath can be called when there is no model
            // yet. So keep it for later use in fillAndSelectCombo
            unsetRequestedPath = pathToSelect
        }
        return false
    }

    // internals
    FontMetrics {
        id: fontMetrics
        font: root.font
    }

    property string unsetRequestedPath

    valueRole: "value"
    textRole: "label"

    // model groups
    property var extraPathModelPrepend: []
    property var mountedPathModel: []
    property var extraPathModelAppend: []

    // rpc helpers
    property var modelIndexArrayToGetInfo: []
    property var rpcIdGetDriveInfo
    property int currPathToCheck: 0
    property bool ignorePendingRpc: false
    property bool fancyFlashRequired: false

    property var oldModel: []
    property var nextModel: []
    model: [] // init valid type

    // calc contentMaxWidth / nextModel -> model / (re)select
    function fillAndSelectCombo() {
        var maxWidth = 0
        var newIndex = -1
        var currModelEntry
        for(var idx=0; idx<nextModel.length; ++idx) {
            currModelEntry = nextModel[idx]
            maxWidth = Math.max(maxWidth, fontMetrics.advanceWidth(currModelEntry.label))
            if(currModelEntry.value === currentPath ) {
                newIndex = idx
            }
        }
        // do populate
        contentMaxWidth = maxWidth + 1.2*implicitHeight /* approx for button down */
        model = nextModel
        // (re-)select entry
        if(unsetRequestedPath === "") {
            if(newIndex >= 0) {
                currentIndex = newIndex
            }
            else {
                currentIndex = 0
            }
        }
        else {
            var tmpPath = unsetRequestedPath
            unsetRequestedPath = ""
            selectPath(tmpPath)
        }
    }

    function checkAvailInfoAndKeepRpcsToCall() { // nextModel pre-populated
        modelIndexArrayToGetInfo = []
        for(var nextLoopIdx=0; nextLoopIdx<nextModel.length; ++nextLoopIdx) {
            // extra entry
            if("labelRaw" in nextModel[nextLoopIdx]) {
                // were extra entries not yet set?
                if(!( "label" in nextModel[nextLoopIdx]) ) {
                    modelIndexArrayToGetInfo.push(nextLoopIdx)
                }
            }
            // mount entry
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
                // mount entry is new - we no device info yet
                if(!foundPathInOld) {
                    modelIndexArrayToGetInfo.push(nextLoopIdx)
                }
            }
        }
    }

    function updateModelsAndStartRPCs() {
        // prepare model transition
        oldModel = model
        nextModel = []
        var idx
        for(idx=0; idx<extraPathModelPrepend; ++idx) {
            nextModel.push(extraPathModelPrepend[idx])
        }
        for(idx=0; idx<mountedPathModel; ++idx) {
            nextModel.push(mountedPathModel[idx])
        }
        for(idx=0; idx<extraPathModelAppend; ++idx) {
            nextModel.push(extraPathModelAppend[idx])
        }

        nextModel = [...extraPathModelPrepend, ...mountedPathModel, extraPathModelAppend]
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
                mountedPathModel.push( { value: mountedPaths[loopMount], label: "" })
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
            rpcIdGetDriveInfo = filesEntity.invokeRPC("RPC_GetDriveInfo(bool p_getDriveName,bool p_getMemAvail,bool p_getMemTotal,QString p_localeName,QString p_mountDir)", {
                                               "p_mountDir": pathToGetInfo,
                                               "p_localeName": ZLocale.localeName,
                                               "p_getDriveName": true,
                                               "p_getMemTotal": true,
                                               "p_getMemAvail": false})
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
                    if(resultStringCount) { // valid response -> extract info
                        for(var loopResult=0; loopResult<resultStringCount; ++loopResult) {
                            var partialInfo = t_resultData["RemoteProcedureData::Return"][loopResult]
                            if(partialInfo.startsWith("name:")) {
                                driveName = partialInfo.replace("name:", "").trim()
                            }
                            else if(partialInfo.startsWith("total:")) {
                                memTotal = partialInfo.replace("total:", "").trim()
                            }
                        }
                    }
                    // build label from info
                    var label = ""
                    if("labelRaw" in nextModel[currPathToCheck]) { // extra entry
                        label = nextModel[currPathToCheck].labelRaw
                    }
                    else { // mount entry
                        if(driveName !== "") {
                            label = driveName
                        }
                    }
                    if(memTotal !== "") {
                        if(label !== "") {
                            label += " / " + memTotal
                        }
                        else {
                            label = Z.tr("unnamed") + " / " + memTotal
                        }
                    }
                    // set entry
                    if(label !== "") {
                        nextModel[currPathToCheck].label = label
                    }
                    else {
                        // fallback to paths to avoid empty combo entries
                        nextModel[currPathToCheck].label = nextModel[currPathToCheck].value
                    }
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
