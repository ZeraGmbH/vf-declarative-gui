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
    property var jsonSourceInfoRaw
    // convenient JSON to simplify code below
    readonly property var jsonSourceInfo: {
        let retJson = jsonSourceInfoRaw
        let supportsHarmonics = false
        let supportsHarmonicsU = false
        let maxUValue = 0.0
        let uiCount = 0;
        if(jsonSourceInfoRaw.UPhaseMax > 0) {
            uiCount++
        }
        if(jsonSourceInfoRaw.IPhaseMax > 0) {
            uiCount++
        }
        for(let phaseU=1; phaseU<=jsonSourceInfoRaw.UPhaseMax; ++phaseU) {
            let phaseNameU = String("U%1").arg(phaseU)
            if(jsonSourceInfoRaw[phaseNameU]) {
                if(jsonSourceInfoRaw[phaseNameU].sameAs) {
                    let refPhaseU = jsonSourceInfoRaw[phaseNameU].sameAs
                    retJson[phaseNameU] = jsonSourceInfoRaw[refPhaseU]
                }
                if(jsonSourceInfoRaw[phaseNameU].supportsHarmonics) {
                    supportsHarmonics = true
                    supportsHarmonicsU = true
                }
                if(jsonSourceInfoRaw[phaseNameU].maxVal > maxUValue) {
                    maxUValue = jsonSourceInfoRaw[phaseNameU].maxVal
                }
            }
        }
        let supportsHarmonicsI = false
        let maxIValue = 0.0
        for(let phaseI=1; phaseI<=jsonSourceInfoRaw.IPhaseMax; ++phaseI) {
            let phaseNameI = String("I%1").arg(phaseI)
            if(jsonSourceInfoRaw[phaseNameI]) {
                if(jsonSourceInfoRaw[phaseNameI].sameAs) {
                    let refPhaseI = jsonSourceInfoRaw[phaseNameI].sameAs
                    retJson[phaseNameI] = jsonSourceInfoRaw[refPhaseI]
                }
                if(jsonSourceInfoRaw[phaseNameI].supportsHarmonics) {
                    supportsHarmonics = true
                    supportsHarmonicsI = true
                }
                if(jsonSourceInfoRaw[phaseNameI].maxVal > maxIValue) {
                    maxIValue = jsonSourceInfoRaw[phaseNameI].maxVal
                }
            }
        }
        retJson['supportsHarmonics'] = supportsHarmonics
        retJson['supportsHarmonicsU'] = supportsHarmonicsU
        retJson['supportsHarmonicsI'] = supportsHarmonicsI

        retJson['uiCount'] = uiCount

        retJson['maxValU'] = maxUValue
        retJson['maxValI'] = maxIValue
        return retJson
    }
    // convenient properties
    readonly property int linesU: (jsonSourceInfo && jsonSourceInfo.UPhaseMax) ? (jsonSourceInfo.supportsHarmonicsU ? 4: 3) : 0
    readonly property int linesI: (jsonSourceInfo && jsonSourceInfo.IPhaseMax) ? (jsonSourceInfo.supportsHarmonicsI ? 4: 3) : 0
    readonly property int linesTotal: 1 + linesU + linesI

    readonly property real pointSize: height > 0 ? height / 30 : 10
    readonly property real headerPointSize: pointSize * 2
    readonly property real comboFontSize: pointSize * 1.25
    readonly property real widthRightArea: width * 0.4
    readonly property real widthLeftArea: width * 0.05

    property real angleLineHeight: (parent.height - phasorDiagramm.height) / 3
    Rectangle { // extra buttons
        id: extraButtonRect
        anchors.left: parent.left
        // argh - we do not have yet https://tc39.es/proposal-optional-chaining/
        // as 'jsonSourceInfo?.supportsHarmonics'
        width: (jsonSourceInfo && jsonSourceInfo.supportsHarmonics) ? widthLeftArea : 0
        anchors.top: parent.top
        anchors.bottom: onOffRect.top
        border.color: Material.dividerColor
        color: Material.backgroundColor
    }
    Item {  // value table
        id: valueRectangle
        anchors.left: extraButtonRect.right
        anchors.right: rightColumn.left
        anchors.top: parent.top
        anchors.bottom: onOffRect.top
        readonly property real headerColumnWidth: valueRectangle.width * 0.08
        readonly property bool keepHeight: linesTotal >= 1+4
        readonly property real lineHeight: keepHeight ? height / linesTotal : 0.5 *  height / linesTotal
        readonly property real topMargin: keepHeight ? 0 : height / 4
        Column {
            id: headerColumnUI
            anchors.top: parent.top
            anchors.topMargin: valueRectangle.topMargin + valueRectangle.lineHeight
            anchors.bottom: parent.bottom
            anchors.left: parent.left // TODO header columns
            width: valueRectangle.headerColumnWidth
            Rectangle { // U
                anchors.left: parent.left
                anchors.right: parent.right
                height: jsonSourceInfo.UPhaseMax ? (jsonSourceInfo.supportsHarmonicsU ? 4 : 3) * valueRectangle.lineHeight : 0
                visible: jsonSourceInfo.UPhaseMax > 0
                border.color: Material.dividerColor
                color: Material.backgroundColor
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: headerPointSize
                    text: "U"
                }
            }
            Rectangle { // I
                anchors.left: parent.left
                anchors.right: parent.right
                height: jsonSourceInfo.IPhaseMax ? (jsonSourceInfo.supportsHarmonicsI ? 4 : 3) * valueRectangle.lineHeight : 0
                visible: jsonSourceInfo.IPhaseMax > 0
                border.color: Material.dividerColor
                color: Material.backgroundColor
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: headerPointSize
                    text: "I"
                }
            }
        }
        Column {
            id: headerColumnInfo
            anchors.top: parent.top
            anchors.topMargin: valueRectangle.topMargin + valueRectangle.lineHeight
            anchors.bottom: parent.bottom
            anchors.left: headerColumnUI.right
            width: valueRectangle.headerColumnWidth
            Repeater {
                model: linesTotal-1 // no horizontal  header
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: valueRectangle.lineHeight
                    border.color: Material.dividerColor
                    color: Material.backgroundColor
                }
            }
        }
        Column {
            id: headerColumnValues
            anchors.top: parent.top
            anchors.topMargin: valueRectangle.topMargin
            anchors.bottom: parent.bottom
            anchors.left: headerColumnInfo.right
            anchors.right: headerColumnUnit.left
            Repeater {
                model: linesTotal
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: valueRectangle.lineHeight
                    border.color: Material.dividerColor
                    color: Material.backgroundColor
                }
            }
        }
        Column {
            id: headerColumnUnit
            anchors.top: parent.top
            anchors.topMargin: valueRectangle.topMargin + valueRectangle.lineHeight
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: valueRectangle.headerColumnWidth
            Repeater {
                model: linesTotal-1 // no horizontal  header
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: valueRectangle.lineHeight
                    border.color: Material.dividerColor
                    color: Material.backgroundColor
                }
            }
        }
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
