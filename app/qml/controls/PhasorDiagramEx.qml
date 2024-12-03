import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0

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
    circleColor: Material.frameColor
    circleValue: maxVoltage / maxNominalFactor

    gridVisible: true
    gridColor: Material.frameColor;
    gridScale: Math.min(height,width)/maxVoltage/2

    vector1Color: GC.colorUL1
    vector2Color: GC.colorUL2
    vector3Color: GC.colorUL3
    vector4Color: GC.colorIL1
    vector5Color: GC.colorIL2
    vector6Color: GC.colorIL3

    readonly property real din410PhiOrigin: Math.atan2(vector1Data[1], vector1Data[0])+Math.PI/2
    readonly property real iec387PhiOrigin: Math.atan2(vector4Data[1], vector4Data[0])
    phiOrigin: din410 ? din410PhiOrigin : iec387PhiOrigin;
}
