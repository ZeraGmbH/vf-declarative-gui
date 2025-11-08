pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import AdjustmentState 1.0
import ZeraTranslation  1.0

Item {
    readonly property var allVersionsForDisplay: translateJson(allVersions)
    readonly property var allVersions: {
        let versions = []
        // TODO: Fix trailing ':' in translations
        versions.push(["Serial number", statusEntity["PAR_SerialNr"]])
        versions.push(["Operating system version", statusEntity["INF_ReleaseNr"]])
        pushArray(versions, pcbVersions)
        versions.push(["DSP firmware version", statusEntity["INF_DSPVersion"]])
        versions.push(["FPGA firmware version", statusEntity["INF_FPGAVersion"]])
        pushArray(versions, controllerVersions)
        pushArray(versions, veinChannelJsonToJsonObject())
        versions.push(["Adjustment status", AdjState.adjustmentStatusBare])
        pushArray(versions, cpuVersions)
        return versions
    }

    // private
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property var controllerVersions: veinJsonToJsonObject("INF_CTRLVersion") // Relais/System/EMOB µController
    readonly property var pcbVersions: veinJsonToJsonObject("INF_PCBVersion")         // Relais/System/EMOB PCB

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

    // Vein/JSON version lookup array fields:
    // 1st: Text displayed in label
    // 2nd: JSON input field name
    function veinJsonToJsonObject(componentName) {
        let versions = []
        let veinCpuInfo = statusEntity[componentName]
        if(veinCpuInfo !== "") {
            let jsonCpuInfo = JSON.parse(veinCpuInfo)
            for(let jsonEntry in jsonCpuInfo) {
                let value = jsonCpuInfo[jsonEntry]
                if (typeof value !== 'object') {
                    let item = [jsonEntry, jsonCpuInfo[jsonEntry]]
                    versions.push(item)
                }
            }
        }
        return versions
    }
    property var emobLabelsToTranslate: []
    readonly property var hotplugChannels: ["IL1", "IL2", "IL3", "IAUX"]
    function veinChannelJsonToJsonObject() {
        let versions = []
        let ctlVersion = JSON.parse(statusEntity["INF_CTRLVersion"])
        let pcbVersion = JSON.parse(statusEntity["INF_PCBVersion"])
        for (var hotIdx=0; hotIdx<hotplugChannels.length; ++hotIdx) {
            let hotplugChannel = hotplugChannels[hotIdx]
            let channelCtrl = ctlVersion[hotplugChannel]
            let channelPCB = pcbVersion[hotplugChannel]
            if (channelCtrl !== undefined || channelPCB !== undefined) {
                let channelAll = Object.assign({}, channelCtrl, channelPCB)
                for(let jsonEntry in channelAll) {
                    let value = channelAll[jsonEntry]
                    let item = [jsonEntry + " " + hotplugChannel, channelAll[jsonEntry]]
                    versions.push(item)
                    if (emobLabelsToTranslate.indexOf(jsonEntry) === -1)
                        emobLabelsToTranslate.push(jsonEntry)
                }
            }
        }
        return versions
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
            let translated = translateEmob(labelBare)
            if (translated === labelBare)
                translated = Z.tr(labelBare)
            let itemTr = [translated, value]
            versions.push(itemTr)
        }
        return versions
    }
    function translateEmob(label) {
        for(let idxLabel in emobLabelsToTranslate)
            label = label.replace(emobLabelsToTranslate[idxLabel], Z.tr(emobLabelsToTranslate[idxLabel]))
        for(let idxHot in hotplugChannels)
            label = label.replace(hotplugChannels[idxHot], Z.tr(hotplugChannels[idxHot]))
        return label
    }

    function pushArray(jsonVersionArray, arrPush) {
        for(let jsonEntry in arrPush) {
            let item = arrPush[jsonEntry]
            jsonVersionArray.push(item)
        }
    }
}
