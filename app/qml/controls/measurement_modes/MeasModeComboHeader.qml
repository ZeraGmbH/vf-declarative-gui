import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import FontAwesomeQml 1.0

Rectangle {
    id: root
    // setters
    property var entity
    property var entityIntrospection
    property real rowHeight

    visible: entity.PAR_FOUT0 !== undefined && entity.PAR_FOUT0 !== ""
    readonly property bool showFoutOnly: entity.PAR_MeasuringMode === "QREF"
    readonly property int rowCount: showFoutOnly ? 1 : 3
    height: visible ? (rowHeight * rowCount * 0.9 + (rowCount+2) * rowHeight * 0.1) : 0
    width: parent.width
    color: "white"
    property real pointSize: height > 0 ? rowHeight * 0.35 : 5
    radius: 4
    GridLayout {
        columns: 2
        columnSpacing: 3
        rowSpacing: 3
        anchors.fill: parent
        anchors.margins: 8
        Text {
            text: FAQ.fa_dot_circle + "<b>:</b>"
            font.pointSize: pointSize
        }
        Text {
            text: root.visible ?  entity.PAR_FOUT0 : ""
            font.pointSize: pointSize
        }
        Text {
            text: Z.tr("NF:")
            visible: !showFoutOnly
            font.bold: true
            font.pointSize: pointSize
        }
        Text {
            text: {
                let nomFreq = Number(entityIntrospection.ModuleInfo.NominalFrequency)
                let scaled = FT.doAutoScale(nomFreq, "Hz")
                return scaled[0]+scaled[1]
            }
            visible: !showFoutOnly
            font.pointSize: pointSize
        }
        Text {
            text: "C:"
            visible: !showFoutOnly
            font.bold: true
            font.pointSize: pointSize
        }
        Text {
            text: {
                let meterConstant = entity.PAR_FOUTConstant0 !== undefined ? Number(entity.PAR_FOUTConstant0) : 0
                // at the time of writing module does not update unit on mode
                // change. Maybe it never will...
                //let unit = entityIntrospection.ComponentInfo[String("ACT_PQS1")].Unit
                // so instead do some 'clever' unit extraction from measurement mode
                let unit = "W"
                let mode = entity.PAR_MeasuringMode
                if(mode.includes("LB")) {
                    unit = "Var"
                }
                else if(mode.includes("LS")) {
                    unit = "VA"
                }
                let scaled = FT.doAutoScale(meterConstant, `/k${unit}h`)
                return Math.round(scaled[0]*1000)/1000+scaled[1]
            }
            visible: !showFoutOnly
            font.pointSize: pointSize
        }
    }
}
