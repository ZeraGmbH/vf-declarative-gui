import QtQuick 2.14
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0
import '../controls'

Item {
    id: root

    readonly property QtObject dftModule: VeinEntity.getEntity("DFTModule1")
    readonly property QtObject rangeInfo: VeinEntity.getEntity("RangeModule1")

    property int viewMode : PhasorDiagram.VIEW_STAR;

    readonly property real pointSize: Math.max(10, height / 28)
    readonly property real horizMarign: 10
    readonly property real comboWidth: width/7
    readonly property real comboMargin: 8

    readonly property bool threePhase: viewMode===PhasorDiagram.VIEW_THREE_PHASE

    readonly property var vectorU1 : getVector(0)
    readonly property var vectorU2 : getVector(1)
    readonly property var vectorU3 : getVector(2)
    readonly property real rmsU1: Math.sqrt(Math.pow(vectorU1[0], 2) + Math.pow(vectorU1[1], 2))
    readonly property real rmsU2: Math.sqrt(Math.pow(vectorU2[0], 2) + Math.pow(vectorU2[1], 2))
    readonly property real rmsU3: Math.sqrt(Math.pow(vectorU3[0], 2) + Math.pow(vectorU3[1], 2))
    readonly property real maxRmsU: {
        let retVal = rmsU1
        retVal = Math.max(retVal, rmsU2)
        retVal = Math.max(retVal, rmsU3)
        return retVal
    }

    readonly property var vectorI1 : getVector(3)
    readonly property var vectorI2 : getVector(4)
    readonly property var vectorI3 : getVector(5)
    readonly property real rmsI1: Math.sqrt(Math.pow(vectorI1[0], 2) + Math.pow(vectorI1[1], 2))
    readonly property real rmsI2: Math.sqrt(Math.pow(vectorI2[0], 2) + Math.pow(vectorI2[1], 2))
    readonly property real rmsI3: Math.sqrt(Math.pow(vectorI3[0], 2) + Math.pow(vectorI3[1], 2))
    readonly property real maxRmsI: {
        let retVal = rmsI1
        retVal = Math.max(retVal, rmsI2)
        retVal = Math.max(retVal, rmsI3)
        return retVal
    }

    property real topMargin: 0

    // vectors / values / ranges....

    function getVectorName(vecIndex) {
        var retVal;
        if(threePhase) {
            if(vecIndex < 3) {
                retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPP"+parseInt(vecIndex+1)].ChannelName;
                let arrPhases = retVal.split('-')
                if(arrPhases.length === 2) {
                    retVal = Z.tr(arrPhases[0]) + '-' + Z.tr(arrPhases[1])
                }
            }
            else
                retVal = Z.tr(ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN"+parseInt(vecIndex+1)].ChannelName)
        }
        else
            retVal = Z.tr(ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN"+parseInt(vecIndex+1)].ChannelName)
        return retVal
    }
    function getVector(vecIndex) {
        var retVal = [0,0];
        if(threePhase) {
            switch(vecIndex)
            {
            case 0:
            case 1:
                retVal=root.dftModule["ACT_DFTPP"+parseInt(vecIndex+1)];
                break;
            case 3:
            case 5:
                retVal=root.dftModule["ACT_DFTPN"+parseInt(vecIndex+1)];
                break;
            case 2:
            case 4:
                retVal=[0,0];
                break;
            }
        }
        else
            retVal = root.dftModule["ACT_DFTPN" + parseInt(vecIndex+1)];
        return retVal
    }
    property string maxURange: "5000V"
    readonly property real maxOVRRejectionU: {
        let maxVal = 0;
        for(let channel=1; channel<=3; channel++) {
            let newVal = root.rangeInfo[`INF_Channel${channel}ActOVLREJ`]/root.rangeInfo[`INF_PreScalingInfoGroup0`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxURange = root.rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }
    property string maxIRange: "10000A"
    readonly property real maxOVRRejectionI: {
        let maxVal = 0;
        for(let channel=4; channel<=6; channel++) {
            let newVal = root.rangeInfo[`INF_Channel${channel}ActOVLREJ`]/root.rangeInfo[`INF_PreScalingInfoGroup1`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxIRange = root.rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }

    Image {
        id: circleIndicator
        anchors.bottom: root.bottom;
        anchors.bottomMargin: GC.standardTextBottomMargin
        anchors.left: root.left
        anchors.leftMargin: horizMarign
        source: "qrc:/data/staticdata/resources/radius-large.svg"
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
            return FT.formatNumber(valUnitArr[0]*1000, lenMode.rangeLen ? 0 : undefined) + valUnitArr[1]
        }
        text: "<font color='" + GC.groupColorVoltage + "'>"+ "U: " + valueStr + " * √2" + "</font>"
        anchors.bottom: currentIndicator.top
        anchors.bottomMargin: GC.standardTextBottomMargin
        anchors.left: circleIndicator.right
        anchors.leftMargin: horizMarign
        font.pointSize: pointSize / 1.25
    }
    Label {
        id: currentIndicator
        readonly property string valueStr: {
            if(lenMode.rangeLen) {
                return maxIRange
            }
            // factor 1000: Our auto scale scales too late - it was designed for values rising monotonous
            let valUnitArr = FT.doAutoScale(phasorDiagram.maxCurrent / (1000 * phasorDiagram.maxNominalFactor * Math.SQRT2), "A")
            return FT.formatNumber(valUnitArr[0]*1000, lenMode.rangeLen ? 0 : undefined) + valUnitArr[1]
        }
        text: "<font color='" + GC.groupColorCurrent + "'>"+ "I: " + valueStr + " * √2" + "</font>"
        anchors.bottom: root.bottom;
        anchors.bottomMargin: GC.standardTextBottomMargin
        anchors.left: circleIndicator.right
        anchors.leftMargin: horizMarign
        font.pointSize: pointSize / 1.25
    }

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
            root.viewMode = targetIndex
            GC.setVectorMode(targetIndex)
        }

        anchors.bottomMargin: comboMargin
        anchors.bottom: currentOnOffSelector.top;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
    }

    Label {
        text: "➚"
        anchors.right: currentOnOffSelector.left
        anchors.verticalCenter: currentOnOffSelector.verticalCenter
        anchors.rightMargin: GC.standardTextHorizMargin
        font.pointSize: pointSize * 1.5
    }
    ZComboBox {
        id: currentOnOffSelector
        arrayMode: true
        model: ["I  "+Z.tr("On"), "I  "+Z.tr("Off")]

        anchors.bottomMargin: comboMargin
        anchors.bottom: dinIECSelector.top;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
        targetIndex: GC.vectorShowI ? 0 : 1
        onTargetIndexChanged: {
            GC.setVectorShowI(targetIndex == 0)
        }

        readonly property bool displayCurrents: targetIndex===0
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
        source: "qrc:/data/staticdata/resources/radius.svg"
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
        centerVertical: true

        targetIndex: GC.vectorCircleMode
        onTargetIndexChanged: {
            GC.setVectorCircleMode(targetIndex)
        }

        property bool rangeLen: targetIndex===0
    }

    PhasorDiagramEx {
        id: phasorDiagram
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        vector1Data: vectorU1
        vector2Data: vectorU2
        vector3Data: vectorU3
        vector4Data: vectorI1
        vector5Data: vectorI2
        vector6Data: vectorI3

        vector1Label: getVectorName(0);
        vector2Label: getVectorName(1);
        vector3Label: getVectorName(2);
        vector4Label: getVectorName(3);
        vector5Label: getVectorName(4);
        vector6Label: getVectorName(5);

        maxVoltage: {
            let rangeMax = root.maxOVRRejectionU*Math.SQRT2
            let max
            if(lenMode.rangeLen) {
                max = rangeMax
            }
            else {
                max = root.maxRmsU * maxNominalFactor / (threePhase ? sqrt3 : 1)
                // avoid no load arrow dance
                let minValue = rangeMax > 1 ? rangeMax*minRelValueDisplayed * 0.1 : rangeMax*minRelValueDisplayed
                if(maxRmsU < minValue)
                    max = rangeMax
            }
            return max
        }
        maxCurrent: {
            let rangeMax = root.maxOVRRejectionI*Math.SQRT2
            let max
            if(lenMode.rangeLen) {
                max = rangeMax
            }
            else {
                max = root.maxRmsI * maxNominalFactor
                // avoid no load arrow dance
                let minValue = rangeMax > 1 ? rangeMax*minRelValueDisplayed * 0.1 : rangeMax*minRelValueDisplayed
                if(maxRmsI < minValue)
                    max = rangeMax
            }
            return max
        }

        vectorView: root.viewMode
        currentVisible: currentOnOffSelector.displayCurrents
    }
}
