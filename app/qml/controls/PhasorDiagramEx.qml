import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0
import ZeraThemeConfig 1.0

PhasorDiagram {
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: Math.min(height * 1.2, parent.width)
    anchors.horizontalCenter: parent.horizontalCenter
    fillColor: color

    property bool din410: true
    property real maxNominalFactor: 1.25
    property real minRelValueDisplayed: 0.05
    minVoltage: maxVoltage * minRelValueDisplayed
    minCurrent: maxCurrent * minRelValueDisplayed

    readonly property real sqrt3: Math.sqrt(3)

    circleVisible: true
    circleColor: ZTC.frameColor
    circleValue: maxVoltage / maxNominalFactor

    gridVisible: true
    gridColor: ZTC.frameColor;
    gridScale: Math.min(height,width)/maxVoltage/2

    fromX: Math.floor(width/2)
    fromY: Math.floor(height/2)

    vectorColor0: CS.colorUL1
    vectorColor1: CS.colorUL2
    vectorColor2: CS.colorUL3
    vectorColor3: CS.colorIL1
    vectorColor4: CS.colorIL2
    vectorColor5: CS.colorIL3

    readonly property real din410PhiOrigin: Math.atan2(vectorData0[1], vectorData0[0])+Math.PI/2
    readonly property real iec387PhiOrigin: Math.atan2(vectorData3[1], vectorData3[0])
    phiOrigin: din410 ? din410PhiOrigin : iec387PhiOrigin;
}
