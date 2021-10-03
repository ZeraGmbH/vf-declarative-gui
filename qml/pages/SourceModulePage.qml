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
    property var jsonSourceParamInfoRaw
    property var jsonSourceParamStatus
    // This is just for debugging purpose and can go soon
    onJsonSourceParamStatusChanged: {
        console.warn("jsonSourceParamStatus changed")
    }
    property string statusEntityName

    enum LineType {
        LineOnOff = 0,
        LineRMS,
        LineAngle,
        LineHarmonics
    }

    // convenient JSON property to simplify code below
    readonly property var jsonSourceParamInfoExtended: {
        // All changes on retJson will occore in jsonSourceParamInfoRaw either
        // but jsonSourceParamInfoRaw is set once and will not change by it's
        // own
        let retJson = jsonSourceParamInfoRaw

        // defaults for mandatory values
        retJson['maxValU'] = 0.0
        retJson['maxValI'] = 0.0
        retJson['extraLinesRequired'] = false

        // * calc U/I max values
        // * U/I/global harmonic support -> extraLinesRequired
        // Note: using array's forEach and arrow function causes qt-creator
        // freaking out on indentation. So loop the old-school way
        let arrUI = ['U', 'I']
        for(let numUI=0; numUI<arrUI.length; ++numUI) {
            let strUI = arrUI[numUI]
            let maxPhaseNum = jsonSourceParamInfoRaw[strUI + 'PhaseMax']
            for(var phase=1; phase<=maxPhaseNum; ++phase) {
                let phaseName = strUI + String(phase)
                if(jsonSourceParamInfoRaw[phaseName]) {
                    if(jsonSourceParamInfoRaw[phaseName].supportsHarmonics) {
                        retJson['extraLinesRequired'] = true
                        retJson['supportsHarmonics'+strUI] = true
                    }
                    if(jsonSourceParamInfoRaw[phaseName].maxVal > retJson['maxVal'+strUI]) {
                        retJson['maxVal'+strUI] = jsonSourceParamInfoRaw[phaseName].maxVal
                    }
                }
            }
        }
        // * generate columInfo as an ordered array of
        // { 'phasenum': .. 'phaseNameDisplay': .., 'colorIndexU': .., 'colorIndexI': .. }
        let columInfo = []
        let maxPhaseAll = Math.max(jsonSourceParamInfoRaw['UPhaseMax'],
                                   jsonSourceParamInfoRaw['IPhaseMax'])
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

    // To avoid waste of CPU by back & forth painting: Load view after jsonSourceParamInfoExtended is valid
    Loader {
        anchors.fill: parent
        sourceComponent: theViewComponent
        active: jsonSourceParamInfoExtended
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
            readonly property int linesU: jsonSourceParamInfoExtended.UPhaseMax ? (jsonSourceParamInfoExtended.supportsHarmonicsU ? 4: 3) : 0
            readonly property int linesI: jsonSourceParamInfoExtended.IPhaseMax ? (jsonSourceParamInfoExtended.supportsHarmonicsI ? 4: 3) : 0
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
            readonly property bool horizScrollbarOn: jsonSourceParamInfoExtended.columnInfo.length > 3
            readonly property bool vertScrollbarOnU: linesU > 3
            readonly property bool vertScrollbarOnI: linesI > 3

            // ------------------------ Layout ---------------------------------
            //
            //   headerColumnUI                       unitColumn
            //  /                                    /
            //  ----------------------------------------------------------------
            // | |                       PhaseOnOff | |                        |
            // | |             U         RMS        | |                        |
            // | |                       Angles     | |                        |
            // | |         dataTable                | |     vectorView         |
            // | |                       PhaseOnOff | |------------------------|
            // | |             I         RMS      <-|-|->       pqRow          |
            // | |                       Angles     | |     angleQuickRow      |
            //  ---------------------------------------------------------------|
            // |              onOffRow                |     frequencyRow       | bottomRow
            //  ----------------------------------------------------------------

            ///////////// left area /////////////
            Column { // U/I header left
                id: headerColumnUI
                anchors.bottom: bottomRow.top
                anchors.bottomMargin: theView.horizScrollbarOn ? theView.scrollBarWidth : 0
                anchors.left: parent.left
                width: theView.headerColumnWidth - jsonSourceParamInfoExtended.extraLinesRequired * scrollBarWidth
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
                contentWidth: columnWidth * jsonSourceParamInfoExtended.columnInfo.length
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
                            model: jsonSourceParamInfoExtended.columnInfo
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
                                    model: jsonSourceParamInfoExtended ? jsonSourceParamInfoExtended.columnInfo : 0
                                    Rectangle { // the field
                                        id: valueRect
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        border.color: Material.dividerColor
                                        color: Material.backgroundColor
                                        width: dataTable.columnWidth
                                        readonly property int columnIndex: index
                                        readonly property string phaseName: uiType + String(columnIndex+1)
                                        readonly property bool isAngleU1: uiType === 'U' &&
                                                                          rowIndex === SourceModulePage.LineType.LineAngle &&
                                                                          // TODO more common: first phase U
                                                                          columnIndex === 0
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
                                                    text: {
                                                        let val
                                                        switch(rowIndex) {
                                                        case SourceModulePage.LineType.LineRMS:
                                                            val = jsonSourceParamStatus[phaseName].rms
                                                            break
                                                        case SourceModulePage.LineType.LineAngle:
                                                            val = jsonSourceParamStatus[phaseName].angle
                                                            break
                                                        }
                                                        return val
                                                    }
                                                    function doApplyInput(newText) {
                                                        switch(rowIndex) {
                                                        case SourceModulePage.LineType.LineRMS:
                                                            jsonSourceParamStatus[phaseName].rms = parseFloat(newText)
                                                            break
                                                        case SourceModulePage.LineType.LineAngle:
                                                            jsonSourceParamStatus[phaseName].angle = parseFloat(newText)
                                                            break
                                                        }
                                                        return true
                                                    }
                                                    readonly property var validatorInfo: {
                                                        let min, max, decimals = 0.0
                                                        switch(rowIndex) {
                                                        case SourceModulePage.LineType.LineRMS:
                                                            min = jsonSourceParamInfoExtended[phaseName]['params']['rms'].min
                                                            max = jsonSourceParamInfoExtended[phaseName]['params']['rms'].max
                                                            decimals = jsonSourceParamInfoExtended[phaseName]['params']['rms'].decimals
                                                            break
                                                        case SourceModulePage.LineType.LineAngle:
                                                            min = jsonSourceParamInfoExtended[phaseName]['params']['angle'].min
                                                            max = jsonSourceParamInfoExtended[phaseName]['params']['angle'].max
                                                            decimals = jsonSourceParamInfoExtended[phaseName]['params']['angle'].decimals
                                                            break
                                                        }
                                                        return { 'min': min, 'max': max, 'decimals': decimals}
                                                    }
                                                    validator: ZDoubleValidator {
                                                        bottom: valueEdit.validatorInfo.min
                                                        top: valueEdit.validatorInfo.max
                                                        decimals: valueEdit.validatorInfo.decimals
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
                                                    checked: jsonSourceParamStatus[phaseName].on
                                                    onClicked: jsonSourceParamStatus[phaseName].on = checked
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
                anchors.rightMargin: jsonSourceParamInfoExtended.extraLinesRequired * scrollBarWidth
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
                anchors.bottom: pqRow.top
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
            RowLayout {
                id: pqRow
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.bottom: angleQuickRow.top
                height: theView.lineHeight + (theView.horizScrollbarOn ? theView.scrollBarWidth : 0)
                readonly property int bottomFreeSpace: 1
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: theView.buttonWidth * 0.55
                    ZComboBox {
                        id: comboPQ
                        anchors.fill: parent
                        anchors.bottomMargin: pqRow.bottomFreeSpace
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
                        textField.topPadding: 9
                        textField.bottomPadding: 9
                        validator: ZDoubleValidator {
                            bottom: -1.0
                            top: 1.0
                            // with we can display 5 digits bur sign is one of them
                            decimals: Math.min(4, Math.min(GC.digitsTotal-1, GC.decimalPlaces))
                        }
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
                        anchors.bottomMargin: pqRow.bottomFreeSpace
                        arrayMode: true
                        fontSize: comboFontSize
                        centerVertical: true
                        model: ['1', '2', '3', '4']
                    }
                }
            }
            Row {
                id: angleQuickRow
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.bottom: bottomRow.top
                height: theView.lineHeight
                readonly property int rightFreeSpace: 2
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    rightInset: angleQuickRow.rightFreeSpace
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "0°"
                }
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    rightInset: angleQuickRow.rightFreeSpace
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "180°"
                }
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    rightInset: angleQuickRow.rightFreeSpace
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
            ///////////// full width bottom area /////////////
            Rectangle {
                id: bottomRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: theView.lineHeight
                border.color: Material.dividerColor
                color: Material.backgroundColor
                readonly property int topFreeSpace: 2
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
                        topInset: bottomRow.topFreeSpace
                        bottomInset: 0
                        anchors.left: parent.left
                        anchors.leftMargin: theView.headerColumnWidth - jsonSourceParamInfoExtended.extraLinesRequired * scrollBarWidth
                        font.pointSize: theView.pointSize * 0.9
                        onClicked: {
                            jsonSourceParamStatus.on = true
                            VeinEntity.getEntity("SourceModule1")[statusEntityName] = jsonSourceParamStatus
                        }
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
                        topInset: bottomRow.topFreeSpace
                        bottomInset: 0
                        anchors.right: parent.right
                        anchors.rightMargin: theView.headerColumnWidth + jsonSourceParamInfoExtended.extraLinesRequired * scrollBarWidth
                        font.pointSize: theView.pointSize * 0.9
                        onClicked: {
                            jsonSourceParamStatus.on = false
                            VeinEntity.getEntity("SourceModule1")[statusEntityName] = jsonSourceParamStatus
                        }
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
                                validator: ZDoubleValidator {
                                    bottom: jsonSourceParamInfoExtended['Frequency']['params']['val'].min
                                    top: jsonSourceParamInfoExtended['Frequency']['params']['val'].max
                                    decimals: jsonSourceParamInfoExtended['Frequency']['params']['val'].decimals
                                }
                                text: jsonSourceParamStatus['Frequency'].val
                                function doApplyInput(newText) {
                                    jsonSourceParamStatus['Frequency'].val = parseFloat(newText)
                                    return true
                                }
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
                                anchors.topMargin: bottomRow.topFreeSpace
                                arrayMode: true
                                fontSize: comboFontSize
                                centerVertical: true
                                model: jsonSourceParamInfoExtended.Frequency.params.type.list
                                readonly property bool varSelected: currentText === "var"
                                function setInitialIndex() {
                                    currentIndex = model.indexOf(jsonSourceParamStatus.Frequency.type)
                                }
                                onModelChanged: setInitialIndex()
                                onSelectedTextChanged: {
                                    jsonSourceParamStatus.Frequency.type = selectedText
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
