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
    readonly property var mountedPaths: filesEntity ? filesEntity.AutoMountedPaths : []
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files") // can be overriden?
    // Depending on usage bind to Layout.minimumWidst or width
    property real contentMaxWidth: 0

    function addFixedPath(pathDir, pathDirDisplay, prepend) {
        // here all paths are handled without trailing '/'
        if(pathDir.endsWith('/')) {
            pathDir = pathDir.substring(0, pathDir.length-1)
        }
        // start label/size RPC
        var rpcId = callRPCGetDriveInfo(pathDir)
        // add to nextModel
        if(prepend) {
            nextModel.splice(modelFixedPrependCount, 0, {value: pathDir, driveLabelFixed: pathDirDisplay, autoMount: false, rpcId: rpcId})
            modelFixedPrependCount++
        }
        else {
            nextModel.push({value: pathDir, driveLabelFixed: pathDirDisplay, autoMount: false, rpcId: rpcId})
        }
    }

    // internals
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
            // we have an unpredicatable sequence on setup due to property
            // bindings selectPath can be called when there is no model
            // yet. So keep it for later use in fillAndSelectCombo
            unsetRequestedPath = pathToSelect
        }
    }

    FontMetrics {
        id: fontMetrics
        font: root.font
    }

    // keep prepend entry count for more simple model add
    property int modelFixedPrependCount: 0

    // keep last mount to calc a proper diff
    property var mountedPathsLast: []

    // combo's ListModel with following properties
    // * value: full path used for identification purpose
    // * text: text displayed
    // * driveLabelFixed: drive name displayed for fixed entries
    // * autoMount: false: fixed path / true: set by mountedPaths (auto-mount)
    // * rpcId: Id of pending RPC

    // Important note:
    // Unlike ListView, ComboBox does not play well with ListModel: In case a
    // a property if textrole changes nothing happens
    model: []
    property var nextModel: []
    textRole: "text"

    Timer {
        id: currentVolumeSizePollTimer
        interval: 1000; repeat: true
        onTriggered: {
            if(currentPath !== "") {
                var currentVolIdx = indexOfValue(nextModel, currentPath)
                nextModel[currentVolIdx].rpcId = callRPCGetDriveInfo(currentPath)
            }
        }
    }

    property int rpcReturnsTillFancyFlash: 0
    property bool ignoreIndexChange: false

    onMountedPathsChanged: {
        // check for added mounts
        var addedMountPaths = [...mountedPaths] // we need a copy
        var pathIdx, pathToCheck, indexFound
        for(pathIdx=0; pathIdx<mountedPathsLast.length; ++pathIdx) {
            pathToCheck = mountedPathsLast[pathIdx]
            indexFound = addedMountPaths.indexOf(pathToCheck)
            if(indexFound >= 0) {
                // mount is not new -> remove it from addedMountPaths
                addedMountPaths.splice(indexFound, 1)
            }
        }
        // check for removed mounts
        var removedMountPaths = []
        for(pathIdx=0; pathIdx<mountedPathsLast.length; ++pathIdx) {
            pathToCheck = mountedPathsLast[pathIdx]
            indexFound = mountedPaths.indexOf(pathToCheck)
            if(indexFound < 0) {
                // mount is not found in mountedPaths any more -> mark as removed
                removedMountPaths.push(pathToCheck)
            }
        }
        // add new and start name/size RPCs
        for(pathIdx=0; pathIdx<addedMountPaths.length; pathIdx++) {
            var pathDir = addedMountPaths[pathIdx]
            // start info/size RPC
            var rpcId = callRPCGetDriveInfo(pathDir)
            // add to nextModel at the end of automount area
            nextModel.splice(modelFixedPrependCount + mountedPathsLast.length, 0, {value: pathDir, driveLabelFixed: "", autoMount: true, rpcId: rpcId})
        }
        // remove gone mounts
        var isRemovedPathSelected = false
        if(removedMountPaths.length > 0) {
            isRemovedPathSelected = removedMountPaths.indexOf(currentPath) >= 0
            for(pathIdx=0; pathIdx<removedMountPaths.length; ++pathIdx) {
                var delIndex = indexOfValue(nextModel, removedMountPaths[pathIdx])
                nextModel.splice(delIndex, 1)
            }
        }
        // keep for next time diff
        mountedPathsLast = [...mountedPaths]

        if(addedMountPaths.length > 0) {
            // notify user after all RPCs finished / final model update is done on RPC responses
            rpcReturnsTillFancyFlash = addedMountPaths.length
        }
        else if(removedMountPaths.length > 0) {
            // update current on empty
            if(mountedPaths.length === 0) {
                privateKeeper.currentPath = ""
            }
            // no mounts added just removed (=no RPC responses) -> we finish here
            if(isRemovedPathSelected && nextModel.length > 0) {
                // go back home
                unsetRequestedPath = nextModel[0].value
            }
            fillAndSelectCombo()
            comboRipple.startFlash()
        }
    }

    // indexOf kindof helpers - stolen from
    // https://stackoverflow.com/questions/7176908/how-to-get-index-of-object-by-its-property-in-javascript
    function indexOfRpcId(jsModel, rpcId) {
        return jsModel.map(function(e) { return e.rpcId }).indexOf(JSON.stringify(rpcId))
    }
    function indexOfValue(jsModel, value) {
        return jsModel.map(function(e) { return e.value }).indexOf(value)
    }

    function fillAndSelectCombo() {
        // update model
        ignoreIndexChange = true
        model = [...nextModel]
        ignoreIndexChange = false

        // recalc width
        var maxWidth = 0
        for(var idx=0; idx<nextModel.length; ++idx) {
            var text = nextModel[idx].text
            maxWidth = Math.max(maxWidth, fontMetrics.advanceWidth(text))
        }
        contentMaxWidth = maxWidth + 1.2*implicitHeight /* approx for button down */

        // (re-)select current
        var pathToSelect = unsetRequestedPath !== "" ? unsetRequestedPath : currentPath
        selectPath(pathToSelect)
    }

    // RPC_GetDriveInfo handling (uuids ar handled as strings for easier debugging - see also indexOfRpcId)
    function callRPCGetDriveInfo(pathToGetInfo) {
        return JSON.stringify(filesEntity.invokeRPC("RPC_GetDriveInfo(QString p_localeName,QString p_mountDir)", {
                                                    "p_mountDir": pathToGetInfo,
                                                    "p_localeName": ZLocale.localeName}))
    }
    Connections {
        target: filesEntity
        onSigRPCFinished: {
            var idxFound = indexOfRpcId(nextModel, t_identifier)
            if(idxFound >= 0) {
                // reset rpc id
                var listElemObj = nextModel[idxFound]
                listElemObj.rpcId = ""
                // for valid response -> extract fields
                var resultStringCount = t_resultData["RemoteProcedureData::resultCode"] === 0 ?
                            t_resultData["RemoteProcedureData::Return"].length : 0
                var driveName = ""
                var memTotal = ""
                var memFree = ""
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
                // build text from info
                var text = ""
                if(!nextModel[idxFound].autoMount) {
                    text = nextModel[idxFound].driveLabelFixed
                    if(text === "") {
                        text = driveName
                    }
                }
                else {
                    text = driveName
                }
                if(text === "") {
                    text = Z.tr("unnamed")
                }
                // append size info
                if(memTotal !== "") {
                    text += " / " + memTotal
                }
                if(memFree !== "") {
                    text += " (" + memFree + " " + Z.tr("free") +")"
                }
                // let's see
                nextModel[idxFound].text = text
                fillAndSelectCombo()
                if(rpcReturnsTillFancyFlash > 0 && --rpcReturnsTillFancyFlash === 0) {
                    comboRipple.startFlash()
                }
                // start size poll
                currentVolumeSizePollTimer.running = true
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
