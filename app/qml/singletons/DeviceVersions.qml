pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0

Item {
    property var dynVersions: []

    readonly property QtObject statusEnt: VeinEntity.getEntity("StatusModule1");
    readonly property bool hasCpuInfo: statusEnt.hasComponent("INF_CpuInfo")
    onHasCpuInfoChanged: {
        if(hasCpuInfo) {
            appendDynVersions(VeinEntity.getEntity("StatusModule1")["INF_CpuInfo"])
        }
    }

    function appendDynVersions(strJsonCpuInfo) {
        // Vein/JSON version lookup fields:
        // 1st: Text displayed in label
        // 2nd: JSON input field name
        let dynVersionLookup = [
            [Z.tr("CPU-board number"),   "PartNumber"],
            [Z.tr("CPU-board assembly"),  "Assembly"],
            [Z.tr("CPU-board date"),    "Date"],
        ];
        // 1st: Text displayed in label
        // 2nd: version
        if(strJsonCpuInfo !== "") {
            let jsonCpuInfo = JSON.parse(strJsonCpuInfo)
            for(let lookupItem=0; lookupItem < dynVersionLookup.length; lookupItem++) {
                let jsonVerName = dynVersionLookup[lookupItem][1]
                if(jsonVerName in jsonCpuInfo) {
                    let item = [dynVersionLookup[lookupItem][0], jsonCpuInfo[jsonVerName]]
                    dynVersions.push(item)
                }
            }
        }
    }

}
