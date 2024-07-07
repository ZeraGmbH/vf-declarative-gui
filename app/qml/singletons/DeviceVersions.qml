pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0

Item {
    readonly property var cpuVersions: { // Variscite
        let versions = []
        let veinCpuInfo = statusEntity["INF_CpuInfo"]
        if(veinCpuInfo !== "") {
            let dynVersionLookup = [
                [Z.tr("CPU-board number"),   "PartNumber"],
                [Z.tr("CPU-board assembly"), "Assembly"],
                [Z.tr("CPU-board date"),     "Date"],
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
    readonly property var controllerVersions: { // Relais/System/EMOB µController
        let versions = []
        let veinCpuInfo = statusEntity["INF_CTRLVersion"]
        if(veinCpuInfo !== "") {
            let jsonCpuInfo = JSON.parse(veinCpuInfo)
            for(let jsonEntry in jsonCpuInfo) {
                let item = [Z.tr(jsonEntry), jsonCpuInfo[jsonEntry]]
                versions.push(item)
            }
        }
        return versions
    }

    // private

    // Vein/JSON version lookup fields:
    // 1st: Text displayed in label
    // 2nd: JSON input field name
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
}
