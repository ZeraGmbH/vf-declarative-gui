import QtQuick 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
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

    readonly property real din410PhiOrigin: Math.atan2(vData.getVector(0)[1],vData.getVector(0)[0])+Math.PI/2
    readonly property real iec387PhiOrigin: Math.atan2(vData.getVector(3)[1],vData.getVector(3)[0])
    readonly property real phiOrigin: dinIECSelector.din410 ? din410PhiOrigin : iec387PhiOrigin;

    property real topMargin: 0

    ZComboBox {
        id: viewModeSelector
        arrayMode: true
        model: ["VEC  UL  PN", "VEC  UL  △", "VEC  UL  ∠"]

        targetIndex: GC.vectorMode
        onTargetIndexChanged: {
            root.viewMode = targetIndex
            GC.setVectorMode(targetIndex)
        }

        anchors.bottomMargin: 24
        anchors.bottom: currentOnOffSelector.top;
        anchors.right: root.right
        anchors.rightMargin: 20
        height: root.height/10
        width: root.width/7
        fontSize: Math.min(18, height/1.5, width/8);
    }

    ZComboBox {
        id: currentOnOffSelector
        arrayMode: true
        model: ["VEC  IL  ON", "VEC  IL  OFF"]

        anchors.bottomMargin: 24
        anchors.bottom: dinIECSelector.top;
        anchors.right: root.right
        anchors.rightMargin: 20
        height: root.height/10
        width: root.width/7
        fontSize: Math.min(18, height/1.5, width/8);
        targetIndex: GC.vectorShowI ? 0 : 1
        onTargetIndexChanged: {
            GC.setVectorShowI(targetIndex == 0)
        }

        readonly property bool displayCurrents: targetIndex===0
    }

    ZComboBox {
        id: dinIECSelector
        arrayMode: true
        model: ["DIN410", "IEC387"]

        anchors.bottomMargin: 24
        anchors.bottom: parent.bottom;
        anchors.right: root.right
        anchors.rightMargin: 20
        height: root.height/10
        width: root.width/7
        fontSize: Math.min(18, height/1.5, width/8);
        centerVertical: true
        centerVerticalOffset: height/2

        targetIndex: GC.vectorIecMode
        onTargetIndexChanged: {
            GC.setVectorIecMode(targetIndex)
        }

        property bool din410: targetIndex===0
    }

    Item {
        id: vData

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

        function getMaxRejectionU() {
            var retVal = 0;
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel1ActREJ)
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel2ActREJ)
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel3ActREJ)
            return retVal
        }

        function getMaxOVRRejectionU() {
            var retVal = 0;
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel1ActOVLREJ)
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel2ActOVLREJ)
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel3ActOVLREJ)
            return retVal
        }

        function getMaxOVRRejectionI() {
            var retVal = 0;
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel4ActOVLREJ)
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel5ActOVLREJ)
            retVal = Math.max(retVal, root.rangeInfo.INF_Channel6ActOVLREJ)
            return retVal
        }
    }

    PhasorDiagram {
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

        vector1Data: vData.getVector(0);
        vector2Data: vData.getVector(1);
        vector3Data: vData.getVector(2);
        vector4Data: vData.getVector(3);
        vector5Data: vData.getVector(4);
        vector6Data: vData.getVector(5);

        vector1Label: vData.getVectorName(0);
        vector2Label: vData.getVectorName(1);
        vector3Label: vData.getVectorName(2);
        vector4Label: vData.getVectorName(3);
        vector5Label: vData.getVectorName(4);
        vector6Label: vData.getVectorName(5);

        phiOrigin: root.phiOrigin
        minVoltage: maxVoltage / 25.0
        maxVoltage: vData.getMaxOVRRejectionU()*Math.sqrt(2)
        minCurrent: maxCurrent / 25.0
        maxCurrent: vData.getMaxOVRRejectionI()*Math.sqrt(2)

        circleColor: Material.frameColor;
        circleValue: vData.getMaxRejectionU()*Math.sqrt(2);
        circleVisible: true

        gridColor: Material.frameColor;
        gridVisible: true

        gridScale: Math.min(height,width)/maxVoltage/2

        vectorView: root.viewMode
        vectorMode: root.referencePhaseMode
        currentVisible: currentOnOffSelector.displayCurrents
    }
}
