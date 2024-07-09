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
        versions.push(["Adjustment status", AdjState.adjustmentStatusBare])
        pushArray(versions, cpuVersions)
        return versions
    }
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
                let item = [jsonEntry, jsonCpuInfo[jsonEntry]]
                versions.push(item)
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
