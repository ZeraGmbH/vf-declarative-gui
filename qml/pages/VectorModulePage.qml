import QtQuick 2.14
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0
import "qrc:/qml/controls" as CCMP

CCMP.ModulePage {
    id: root

    readonly property QtObject dftModule: VeinEntity.getEntity("DFTModule1")
    readonly property QtObject rangeInfo: VeinEntity.getEntity("RangeModule1")

    readonly property int e_starView: 0;
    readonly property int e_triangleView: 1;
    readonly property int e_threePhaseView: 2;

    property int viewMode : e_starView;

    readonly property int e_DIN: 0;
    readonly property int e_IEC: 1;

    property int referencePhaseMode: e_DIN;

    readonly property real pointSize: Math.max(10, height / 28)
    readonly property real horizMarign: 10
    readonly property real comboWidth: width/7.5
    readonly property real maxNominalFactor: 1.25

    property real topMargin: 0

    // vectors / values / ranges....
    readonly property real din410PhiOrigin: Math.atan2(getVector(0)[1], getVector(0)[0])+Math.PI/2
    readonly property real iec387PhiOrigin: Math.atan2(getVector(3)[1], getVector(3)[0])
    readonly property real phiOrigin: dinIECSelector.din410 ? din410PhiOrigin : iec387PhiOrigin;

    function getVectorName(vecIndex) {
        var retVal;
        if(root.viewMode===root.e_starView || root.viewMode===root.e_triangleView) {
            retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN"+parseInt(vecIndex+1)].ChannelName
        }
        if(root.viewMode===root.e_threePhaseView) {
            if(vecIndex < 3) {
                retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPP"+parseInt(vecIndex+1)].ChannelName;
            }
            else {
                retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN"+parseInt(vecIndex+1)].ChannelName
            }
        }
        return retVal;
    }
    function getVector(vecIndex) {
        var retVal=[0,0];
        if(root.viewMode===root.e_starView || root.viewMode===root.e_triangleView) {
            retVal = root.dftModule["ACT_DFTPN"+parseInt(vecIndex+1)];
        }
        else if(root.viewMode===root.e_threePhaseView) {
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
        return retVal;
    }
    property string maxURange: "5000V"
    readonly property real maxOVRRejectionU: {
        let maxVal = 0;
        for(let channel=1; channel<=3; channel++) {
            let newVal = root.rangeInfo[`INF_Channel${channel}ActOVLREJ`]
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
            let newVal = root.rangeInfo[`INF_Channel${channel}ActOVLREJ`]
            if(newVal > maxVal) {
                maxVal = newVal
                maxIRange = root.rangeInfo[`PAR_Channel${channel}Range`]
            }
        }
        return maxVal
    }
    readonly property real maxU: {
        let retVal = 0;
        for(let channel=0; channel<3; channel++) {
            retVal = Math.max(retVal, Math.sqrt(Math.pow(getVector(channel)[0], 2) + Math.pow(getVector(channel)[1], 2)))
        }
        return retVal
    }
    readonly property real maxI: {
        let retVal = 0;
        for(let channel=3; channel<6; channel++) {
            retVal = Math.max(retVal, Math.sqrt(Math.pow(getVector(channel)[0], 2) + Math.pow(getVector(channel)[1], 2)))
        }
        return retVal
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
            if(lenMode.rangeLen && root.viewMode !== root.e_threePhaseView) {
                return maxURange
            }
            let maxVoltage = phasorDiagramm.maxVoltage
            if(root.viewMode === root.e_threePhaseView) {
                maxVoltage *= Math.sqrt(3)
            }
            // factor 1000: Our auto scale scales too late - it was designed for values rising monotonous
            let valUnitArr = GC.doAutoScale(maxVoltage / (1000*maxNominalFactor * Math.sqrt(2)), "V")
            return GC.formatNumber(valUnitArr[0]*1000, lenMode.rangeLen ? 0 : undefined) + valUnitArr[1]
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
            let valUnitArr = GC.doAutoScale(phasorDiagramm.maxCurrent / (1000 * maxNominalFactor * Math.sqrt(2)), "A")
            return GC.formatNumber(valUnitArr[0]*1000, lenMode.rangeLen ? 0 : undefined) + valUnitArr[1]
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

        anchors.bottomMargin: 12
        anchors.bottom: currentOnOffSelector.top;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
        fontSize: pointSize
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

        anchors.bottomMargin: 12
        anchors.bottom: dinIECSelector.top;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
        fontSize: pointSize
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
        anchors.bottomMargin: 12
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
        fontSize: pointSize

        targetIndex: GC.vectorIecMode
        onTargetIndexChanged: {
            GC.setVectorIecMode(targetIndex)
        }

        property bool din410: targetIndex===0
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

        //anchors.bottomMargin: 12
        anchors.bottom: parent.bottom;
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth
        fontSize: pointSize
        centerVertical: true

        targetIndex: GC.vectorCircleMode
        onTargetIndexChanged: {
            GC.setVectorCircleMode(targetIndex)
        }

        property bool rangeLen: targetIndex===0
    }

    PhasorDiagram {
        id: phasorDiagramm
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        fromX: Math.floor(width/2)
        fromY: Math.floor(height/2)

        vector1Color: GC.colorUL1
        vector2Color: GC.colorUL2
        vector3Color: GC.colorUL3
        vector4Color: GC.colorIL1
        vector5Color: GC.colorIL2
        vector6Color: GC.colorIL3

        vector1Data: getVector(0);
        vector2Data: getVector(1);
        vector3Data: getVector(2);
        vector4Data: getVector(3);
        vector5Data: getVector(4);
        vector6Data: getVector(5);

        vector1Label: getVectorName(0);
        vector2Label: getVectorName(1);
        vector3Label: getVectorName(2);
        vector4Label: getVectorName(3);
        vector5Label: getVectorName(4);
        vector6Label: getVectorName(5);

        phiOrigin: root.phiOrigin
        minVoltage: maxVoltage / 25.0
        maxVoltage: {
            let rangeMax = root.maxOVRRejectionU*Math.sqrt(2)
            let max
            if(lenMode.rangeLen) {
                max = rangeMax
            }
            else {
                max = root.maxU * maxNominalFactor / (root.viewMode === root.e_threePhaseView ? Math.sqrt(3) : 1)
                // avoid no load arrow dance
                if(max < rangeMax / 10) {
                    max = rangeMax
                }
            }
            return max
        }
        minCurrent: maxCurrent / 25.0
        maxCurrent: {
            let rangeMax = root.maxOVRRejectionI*Math.sqrt(2)
            let max
            if(lenMode.rangeLen) {
                max = rangeMax
            }
            else {
                max = root.maxI * maxNominalFactor
                // avoid no load arrow dance
                if(max < rangeMax / 10) {
                    max = rangeMax
                }
            }
            return max
        }
        circleColor: Material.frameColor;
        circleValue: maxVoltage / maxNominalFactor
        circleVisible: true

        gridColor: Material.frameColor;
        gridVisible: true

        gridScale: Math.min(height,width)/maxVoltage/2

        vectorView: root.viewMode
        vectorMode: root.referencePhaseMode
        currentVisible: currentOnOffSelector.displayCurrents
    }
}
