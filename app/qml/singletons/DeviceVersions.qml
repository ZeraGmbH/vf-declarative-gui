pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0

Item {
    readonly property var controllerVersions: veinJsonToJsonObject("INF_CTRLVersion") // Relais/System/EMOB µController
    readonly property var pcbVersions: veinJsonToJsonObject("INF_PCBVersion")         // Relais/System/EMOB PCB
    readonly property var cpuVersions: {                                              // Variscite SOM
        let versions = []
        let veinCpuInfo = statusEntity["INF_CpuInfo"]
        if(veinCpuInfo !== "") {
            let dynVersionLookup = [
                ["CPU-board number",   "PartNumber"],
                ["CPU-board assembly", "Assembly"],
                ["CPU-board date",     "Date"],
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
    // localized
    readonly property var controllerVersionsTr: translateJson(controllerVersions)
    readonly property var pcbVersionsTr: translateJson(pcbVersions)
    readonly property var cpuVersionsTr: translateJson(cpuVersions)

    // private
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
            let itemTr = [Z.tr(item[0]), item[1]]
            versions.push(itemTr)
        }
        return versions
    }
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
}
