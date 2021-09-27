import QtQuick 2.14
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraFa 1.0

Item {
    // set by our tab-page
    property var jsonSourceInfoRaw

    enum LineType {
        LineOnOff = 0,
        LineRMS,
        LineAngle,
        LineHarmonics
    }

    // convenient JSON to simplify code below
    readonly property var jsonSourceInfo: {
        let retJson = jsonSourceInfoRaw

        retJson['maxValU'] = 0.0
        retJson['maxValI'] = 0.0
        retJson['extraLinesRequired'] = false

        let uiCount = 0
        let arrUI = ['U', 'I']

        // * apply 'sameAs'
        // * calc U/I max values
        // * U/I/global harmonic support

        // using array's forEach and arrow function causes qt-creator
        // freaking out on indentation. So loop the old-school way
        for(let numUI=0; numUI<arrUI.length; ++numUI) {
            let strUI = arrUI[numUI]
            let maxPhaseNum = jsonSourceInfoRaw[strUI + 'PhaseMax']
            if(maxPhaseNum > 0) {
                uiCount++
            }

            for(var phase=1; phase<=maxPhaseNum; ++phase) {
                let phaseName = strUI + String(phase)
                if(jsonSourceInfoRaw[phaseName]) {
                    if(jsonSourceInfoRaw[phaseName].sameAs) {
                        let refPhase = jsonSourceInfoRaw[phaseName].sameAs
                        retJson[phaseName] = jsonSourceInfoRaw[refPhase]
                    }
                    if(jsonSourceInfoRaw[phaseName].supportsHarmonics) {
                        retJson['extraLinesRequired'] = true
                        retJson['supportsHarmonics'+strUI] = true
                    }
                    if(jsonSourceInfoRaw[phaseName].maxVal > retJson['maxVal'+strUI]) {
                        retJson['maxVal'+strUI] = jsonSourceInfoRaw[phaseName].maxVal
                    }
                }
            }
        }
        retJson['uiCount'] = uiCount

        // check which colums we have to display
        let columInfo = []
        let maxPhaseAll = Math.max(jsonSourceInfoRaw['UPhaseMax'],
                                   jsonSourceInfoRaw['IPhaseMax'])
        for(phase=1; phase<=maxPhaseAll; ++phase) {
            let phaseRequired = retJson['U'+String(phase)] !== undefined || retJson['I'+String(phase)] !== undefined
            if(phaseRequired) {
                let phaseNameDisplay = 'L' + String(phase)
                let colorIndexU = phase-1
                let colorIndexI = phase-1 + 3
                if(phase > 3) {
                    colorIndexU = 6 // zero based
                    colorIndexI = 7
                    if(maxPhaseAll > 4) {
                        phaseNameDisplay = 'AUX' + String(phase-maxPhaseAll)
                    } else {
                        phaseNameDisplay = 'AUX'
                    }
                }
                columInfo.push({'phaseNum': phase,
                                   'phaseNameDisplay': phaseNameDisplay,
                                   'colorIndexU': colorIndexU,
                                   'colorIndexI': colorIndexI})
            }
        }
        retJson['columnInfo'] = columInfo

        return retJson
    }

    // To avoid waste of CPU by back & forth painting: Load view after jsonSourceInfo is valid
    Loader {
        anchors.fill: parent
        sourceComponent: theViewComponent
        active: jsonSourceInfo
    }
    Component {
        id: theViewComponent
        Item {
            id: theView
            anchors.fill: parent

            // convenient properties
            readonly property int linesStandardUI: 3 // RMS / Angle / OnOff
            readonly property real lineHeight: height / (linesStandardUI*2 + 2) // +2 header+bottom line
            readonly property real lineHeightHeaderLine: lineHeight - (horizScrollbarOn ? scrollBarWidth : 0)
            readonly property int linesU: jsonSourceInfo.UPhaseMax ? (jsonSourceInfo.supportsHarmonicsU ? 4: 3) : 0
            readonly property int linesI: jsonSourceInfo.IPhaseMax ? (jsonSourceInfo.supportsHarmonicsI ? 4: 3) : 0
            readonly property var uiModel: {
                let retArr = []
                if(linesU > 0) {
                    retArr.push('U')
                }
                if(linesI > 0) {
                    retArr.push('I')
                }
                return retArr
            }
            readonly property int columnsStandardUI: 3

            readonly property real pointSize: height > 0 ? height / 30 : 10
            readonly property real headerPointSize: pointSize * 1.5
            readonly property real comboFontSize: pointSize * 1.25
            readonly property real widthLeftArea: width * 0.6
            readonly property real widthRightArea: width - widthLeftArea
            readonly property real headerColumnWidth: widthLeftArea * 0.12
            readonly property real buttonWidth: widthRightArea / 4
            readonly property int scrollBarWidth: width > 100 ? width / 100 : 8
            readonly property bool horizScrollbarOn: jsonSourceInfo.columnInfo.length > 3
            readonly property bool vertScrollbarOnU: linesU > 3
            readonly property bool vertScrollbarOnI: linesI > 3

            // ------------------------ Layout ---------------------------------
            //
            //   headerColumnUI                       unitColumn
            //  /                                    /
            //  ----------------------------------------------------------------
            // | |                       RMS        | |                        |
            // | |             U         Angles     | |                        |
            // | |                       PhaseOnOff | |                        |
            // | |         dataTable                | |     vectorView         |
            // | |                       RMS        | |------------------------|
            // | |             I         Angles   <-|-|->   angleQuickRow      |
            // | |                       PhaseOnOff | |     pqRow              |
            //  ---------------------------------------------------------------|
            // |              onOffRow                |     frequencyRow       | bottomRow
            //  ----------------------------------------------------------------

            ///////////// left area /////////////
            Column { // U/I header left
                id: headerColumnUI
                anchors.bottom: bottomRow.top
                anchors.bottomMargin: theView.horizScrollbarOn ? theView.scrollBarWidth : 0
                anchors.left: parent.left
                width: theView.headerColumnWidth - jsonSourceInfo.extraLinesRequired * scrollBarWidth
                Rectangle { // empty topmost
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: theView.lineHeightHeaderLine
                    border.color: Material.dividerColor
                    color: GC.tableShadeColor
                }
                Repeater { // U/I rectangles
                    model: theView.uiModel
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: theView.linesStandardUI * theView.lineHeight
                        border.color: Material.dividerColor
                        color: GC.tableShadeColor
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pointSize: theView.headerPointSize
                            text: modelData
                        }
                    }
                }
            }

            Flickable { // table with controls to set values - center
                id: dataTable
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds // don't tear our table away from units
                anchors.top: parent.top
                anchors.topMargin: theView.linesU > 0 ? 0 : theView.linesStandardUI * lineHeight
                anchors.bottom: bottomRow.top
                anchors.left: headerColumnUI.right
                anchors.right: unitColumn.left
                contentWidth: columnWidth * jsonSourceInfo.columnInfo.length
                contentHeight: height - (theView.horizScrollbarOn ? theView.scrollBarWidth : 0)
                clip: true
                readonly property real columnWidth: width / theView.columnsStandardUI
                Column { // header / U table / I table
                    width: dataTable.contentWidth
                    height: dataTable.contentHeight

                    Row { // header row
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: theView.lineHeightHeaderLine
                        Repeater {
                            model: jsonSourceInfo.columnInfo
                            Rectangle {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: dataTable.columnWidth
                                border.color: Material.dividerColor
                                color: GC.tableShadeColor
                                Label {
                                    anchors.fill: parent
                                    anchors.rightMargin: GC.standardTextHorizMargin
                                    horizontalAlignment: Label.AlignRight
                                    verticalAlignment: Label.AlignVCenter
                                    font.pointSize: theView.headerPointSize
                                    text: modelData.phaseNameDisplay
                                    color: GC.currentColorTable[modelData.colorIndexU]
                                }
                            }
                        }
                    }

                    Repeater {  // a set of ListView for U & I
                        model: theView.uiModel
                        ListView { // 3+ lines
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: theView.lineHeight * theView.linesStandardUI
                            readonly property string uiType: modelData
                            model: uiType === 'U' ? theView.linesU : theView.linesI
                            snapMode: ListView.SnapToItem
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true
                            delegate: Row { // row of phase fields
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: theView.lineHeight
                                readonly property int rowIndex: index
                                Repeater {
                                    model: jsonSourceInfo ? jsonSourceInfo.columnInfo : 0
                                    Rectangle { // the field
                                        id: valueRect
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        border.color: Material.dividerColor
                                        color: Material.backgroundColor
                                        width: dataTable.columnWidth
                                        readonly property int columnIndex: index
                                        readonly property bool isAngleU1: uiType === 'U' &&
                                                                          rowIndex === SourceModulePage.LineType.LineAngle &&
                                                                          // TODO more common: first phase U
                                                                          columnIndex === 0
                                        property string valueText: { // This is for demo - we need some JSON for this
                                            if(isAngleU1) {
                                                return '0'
                                            }  else {
                                                // TODO!!!!!
                                                return '0.000'
                                            }
                                        }
                                        Loader { // we load matching control dynamically
                                            anchors.fill: parent
                                            sourceComponent: {
                                                switch(rowIndex) {
                                                default:
                                                    return phaseValueTextComponent
                                                case SourceModulePage.LineType.LineOnOff:
                                                    return phaseCheckBoxComponent
                                                case SourceModulePage.LineType.LineHarmonics:
                                                    return phaseComboHarmonics
                                                }
                                            }
                                        }
                                        Component {
                                            id: phaseValueTextComponent
                                            Item {
                                                anchors.fill: parent
                                                ZLineEdit {
                                                    id: valueEdit
                                                    anchors.fill: parent
                                                    pointSize: theView.lineHeight * 0.3
                                                    enabled: !valueRect.isAngleU1 &&
                                                             (!symmetricCheckbox.checked || columnIndex == 0 || columnIndex >= 3)
                                                    visible: enabled
                                                    textField.color: GC.currentColorTable[uiType === 'U' ?
                                                                                              modelData.colorIndexU :
                                                                                              modelData.colorIndexI]
                                                    text: valueText
                                                    readonly property var validatorInfo: {
                                                        let uiPrefix = uiType
                                                        let uiPhase = uiPrefix + String(columnIndex+1)
                                                        let minVal, maxVal, minStepVal = 0.0
                                                        switch(rowIndex) {
                                                        case SourceModulePage.LineType.LineRMS:
                                                            minVal = jsonSourceInfo[uiPhase].minVal
                                                            maxVal = jsonSourceInfo[uiPhase].maxVal
                                                            minStepVal = jsonSourceInfo[uiPhase].minStepVal
                                                            break
                                                        case SourceModulePage.LineType.LineAngle:
                                                            minStepVal = jsonSourceInfo[uiPhase].minStepValAngle
                                                            minVal = -360.0 + minStepVal
                                                            maxVal = 360.0 - minStepVal
                                                            break
                                                        }
                                                        return { 'minVal': minVal, 'maxVal': maxVal, 'minStepVal': minStepVal}
                                                    }
                                                    validator: ZDoubleValidator {
                                                        bottom: valueEdit.validatorInfo.minVal
                                                        top: valueEdit.validatorInfo.maxVal
                                                        decimals: FT.ceilLog10Of1DividedByX(valueEdit.validatorInfo.minStepVal)
                                                    }
                                                }
                                                // Hack: to make underline disappear for disabled ZLineEdit show Label
                                                Label {
                                                    visible: !valueEdit.visible
                                                    anchors.fill: parent
                                                    anchors.rightMargin: GC.standardTextHorizMargin
                                                    font.pointSize: theView.lineHeight * 0.3
                                                    horizontalAlignment: Label.AlignRight
                                                    verticalAlignment: Label.AlignVCenter
                                                    color: GC.currentColorTable[uiType === 'U' ?
                                                                                    modelData.colorIndexU :
                                                                                    modelData.colorIndexI]
                                                    text: valueEdit.textField.text
                                                }
                                            }
                                        }
                                        Component {
                                            id: phaseCheckBoxComponent
                                            Item {
                                                CheckBox {
                                                    anchors.right: parent.right
                                                    anchors.rightMargin: GC.standardTextHorizMargin
                                                    anchors.top: parent.top
                                                    anchors.bottom: parent.bottom
                                                    width: indicator.width
                                                }
                                            }
                                        }
                                        Component {
                                            id: phaseComboHarmonics
                                            ZComboBox {
                                                anchors.fill: parent
                                                arrayMode: true
                                                fontSize: theView.lineHeight * 0.4
                                                centerVertical: true
                                                model: [Z.tr('none')]
                                                textColor: GC.currentColorTable[uiType === 'U' ?
                                                                                    modelData.colorIndexU :
                                                                                    modelData.colorIndexI]
                                            }
                                        }
                                    }
                                }
                            }
                            ScrollBar.vertical: uiType === 'U' ? scrollbarU : scrollbarI
                        }
                    }
                }
                ScrollBar.horizontal: scrollbarHoriz
            }

            Column { // units right
                id: unitColumn
                anchors.bottom: bottomRow.top
                anchors.bottomMargin: theView.horizScrollbarOn ? theView.scrollBarWidth : 0
                anchors.right: vectorView.left
                anchors.rightMargin: jsonSourceInfo.extraLinesRequired * scrollBarWidth
                width: theView.headerColumnWidth
                Rectangle { // [ ] topmost
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: theView.lineHeightHeaderLine
                    border.color: Material.dividerColor
                    color: GC.tableShadeColor
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize: theView.headerPointSize * 0.8
                        text: '[ ]'
                    }
                }
                Repeater {
                    model: theView.uiModel
                    ListView {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        readonly property string uiType: modelData
                        model: uiType === 'U' ? linesU : linesI
                        height: model > 0 ? theView.linesStandardUI * theView.lineHeight : 0
                        clip: true
                        snapMode: ListView.SnapToItem
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Rectangle {
                            anchors.left: parent.left
                            width: parent.width
                            height: theView.lineHeight
                            border.color: Material.dividerColor
                            color: Material.backgroundColor
                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pointSize: headerPointSize * 0.8
                                font.family: FA.old
                                text: {
                                    switch(index) {
                                    case SourceModulePage.LineType.LineRMS:
                                        return uiType === 'U' ? 'V' : 'A'
                                    case SourceModulePage.LineType.LineAngle:
                                        return '°'
                                    default:
                                        return ''
                                    }
                                }
                            }
                        }
                        ScrollBar.vertical: uiType === 'U' ? scrollbarU : scrollbarI
                    }
                }
            }
            // we need tailored scrollbars to syncronize scrolling of dataTable's
            // and unitColumn's children
            ScrollBar {
                id: scrollbarU
                orientation: Qt.Vertical
                anchors.top: parent.top
                height: theView.linesStandardUI * theView.lineHeight
                anchors.topMargin: theView.lineHeightHeaderLine
                anchors.right: vectorView.left
                policy: theView.vertScrollbarOnU ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                width: theView.scrollBarWidth
            }
            ScrollBar {
                id: scrollbarI
                orientation: Qt.Vertical
                anchors.bottom: bottomRow.top
                anchors.bottomMargin: theView.horizScrollbarOn ? theView.scrollBarWidth : 0
                height: theView.linesStandardUI * theView.lineHeight
                anchors.right: vectorView.left
                policy: theView.vertScrollbarOnI ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                width: theView.scrollBarWidth
            }
            // we introduced scrollBarWidth depending upon screen resolution. This made
            // dataTable freak out on change of resolution: Scroll bar was painted in the
            // middle of our screen. So use a hand crafted scrollbar too.
            ScrollBar {
                id: scrollbarHoriz
                orientation: Qt.Horizontal
                anchors.bottom: bottomRow.top
                anchors.right: unitColumn.left
                anchors.left: headerColumnUI.right
                policy: theView.horizScrollbarOn ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                height: theView.scrollBarWidth
            }


            ///////////// right area /////////////
            readonly property real qAndHzLabelWidth: width / 32
            Rectangle {
                id: vectorView
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.top: parent.top
                anchors.bottom: angleQuickRow.top
                border.color: Material.dividerColor
                color: Material.backgroundColor

                PhasorDiagram {
                    anchors.fill: parent

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
            Row {
                id: angleQuickRow
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.bottom: pqRow.top
                height: theView.lineHeight
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "0°"
                }
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "180°"
                }
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "+15°"
                }
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "-15°"
                }
            }

            RowLayout {
                id: pqRow
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.bottom: bottomRow.top
                height: theView.lineHeight + (theView.horizScrollbarOn ? theView.scrollBarWidth : 0)
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: theView.buttonWidth * 0.55
                    ZComboBox {
                        id: comboPQ
                        anchors.fill: parent
                        arrayMode: true
                        fontSize: theView.comboFontSize
                        centerVertical: true
                        model: ['P', 'Q']
                    }
                }
                Label {
                    font.pointSize: theView.pointSize
                    Layout.fillWidth: true
                    horizontalAlignment: Label.AlignRight
                    Layout.preferredWidth: theView.buttonWidth
                    text: comboPQ.currentText === "P" ? "cos φ:" :"sin φ:"
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: theView.buttonWidth * 1.1
                    ZLineEdit {
                        anchors.fill: parent
                        pointSize: theView.pointSize
                    }
                }
                Label {
                    font.pointSize: theView.pointSize
                    Layout.preferredWidth: theView.qAndHzLabelWidth
                    text: "Q:"
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: theView.buttonWidth
                    ZComboBox {
                        anchors.fill: parent
                        arrayMode: true
                        fontSize: comboFontSize
                        centerVertical: true
                        model: ['1', '2', '3', '4']
                    }
                }
            }

            ///////////// full width bottom area /////////////
            Rectangle {
                id: bottomRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: theView.lineHeight
                border.color: Material.dividerColor
                color: Material.backgroundColor
                Item {
                    id: onOffRow
                    anchors.left: parent.left
                    anchors.right: frequencyRow.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    Button {
                        text: Z.tr("On")
                        width: theView.buttonWidth
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: theView.headerColumnWidth - jsonSourceInfo.extraLinesRequired * scrollBarWidth
                        topInset: 0
                        bottomInset: 0
                        font.pointSize: theView.pointSize * 0.9
                    }
                    CheckBox {
                        id: symmetricCheckbox
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Z.tr("symmetric")
                        font.pointSize: theView.pointSize * 0.9
                    }
                    Button {
                        text: Z.tr("Off")
                        width: theView.buttonWidth
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: theView.headerColumnWidth
                        topInset: 0
                        bottomInset: 0
                        font.pointSize: theView.pointSize * 0.9
                    }
                }
                Item {
                    id: frequencyRow
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: theView.widthRightArea
                    RowLayout {
                        anchors.fill: parent
                        Label {
                            font.pointSize: pointSize
                            Layout.fillWidth: true
                            text: Z.tr("Frequency:")
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: theView.buttonWidth * 1.1
                            visible: frequencyMode.varSelected
                            ZLineEdit {
                                anchors.fill: parent
                                pointSize: theView.pointSize
                            }
                        }
                        Label {
                            Layout.preferredWidth: theView.qAndHzLabelWidth
                            font.pointSize: theView.pointSize
                            visible: frequencyMode.varSelected
                            text: "Hz"
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: theView.buttonWidth
                            ZComboBox {
                                id: frequencyMode
                                anchors.fill: parent
                                arrayMode: true
                                fontSize: comboFontSize
                                centerVertical: true
                                model: [Z.tr('var'), Z.tr('sync')]
                                readonly property bool varSelected: targetIndex === 0
                            }
                        }
                    }
                }
            }
        }
    }
}
