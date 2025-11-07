pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import AdjustmentState 1.0
import ZeraTranslation  1.0

Item {
    readonly property var allVersionsForDisplay: translateJson(allVersions)
    readonly property var allVersionsForStore: {
        let versions = {}
        for(let entry = 0; entry < allVersions.length; entry++) {
            let label = allVersions[entry][0]
            let value = allVersions[entry][1]
            versions[label] = value
        }
        return versions
    }

    // private
    readonly property var allVersions: {
        let versions = []
        // TODO: Fix trailing ':' in translations
        versions.push(["Serial number", statusEntity["PAR_SerialNr"]])
        versions.push(["Operating system version", statusEntity["INF_ReleaseNr"]])
        pushArray(versions, pcbVersions)
        versions.push(["DSP firmware version", statusEntity["INF_DSPVersion"]])
        versions.push(["FPGA firmware version", statusEntity["INF_FPGAVersion"]])
        pushArray(versions, controllerVersions)
        pushArray(versions, pushHotplug())
        versions.push(["Adjustment status", AdjState.adjustmentStatusBare])
        pushArray(versions, cpuVersions)
        return versions
    }
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property var channels: ["IL1", "IL2", "IL3", "IAUX"]
    property var hotplugObject: ({})
    readonly property var controllerVersions: veinJsonToJsonObject("INF_CTRLVersion")   // Relais/System/EMOB µController
    readonly property var pcbVersions: veinJsonToJsonObject("INF_PCBVersion") // Relais/System/EMOB PCB

    function extractHotplugData(channel, object) {
        if (hotplugObject.hasOwnProperty(channel))
            Object.assign(hotplugObject[channel], object)
        else
            hotplugObject[channel] = object
    }

    function pushHotplug() {
        let versions = []
        let keys = Object.keys(hotplugObject)
        for(var i = 0; i<keys.length; i++) {
            let key = keys[i]
            let value = hotplugObject[key]
            versions.push([key, ""])
            pushArray(versions, extractChannelVersions(value))
        }
        return versions;
    }

    function extractChannelVersions(object) {
        let arr = []
        let keys = Object.keys(object)
        for(var i = 0; i<keys.length; i++) {
            let key = keys[i]
            let value = object[key]
            arr.push([key, value])
        }
        return arr
    }


    readonly property var cpuVersions: {                                              // Variscite SOM
        let versions = []
        let veinCpuInfo = statusEntity["INF_CpuInfo"]
        if(veinCpuInfo !== "") {
            let dynVersionLookup = [
                ["CPU-board date",     "Date"],
                ["CPU-board number",   "PartNumber"],
                ["CPU-board assembly", "Assembly"],
            ]
            let jsonCpuInfo = JSON.parse(veinCpuInfo)
            for(let lookupItem=0; lookupItem < dynVersionLookup.length; lookupItem++) {
                let jsonVerName = dynVersionLookup[lookupItem][1]
                if(jsonVerName in jsonCpuInfo) {
                    let item = [dynVersionLookup[lookupItem][0], jsonCpuInfo[jsonVerName]]
                    versions.push(item)
                }
            }
        }
        return versions
    }

    function veinJsonToJsonObject(componentName) {
        let versions = []
        let veinVersion = statusEntity[componentName]
        if(veinVersion !== "") {
            let versionObject = JSON.parse(veinVersion)
            let keys = Object.keys(versionObject)
            for(var i = 0; i<keys.length; i++) {
                let key = keys[i]
                let value = versionObject[key]
                if(channels.includes(key))
                    extractHotplugData(key, value)
                else
                    versions.push([key, value])
            }
        }
        return versions;
    }
    function translateJson(jsonVersionArray) {
        let versions = []
        for(let jsonEntry in jsonVersionArray) {
            let item = jsonVersionArray[jsonEntry]
            let labelBare = item[0]
            let value
            if(labelBare !== "Adjustment status")
                value = item[1]
            else
                value = AdjState.adjustmentStatusDisplay
            let itemTr = [Z.tr(labelBare), value]
            versions.push(itemTr)
        }
        return versions
    }
    function pushArray(jsonVersionArray, arrPush) {
        for(let jsonEntry in arrPush) {
            let item = arrPush[jsonEntry]
            jsonVersionArray.push(item)
        }
    }
}
