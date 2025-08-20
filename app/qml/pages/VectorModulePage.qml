import QtQuick 2.14
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import VectorDiagramQml 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0
import ZeraThemeConfig 1.0
import '../controls'

Item {
    id: root

    readonly property real pointSize: Math.max(10, height / 28)
    readonly property real horizMarign: width*0.01
    property real topMargin: 0

    readonly property var vector0: getVector(0)
    readonly property var vector1: getVector(1)
    readonly property var vector2: getVector(2)
    readonly property var vector3: getVector(3)
    readonly property var vector4: getVector(4)
    readonly property var vector5: getVector(5)

    // vector & range helpers
    function getVector(vecIndex) {
        let strIndex = parseInt(vecIndex+1)
        let value = phasorDiagram.dftModule["ACT_DFTPN" + strIndex]
        return value !== undefined ? value : [0,0]
    }

    PhasorDiagramEx {
        id: phasorDiagram

        nominalSelection: lenMode.targetIndex

        vectorData0: vector0
        vectorData1: vector1
        vectorData2: vector2
        vectorData3: vector3
        vectorData4: vector4
        vectorData5: vector5

        nominalVoltage: maxRejectionU
        minVoltage: nominalSelection == VectorSettingsLengths.MAXIMUM ? nominalVoltage * 0.009 : nominalVoltage * 0.05
        nominalCurrent: maxRejectionI
        minCurrent: nominalSelection == VectorSettingsLengths.MAXIMUM ? nominalCurrent * 0.009 : nominalCurrent * 0.05
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
            if(lenMode.rangeLen)
                return phasorDiagram.maxURange
            let maxVoltage = phasorDiagram.maxVoltage
            // factor 1000: Our auto scale scales too late - it was designed for values rising monotonous
            let valUnitArr = FT.doAutoScale(maxVoltage / (1000 * Math.SQRT2), "V")
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
                return phasorDiagram.maxIRange
            // factor 1000: Our auto scale scales too late - it was designed for values rising monotonous
            let valUnitArr = FT.doAutoScale(phasorDiagram.maxCurrent / (1000 * Math.SQRT2), "A")
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
    readonly property real comboWidth: width/7
    readonly property real comboMargin: 8
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

        targetIndex: GC.vectorType
        onTargetIndexChanged: GC.setVectorType(targetIndex)

        anchors.bottomMargin: comboMargin
        anchors.bottom: dinIECSelector.top
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
        model: ["DIN", "IEC", "ANSI"]

        anchors.bottom: lenMode.top
        anchors.bottomMargin: comboMargin
        anchors.right: root.right
        anchors.rightMargin: horizMarign
        height: root.height/10
        width: comboWidth

        targetIndex: GC.vectorStandard
        onTargetIndexChanged: GC.setVectorStandard(targetIndex)
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
        onTargetIndexChanged:  GC.setVectorCircleMode(targetIndex)

        property bool rangeLen: targetIndex===0
    }
}
