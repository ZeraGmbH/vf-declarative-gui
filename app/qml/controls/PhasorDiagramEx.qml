import QtQuick 2.14
import QtQuick.Controls 2.14
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import ModuleIntrospection 1.0
import VectorDiagramQml 1.0
import ZeraTranslation 1.0
import ZeraThemeConfig 1.0

VectorDiagram {
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: Math.min(height * 1.2, parent.width)
    anchors.horizontalCenter: parent.horizontalCenter

    fillColor: color
    coordCrossColor: ZTC.frameColor;
    circleColor: ZTC.frameColor

    vectorStandard: GC.vectorStandard
    vectorType: GC.vectorType

    readonly property QtObject rangeInfo: VeinEntity.getEntity("RangeModule1")
    readonly property QtObject dftModule: VeinEntity.getEntity("DFTModule1")

    function getVectorName(vecIndex) {
        let strIndex = parseInt(vecIndex+1)
        return Z.tr(ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN" + strIndex].ChannelName)
    }

    property string maxURange: "5000V"
    readonly property real maxRejectionU: {
        let maxVal = 0;
        for(let channel=1; channel<=3; channel++) {
            let newVal = rangeInfo[`INF_Channel${channel}ActREJ`] / rangeInfo[`INF_PreScalingInfoGroup0`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxURange = rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }
    property string maxIRange: "10000A"
    readonly property real maxRejectionI: {
        let maxVal = 0;
        for(let channel=4; channel<=6; channel++) {
            let newVal = rangeInfo[`INF_Channel${channel}ActREJ`] / rangeInfo[`INF_PreScalingInfoGroup1`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxIRange = rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }

    vectorLabel0: getVectorName(0);
    vectorLabel1: getVectorName(1);
    vectorLabel2: getVectorName(2);
    vectorLabel3: getVectorName(3);
    vectorLabel4: getVectorName(4);
    vectorLabel5: getVectorName(5);

    vectorColor0: CS.colorUL1
    vectorColor1: CS.colorUL2
    vectorColor2: CS.colorUL3
    vectorColor3: CS.colorIL1
    vectorColor4: CS.colorIL2
    vectorColor5: CS.colorIL3
}
