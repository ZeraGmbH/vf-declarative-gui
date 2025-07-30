import QtQuick 2.14
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0
import ZeraThemeConfig 1.0
import '../controls'

Item {
    id: root

    readonly property QtObject dftModule: VeinEntity.getEntity("DFTModule1")
    readonly property QtObject rangeInfo: VeinEntity.getEntity("RangeModule1")

    property int viewMode : PhasorDiagram.VIEW_STAR;
    readonly property bool threePhase: viewMode === PhasorDiagram.VIEW_THREE_PHASE

    readonly property real pointSize: Math.max(10, height / 28)
    readonly property real horizMarign: width*0.005
    readonly property real comboWidth: width/7
    readonly property real comboMargin: 8
    property real topMargin: 0

    readonly property var vector0: getVector(0)
    readonly property var vector1: getVector(1)
    readonly property var vector2: getVector(2)
    readonly property var vector3: getVector(3)
    readonly property var vector4: getVector(4)
    readonly property var vector5: getVector(5)

    readonly property var vectorU1 : vector0 !== undefined ? vector0 : [0,0]
    readonly property var vectorU2 : vector1 !== undefined ? vector1 : [0,0]
    readonly property var vectorU3 : vector2 !== undefined ? vector2 : [0,0]
    readonly property real rmsU1: Math.sqrt(Math.pow(vectorU1[0], 2) + Math.pow(vectorU1[1], 2))
    readonly property real rmsU2: Math.sqrt(Math.pow(vectorU2[0], 2) + Math.pow(vectorU2[1], 2))
    readonly property real rmsU3: Math.sqrt(Math.pow(vectorU3[0], 2) + Math.pow(vectorU3[1], 2))
    readonly property real maxRmsU: Math.max(rmsU1, Math.max(rmsU2, rmsU3))

    readonly property var vectorI1 : vector3 !== undefined ? vector3 : [0,0]
    readonly property var vectorI2 : vector4 !== undefined ? vector4 : [0,0]
    readonly property var vectorI3 : vector5 !== undefined ? vector5 : [0,0]
    readonly property real rmsI1: Math.sqrt(Math.pow(vectorI1[0], 2) + Math.pow(vectorI1[1], 2))
    readonly property real rmsI2: Math.sqrt(Math.pow(vectorI2[0], 2) + Math.pow(vectorI2[1], 2))
    readonly property real rmsI3: Math.sqrt(Math.pow(vectorI3[0], 2) + Math.pow(vectorI3[1], 2))
    readonly property real maxRmsI: Math.max(rmsI1, Math.max(rmsI2, rmsI3))

    // vector & range helpers
    function getVectorName(vecIndex) {
        let strIndex = parseInt(vecIndex+1)
        let retVal = Z.tr(ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN" + strIndex].ChannelName)
        if(threePhase) { // unlikely - a must hate :)
            if(vecIndex < 3) {
                retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPP" + strIndex].ChannelName;
                let arrPhases = retVal.split('-')
                if(arrPhases.length === 2)
                    retVal = Z.tr(arrPhases[0]) + '-' + Z.tr(arrPhases[1])
            }
            else
                retVal = Z.tr(ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN" + strIndex].ChannelName)
        }
        return retVal
    }
    function getVector(vecIndex) {
        let strIndex = parseInt(vecIndex+1)
        let retVal = dftModule["ACT_DFTPN" + strIndex];
        if(threePhase) { // unlikely - a must hate :)
            switch(vecIndex)
            {
            case 0:
            case 1:
                retVal= dftModule["ACT_DFTPP" + strIndex];
                break;
            case 3:
            case 5:
                retVal = dftModule["ACT_DFTPN" + strIndex];
                break;
            case 2:
            case 4:
                retVal=[0,0];
                break;
            }
        }
        return retVal
    }
    property string maxURange: "5000V"
    readonly property real maxOVRRejectionU: {
        let maxVal = 0;
        for(let channel=1; channel<=3; channel++) {
            let newVal = rangeInfo[`INF_Channel${channel}ActOVLREJ`] / rangeInfo[`INF_PreScalingInfoGroup0`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxURange = rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }
    property string maxIRange: "10000A"
    readonly property real maxOVRRejectionI: {
        let maxVal = 0;
        for(let channel=4; channel<=6; channel++) {
            let newVal = rangeInfo[`INF_Channel${channel}ActOVLREJ`] / rangeInfo[`INF_PreScalingInfoGroup1`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxIRange = rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }

    PhasorDiagramEx {
        id: phasorDiagram
        anchors.topMargin: root.topMargin

        vectorView: viewMode

        vectorData0: vectorU1
        vectorData1: vectorU2
        vectorData2: vectorU3
        vectorData3: vectorI1
        vectorData4: vectorI2
        vectorData5: vectorI3

        vectorLabel0: getVectorName(0);
        vectorLabel1: getVectorName(1);
        vectorLabel2: getVectorName(2);
        vectorLabel3: getVectorName(3);
        vectorLabel4: getVectorName(4);
        vectorLabel5: getVectorName(5);

        maxVoltage: {
            let rangeMax = maxOVRRejectionU * Math.SQRT2
            let max = rangeMax
            if(!lenMode.rangeLen) {
                max = maxRmsU * maxNominalFactor / (threePhase ? sqrt3 : 1)
                // avoid no load arrow dance
                let minValue = rangeMax > 1 ? rangeMax*minRelValueDisplayed * 0.1 : rangeMax*minRelValueDisplayed
                if(maxRmsU < minValue)
                    max = rangeMax
            }
            return max
        }
        maxCurrent: {
            let rangeMax = maxOVRRejectionI * Math.SQRT2
            let max = rangeMax
            if(!lenMode.rangeLen) {
                max = maxRmsI * maxNominalFactor
                // avoid no load arrow dance
                let minValue = rangeMax > 1 ? rangeMax*minRelValueDisplayed * 0.1 : rangeMax*minRelValueDisplayed
                if(maxRmsI < minValue)
                    max = rangeMax
            }
            return max
        }
    }

    // bottom left voltage/current circle value indicator
    Image {
        id: circleIndicator
        anchors.bottom: root.bottom;
        anchors.bottomMargin: GC.standardTextBottomMargin
        anchors.left: root.left
        anchors.leftMargin: horizMarign
        source: ZTC.isDarkTheme ?
                    "qrc:/data/staticdata/resources/radius-large.svg" :
                    "qrc:/data/staticdata/resources/radius-large-for-light-theme.svg"
        height: pointSize * 3
        mipmap: true
        antialiasing: true
        fillMode: Image.PreserveAspectFit
    }
    Label {
        id: voltageIndicator
        readonly property string valueStr: {
            if(lenMode.rangeLen && !threePhase)
                return maxURange
            let maxVoltage = phasorDiagram.maxVoltage
            if(threePhase)
                maxVoltage *= phasorDiagram.sqrt3
            // factor 1000: Our auto scale scales too late - it was designed for values rising monotonous
            let valUnitArr = FT.doAutoScale(maxVoltage / (1000*phasorDiagram.maxNominalFactor * Math.SQRT2), "V")
            return FT.formatNumberForScaledValues(valUnitArr[0]*1000, lenMode.rangeLen ? 0 : undefined) + valUnitArr[1]
        }
        text: "<font color='" + CS.colorUL1 + "'>"+ "U: " + valueStr + " * √2" + "</font>"
        anchors.bottom: currentIndicator.top
        height: circleIndicator.height * 0.5
        anchors.bottomMargin: circleIndicator.height * 0.2
        anchors.left: circleIndicator.right
        anchors.leftMargin: horizMarign
        horizontalAlignment: Label.AlignLeft
        font.pointSize: pointSize / 1.25
    }
    Label {
        id: currentIndicator
        readonly property string valueStr: {
            if(lenMode.rangeLen)
                return maxIRange
            // factor 1000: Our auto scale scales too late - it was designed for values rising monotonous
            let valUnitArr = FT.doAutoScale(phasorDiagram.maxCurrent / (1000 * phasorDiagram.maxNominalFactor * Math.SQRT2), "A")
            return FT.formatNumberForScaledValues(valUnitArr[0]*1000, lenMode.rangeLen ? 0 : undefined) + valUnitArr[1]
        }
        text: "<font color='" + CS.colorIL1 + "'>"+ "I: " + valueStr + " * √2" + "</font>"
        anchors.bottom: root.bottom
        height: circleIndicator.height * 0.5
        anchors.bottomMargin: GC.standardTextBottomMargin * 1.2
        anchors.left: circleIndicator.right
        anchors.leftMargin: horizMarign
        horizontalAlignment: Label.AlignLeft
        font.pointSize: pointSize / 1.25
    }

    // bottom right comboboxes
    Label {
        text: "➚"
        anchors.right: viewModeSelector.left
        anchors.verticalCenter: viewModeSelector.verticalCenter
        anchors.rightMargin: GC.standardTextHorizMargin
        font.pointSize: pointSize * 1.5
    }
    ZComboBox {
        id: viewModeSelector
        arrayMode: true
        model: ["U  PN", "U  △", "U  ∠"]

        targetIndex: GC.vectorMode
        onTargetIndexChanged: {
            viewMode = targetIndex
            GC.setVectorMode(targetIndex)
        }

        anchors.bottomMargin: comboMargin
        anchors.bottom: dinIECSelector.top;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
    }

    Label {
        text: "➚"
        anchors.right: dinIECSelector.left
        anchors.verticalCenter: dinIECSelector.verticalCenter
        anchors.rightMargin: GC.standardTextHorizMargin
        font.pointSize: pointSize * 1.5
    }
    ZComboBox {
        id: dinIECSelector
        arrayMode: true
        model: ["DIN410", "IEC387"]

        anchors.bottom: lenMode.top
        anchors.bottomMargin: comboMargin
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth

        targetIndex: GC.vectorIecMode
        onTargetIndexChanged: {
            phasorDiagram.din410 = targetIndex == 0
            GC.setVectorIecMode(targetIndex)
        }
    }

    Image {
        anchors.right: lenMode.left
        anchors.verticalCenter: lenMode.verticalCenter
        anchors.rightMargin: GC.standardTextHorizMargin
        source: ZTC.isDarkTheme ?
                    "qrc:/data/staticdata/resources/radius.svg" :
                    "qrc:/data/staticdata/resources/radius-for-light-theme.svg"
        height: pointSize * 1.75
        mipmap: true
        antialiasing: true
        fillMode: Image.PreserveAspectFit
    }
    ZComboBox {
        id: lenMode
        arrayMode: true
        model: [Z.tr("Ranges"), Z.tr("Maximum")]

        anchors.bottomMargin: 12
        anchors.bottom: parent.bottom;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth

        targetIndex: GC.vectorCircleMode
        onTargetIndexChanged: {
            GC.setVectorCircleMode(targetIndex)
        }

        property bool rangeLen: targetIndex===0
    }
}
