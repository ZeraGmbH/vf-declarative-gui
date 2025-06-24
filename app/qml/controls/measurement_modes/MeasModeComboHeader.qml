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
import ZeraVeinComponents 1.0
import ZeraComponents 1.0

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
        id: grid
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
                //let nomFreq = Number(entityIntrospection.ModuleInfo.NominalFrequency)
                let nomFreq = entity.PAR_FOUT_NOMINAL_FREQ !== undefined ? entity.PAR_FOUT_NOMINAL_FREQ : 0
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
    Button {
        id: editNfButton
        text: FAQ.fa_cogs
        font.pointSize: pointSize * 1.5
        anchors.rightMargin: grid.width > 200 ? 5 : -5
        anchors.right: grid.right
        anchors.verticalCenter: grid.verticalCenter
        implicitWidth: grid.width < 200 ? 35 : 50
        implicitHeight: parent.height / 2
        enabled: true
        visible: !showFoutOnly
        onClicked: {
            setNominalFrequencyPopup.open()
        }
    }

    Popup {
        id: setNominalFrequencyPopup
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        modal: true
        // Depending on session parent.width is different so we take own width
        contentWidth: buttonRow.implicitWidth * 1.2
        height: parent.height * 1.5

        ColumnLayout {
            id: setNominalFrequencyPopupContent
            anchors.fill: parent
            anchors.horizontalCenter: parent.Center
            Label {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter || Qt.AlignTop
                font.pointSize: root.pointSize * 1.8
                text: Z.tr("NF (Nominal Frequency)")
            }
            RowLayout {
                id: buttonRow
                spacing: 40
                Layout.alignment: Qt.AlignHCenter
                Button {
                    text: Z.tr("60 kHz");
                    font.pointSize: root.pointSize * 1.8
                    highlighted: false
                    onClicked: {
                        root.entity.PAR_FOUT_NOMINAL_FREQ = 60000
                        setNominalFrequencyPopup.close()
                    }
                }
                Button {
                    text: Z.tr("200 kHz");
                    font.pointSize: root.pointSize * 1.8
                    highlighted: false
                    onClicked: {
                        root.entity.PAR_FOUT_NOMINAL_FREQ = 200000
                        setNominalFrequencyPopup.close()
                    }
                }
                Button {
                    text: Z.tr("Close")
                    font.pointSize: root.pointSize * 1.8
                    highlighted: false
                    onClicked: {
                        setNominalFrequencyPopup.close()
                    }
                }
            }
        }
    }
}
