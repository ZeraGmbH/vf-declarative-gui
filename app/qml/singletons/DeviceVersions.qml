pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0

Item {
    // Vein/JSON version lookup fields:
    // 1st: Text displayed in label
    // 2nd: JSON input field name
    readonly property var cpuVersions: {
        let versions = []
        let veinCpuInfo = VeinEntity.getEntity("StatusModule1")["INF_CpuInfo"]
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

    // private
    readonly property QtObject statusEnt: VeinEntity.getEntity("StatusModule1");
}
