import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraFa 1.0

Item {
    id: root
    clip: true

    // set by our tab-page
    property var jsonSourceInfo

    readonly property real pointSize: height > 0 ? height / 30 : 10
    readonly property real comboFontSize: pointSize * 1.25
    readonly property real widthRightArea: width * 0.4
    readonly property real widthLeftArea: width * 0.05

    property real angleLineHeight: (parent.height - phasorDiagramm.height) / 3
    Rectangle { // extra buttons
        id: extraButtonRect
        anchors.left: parent.left
        width: 0//widthLeftArea
        anchors.top: parent.top
        anchors.bottom: onOffRect.top
        border.color: Material.dividerColor
        color: Material.backgroundColor
    }
    Rectangle {  // value table
        anchors.left: extraButtonRect.right
        anchors.right: rightColumn.left
        anchors.top: parent.top
        anchors.bottom: onOffRect.top
        border.color: Material.dividerColor
        color: Material.backgroundColor
    }
    Rectangle {
        id: onOffRect
        anchors.left: parent.left
        anchors.right: rightColumn.left
        height: angleLineHeight
        anchors.bottom: parent.bottom
        border.color: Material.dividerColor
        color: Material.backgroundColor
        Button {
            text: Z.tr("On")
            width: angleButtonRow.buttonWidth * 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: widthLeftArea
            topInset: 0
            bottomInset: 0
            font.pointSize: root.pointSize * 0.9
        }
        Button {
            text: Z.tr("Off")
            width: angleButtonRow.buttonWidth * 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: widthLeftArea
            topInset: 0
            bottomInset: 0
            font.pointSize: root.pointSize * 0.9
        }
    }




    Column {
        id: rightColumn
        anchors.right: parent.right
        width: widthRightArea
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Rectangle {
            id: vectorFrame
            width: parent.width
            height: width * 0.8
            border.color: Material.dividerColor
            color: Material.backgroundColor
            PhasorDiagram {
                anchors.fill: parent
                id: phasorDiagramm
                circleVisible: true

                gridColor: Material.frameColor;
                gridVisible: true

                fromX: Math.floor(width/2)
                fromY: Math.floor(height/2)
                phiOrigin: 0

                vector1Color: GC.colorUL1
                vector2Color: GC.colorUL2
                vector3Color: GC.colorUL3
                vector4Color: GC.colorIL1
                vector5Color: GC.colorIL2
                vector6Color: GC.colorIL3

                /*vector1Data: [v1x.text,v1y.text];
                vector2Data: [v2x.text,v2y.text];
                vector3Data: [v3x.text,v3y.text];
                vector4Data: [v4x.text,v4y.text];
                vector5Data: [v5x.text,v5y.text];
                vector6Data: [v6x.text,v6y.text];*/

                vector1Label: "UL1"
                vector2Label: "UL2"
                vector3Label: "UL3"
                vector4Label: "IL1"
                vector5Label: "IL2"
                vector6Label: "IL3"
            }
        }
        Rectangle {
            border.color: Material.dividerColor
            width: parent.width
            height: angleLineHeight
            color: Material.backgroundColor
            Row {
                id: angleButtonRow
                readonly property int buttonWidth: parent.width / 4
                width: parent.width
                height: angleLineHeight
                anchors.top: parent.top
                Button {
                    width: angleButtonRow.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: root.pointSize * 0.9
                    text: "0°"
                }
                Button {
                    width: angleButtonRow.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: root.pointSize * 0.9
                    text: "180°"
                }
                Button {
                    width: angleButtonRow.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: root.pointSize * 0.9
                    text: "+15°"
                }
                Button {
                    width: angleButtonRow.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: root.pointSize * 0.9
                    text: "-15°"
                }
            }
        }
        Rectangle { // P/Q + cos/sin + quadrant row
            border.color: Material.dividerColor
            width: parent.width
            height: angleLineHeight
            color: Material.backgroundColor
            RowLayout {
                width: parent.width
                height: angleLineHeight
                anchors.bottom: parent.bottom
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: angleButtonRow.buttonWidth * 0.5
                    ZComboBox {
                        id: comboPQ
                        anchors.fill: parent
                        arrayMode: true
                        fontSize: comboFontSize
                        centerVertical: true
                        model: ['P', 'Q']
                    }
                }
                Label {
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    horizontalAlignment: Label.AlignRight
                    text: comboPQ.currentText === "P" ? "cos φ:" :"sin φ:"
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: itemFreq.width
                    ZLineEdit {
                        anchors.fill: parent
                        pointSize: root.pointSize
                    }
                }
                Label {
                    font.pointSize: pointSize
                    Layout.preferredWidth: lblHz.width
                    text: "Q:"
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: angleButtonRow.buttonWidth * 0.75
                    Layout.rightMargin: 2 // have no idea why it paints over parent's border
                    ZComboBox {
                        anchors.fill: parent
                        arrayMode: true
                        fontSize: comboFontSize
                        centerVertical: true
                        model: ['1', '2', '3', '4']
                    }
                }
            }
        }
        Rectangle { // frequency row
            border.color: Material.dividerColor
            width: parent.width
            height: angleLineHeight
            color: Material.backgroundColor
            RowLayout {
                width: parent.width
                height: angleLineHeight
                anchors.bottom: parent.bottom
                Label {
                    font.pointSize: pointSize
                    Layout.leftMargin: GC.standardTextHorizMargin
                    text: Z.tr("Frequency:")
                }
                Item {
                    id: itemFreq
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ZLineEdit {
                        anchors.fill: parent
                        pointSize: root.pointSize
                    }
                }
                Label {
                    id: lblHz
                    font.pointSize: pointSize
                    text: "Hz"
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: angleButtonRow.buttonWidth * 0.75
                    Layout.rightMargin: 2 // have no idea why it paints over parent's border
                    ZComboBox {
                        anchors.fill: parent
                        arrayMode: true
                        fontSize: comboFontSize
                        centerVertical: true
                        model: ['var', 'syn']
                    }
                }
            }
        }
    }
}
