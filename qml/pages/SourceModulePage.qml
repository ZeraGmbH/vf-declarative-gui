import QtQuick 2.14
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import DeclarativeJson 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
import ZeraFa 1.0
import '../controls'

// TODOs / Ideas
// * Missing Feature: Phase sequence: Idea: Can we abuse phase sequence
//   indicator in toolbar to save pixels?
// * Bug/Feature: Current-only sources vector display: Suggestion: Add shadow
//   data/vectors for voltage
// * Bug: On switch on previous load set is displayed shortly (only visible on
//   device
// * Bug: Opening source GUI for multiple devices is very slow
// * Feature: Make U/I buttons to select all / no phase (or add 3-state CheckBox??)
// * Feature: Introduce two-finger rotate gesture for vector diagram
// * Bug: Sync/Var is not sent to source module
// * Feature: Add an indicator right to 'ON' button to show that user has made
//   changes since last (active) switch on
// * Feature: Add an option to fade Phase 2 & 3 for better understanding of angle
//   quadrant
// * Feature: Add harmonics editor...
// * Feature: Add sound on clicks particularly on sequence of clicks caused by
//   long press of +-15°

Item {
    id: root

    // params for createObject
    property var jsonParamInfo
    property var jsonState
    property var declarativeJsonItem
    property var sendParamsToServer

    enum LineType {
        LineOnOff = 0,
        LineRMS,
        LineAngle,
        LineHarmonics
    }
    property var arrJsonTypeKey: [ // json keys for enum LineType
        "on",
        "rms",
        "angle",
        "not-implemented"
    ]

    // On/off wait popup
    onJsonStateChanged: {
        if(jsonState.busy) {
            waitPopup.startWait((declarativeJsonItem.on ? Z.tr("Switching on") : Z.tr("Switching off"))+" "+ jsonParamInfo.Name)
        }
        else {
            waitPopup.stopWait(jsonState.warnings, jsonState.errors, null)
        }
    }
    WaitTransaction {
        id: waitPopup
        animationComponent: AnimationSlowBits { }
    }

    Component.onCompleted: {
        symmetrize()
    }

    // convenient properties for layout vertical
    readonly property int linesStandardUI: 3 // RMS / Angle / OnOff
    readonly property real lineHeight: height > 0 ? (height / (linesStandardUI*2 + 2)) : 10 // +2 header+bottom line
    readonly property real lineHeightHeaderLine: lineHeight - (horizScrollbarOn ? scrollBarWidth : 0)
    readonly property int linesU: jsonParamInfo.UPhaseMax ? (jsonParamInfo.supportsHarmonicsU ? 4: 3) : 0
    readonly property int linesI: jsonParamInfo.IPhaseMax ? (jsonParamInfo.supportsHarmonicsI ? 4: 3) : 0
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
    // convenient properties for layout horizontal
    readonly property int columnsStandardUI: 3
    readonly property real comboFontSize: pointSize * 1.25
    readonly property real widthLeftArea: width * 0.6
    readonly property real widthRightArea: width - widthLeftArea
    readonly property real headerColumnWidth: widthLeftArea * 0.12
    readonly property real buttonWidth: widthRightArea / 4
    readonly property real columnWidth: (widthLeftArea - 2*headerColumnWidth) / columnsStandardUI
    readonly property real moveTableRightForFewPhasors:
        jsonParamInfo.maxPhaseAll >= columnsStandardUI ?
            0 : (columnsStandardUI - jsonParamInfo.maxPhaseAll) * columnWidth

    // convenient properties fonts
    readonly property real headerPointSize: pointSize * 1.5
    readonly property real pointSize: (height > 0) ? (height / 30) : 10.0

    // convenient properties scrollbars
    readonly property int scrollBarWidth: width > 100 ? width / 100 : 8
    readonly property bool horizScrollbarOn: jsonParamInfo.columnInfo.length > 3
    readonly property bool vertScrollbarOnU: linesU > 3
    readonly property bool vertScrollbarOnI: linesI > 3

    // angle helpers
    readonly property real toRadianFactor: 2*Math.PI/360
    function angleModulo(angle) {
        // just a little of a hack but due to validators only autoAngle
        // may cause negative angles
        return (angle+36000) % 360
    }
    function symmetrize() {
        if(symmetricCheckbox.checked) {
            let angleOffset = 120.0
            let angleU = 0.0
            let angleI = declarativeJsonItem["I1"] ? declarativeJsonItem["I1"].angle : 0.0
            let rmsU = declarativeJsonItem["U1"] ? declarativeJsonItem["U1"].rms : 0.0
            let rmsI = declarativeJsonItem["I1"] ? declarativeJsonItem["I1"].rms : 0.0
            for(let phase=2; phase<=3; phase++) {
                let jsonPhaseNameU = 'U%1'.arg(phase)
                if(declarativeJsonItem[jsonPhaseNameU]) {
                    let decimals = jsonParamInfo[jsonPhaseNameU]['params']['angle'].decimals
                    declarativeJsonItem[jsonPhaseNameU].angle = Number(FT.formatNumber(angleModulo(angleU + angleOffset), decimals))
                    declarativeJsonItem[jsonPhaseNameU].rms = rmsU
                }
                let jsonPhaseNameI = 'I%1'.arg(phase)
                if(declarativeJsonItem[jsonPhaseNameI]) {
                    let decimals = jsonParamInfo[jsonPhaseNameI]['params']['angle'].decimals
                    declarativeJsonItem[jsonPhaseNameI].angle = Number(FT.formatNumber(angleModulo(angleI + angleOffset), decimals))
                    declarativeJsonItem[jsonPhaseNameI].rms = rmsI
                }
                angleOffset += 120
            }

        }
    }
    function autoAngle(isAbs, diffAngleSet) {
        let defaultAngle = 0.0
        for(let phase=1; phase<=3; phase++) {
            let jsonPhaseNameU = 'U%1'.arg(phase)
            let angleUCurr = defaultAngle
            if(declarativeJsonItem[jsonPhaseNameU]) {
                angleUCurr = declarativeJsonItem[jsonPhaseNameU].angle
            }
            let jsonPhaseNameI = 'I%1'.arg(phase)
            let angleICurr = defaultAngle
            if(declarativeJsonItem[jsonPhaseNameI]) {
                angleICurr = declarativeJsonItem[jsonPhaseNameI].angle
            }

            let angleINew
            if(isAbs) {
                angleINew = angleUCurr + diffAngleSet
            }
            else {
                angleINew = angleICurr + diffAngleSet
            }

            if(declarativeJsonItem[jsonPhaseNameI]) {
                let decimals = jsonParamInfo[jsonPhaseNameI]['params']['angle'].decimals
                declarativeJsonItem[jsonPhaseNameI].angle = Number(FT.formatNumber(angleModulo(angleINew), decimals))
            }
            defaultAngle += 120
        }
    }
    // Phasor diagramm max values
    readonly property var maxVoltage: {
        let max = 1e-6 // avoid division by 0
        for(let phase=1; phase<=3; phase++) {
            let jsonPhaseNameU = 'U%1'.arg(phase)
            if(declarativeJsonItem[jsonPhaseNameU]) {
                max = Math.max(max, declarativeJsonItem[jsonPhaseNameU].rms)
            }
        }
        return max
    }
    readonly property var maxCurrent: {
        let max = 1e-6 // avoid division by 0
        for(let phase=1; phase<=3; phase++) {
            let jsonPhaseNameI = 'I%1'.arg(phase)
            if(declarativeJsonItem[jsonPhaseNameI]) {
                max = Math.max(max, declarativeJsonItem[jsonPhaseNameI].rms)
            }
        }
        return max
    }

    // --------------------- Items Layout ------------------------------
    //
    //   headerColumnUI                       unitColumn
    //  /                                    /
    //  ----------------------------------------------------------------
    // | |                       PhaseOnOff | |                        |
    // | |             U         RMS        | |                        |
    // | |                       Angles     | |                        |
    // | |         dataTable                | |     phasorView         |
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
        anchors.bottomMargin: horizScrollbarOn ? scrollBarWidth : 0
        anchors.left: parent.left
        anchors.leftMargin: moveTableRightForFewPhasors
        width: headerColumnWidth - jsonParamInfo.extraLinesRequired * scrollBarWidth
        GridRect { // empty topmost
            anchors.left: parent.left
            anchors.right: parent.right
            height: lineHeightHeaderLine
            color: GC.tableShadeColor
        }
        Repeater { // U/I rectangles
            model: uiModel
            GridRect {
                anchors.left: parent.left
                anchors.right: parent.right
                height: linesStandardUI * lineHeight
                color: GC.tableShadeColor
                Label {
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: headerPointSize
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
        anchors.topMargin: linesU > 0 ? 0 : linesStandardUI * lineHeight
        anchors.bottom: bottomRow.top
        anchors.left: headerColumnUI.right
        anchors.right: unitColumn.left
        contentWidth: columnWidth * jsonParamInfo.columnInfo.length
        contentHeight: height - (horizScrollbarOn ? scrollBarWidth : 0)
        clip: true
        Column { // header / U table / I table
            width: dataTable.contentWidth
            height: dataTable.contentHeight

            Row { // header row
                anchors.left: parent.left
                anchors.right: parent.right
                height: lineHeightHeaderLine
                Repeater {
                    model: jsonParamInfo.columnInfo
                    GridRect {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: columnWidth
                        color: GC.tableShadeColor
                        Label {
                            textFormat: Text.PlainText
                            anchors.fill: parent
                            anchors.rightMargin: GC.standardTextHorizMargin
                            horizontalAlignment: Label.AlignRight
                            verticalAlignment: Label.AlignVCenter
                            font.pointSize: headerPointSize
                            text: modelData.phaseNameDisplay
                            color: GC.currentColorTable[modelData.colorIndexU]
                        }
                    }
                }
            }

            Repeater {  // a set of ListView for U & I
                model: uiModel
                ListView { // 3+ lines
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: lineHeight * linesStandardUI
                    readonly property string uiType: modelData
                    model: uiType === 'U' ? linesU : linesI
                    snapMode: ListView.SnapToItem
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    delegate: Row { // row of phase fields
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: lineHeight
                        readonly property int rowIndex: index
                        Repeater {
                            model: jsonParamInfo.columnInfo
                            GridRect { // the field
                                id: valueRect
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: columnWidth
                                readonly property int columnIndex: index
                                readonly property string jsonPhaseName: uiType + String(columnIndex+1)
                                property var jsonDataBase: declarativeJsonItem[jsonPhaseName]
                                readonly property var jsonParamInfoBase: jsonParamInfo[jsonPhaseName]['params']
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
                                            pointSize: root.pointSize * 1.2
                                            enabled: !valueRect.isAngleU1 &&
                                                     (!symmetricCheckbox.checked || columnIndex == 0 || columnIndex >= 3)
                                            visible: enabled
                                            textField.color: GC.currentColorTable[uiType === 'U' ?
                                                                                      modelData.colorIndexU :
                                                                                      modelData.colorIndexI]
                                            text: jsonDataBase[arrJsonTypeKey[rowIndex]]

                                            function doApplyInput(newText) {
                                                if(rowIndex === SourceModulePage.LineType.LineAngle) { // correct negative angles immediately
                                                    let angle = Number(newText)
                                                    angle = angleModulo(angle)
                                                    newText = FT.formatNumber(angle, jsonParamInfoBase['angle'].decimals)
                                                }
                                                jsonDataBase[arrJsonTypeKey[rowIndex]] = parseFloat(newText)
                                                if(jsonPhaseName == 'U1' || jsonPhaseName == 'I1') {
                                                    symmetrize()
                                                }
                                                discardInput() // Long reasoning for this at sin/cos field
                                                return false
                                            }
                                            readonly property var validatorInfo: {
                                                let min, max, decimals = 0.0
                                                switch(rowIndex) {
                                                case SourceModulePage.LineType.LineRMS:
                                                    min = jsonParamInfoBase['rms'].min
                                                    max = jsonParamInfoBase['rms'].max
                                                    decimals = jsonParamInfoBase['rms'].decimals
                                                    break
                                                case SourceModulePage.LineType.LineAngle:
                                                    min = -jsonParamInfoBase['angle'].max // we allow users entering +/-
                                                    max = jsonParamInfoBase['angle'].max
                                                    decimals = jsonParamInfoBase['angle'].decimals
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
                                            textFormat: Text.PlainText
                                            visible: !valueEdit.visible
                                            anchors.fill: parent
                                            anchors.rightMargin: GC.standardTextHorizMargin
                                            font.pointSize: pointSize * 1.2
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
                                            checked: jsonDataBase.on
                                            onClicked: jsonDataBase.on = checked
                                        }
                                    }
                                }
                                Component {
                                    id: phaseComboHarmonics
                                    ZComboBox {
                                        anchors.fill: parent
                                        arrayMode: true
                                        fontSize: lineHeight * 0.4
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
        anchors.bottomMargin: horizScrollbarOn ? scrollBarWidth : 0
        anchors.right: phasorView.left
        anchors.rightMargin: jsonParamInfo.extraLinesRequired * scrollBarWidth
        width: headerColumnWidth
        GridRect { // [ ] topmost
            anchors.left: parent.left
            anchors.right: parent.right
            height: lineHeightHeaderLine
            color: GC.tableShadeColor
            Label {
                textFormat: Text.PlainText
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: headerPointSize
                text: '[ ]'
            }
        }
        Repeater {
            model: uiModel
            ListView {
                anchors.left: parent.left
                anchors.right: parent.right
                readonly property string uiType: modelData
                model: uiType === 'U' ? linesU : linesI
                height: model > 0 ? linesStandardUI * lineHeight : 0
                clip: true
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                delegate: GridRect {
                    anchors.left: parent.left
                    width: parent.width
                    height: lineHeight
                    Label {
                        textFormat: Text.PlainText
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pointSize: pointSize
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
        height: linesStandardUI * lineHeight
        anchors.topMargin: lineHeightHeaderLine
        anchors.right: phasorView.left
        policy: vertScrollbarOnU ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        width: scrollBarWidth
    }
    ScrollBar {
        id: scrollbarI
        orientation: Qt.Vertical
        anchors.bottom: bottomRow.top
        anchors.bottomMargin: horizScrollbarOn ? scrollBarWidth : 0
        height: linesStandardUI * lineHeight
        anchors.right: phasorView.left
        policy: vertScrollbarOnI ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        width: scrollBarWidth
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
        policy: horizScrollbarOn ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        height: scrollBarWidth
    }


    ///////////// right area /////////////
    readonly property real qAndHzLabelWidth: buttonWidth * 0.35
    GridRect {
        id: phasorView
        anchors.right: parent.right
        width: widthRightArea
        anchors.top: parent.top
        anchors.bottom: pqRow.top

        PhasorDiagramEx {
            id: phasorDiagram
            anchors.fill: parent
            maxNominalFactor: 1.2
            readonly property var arrRms: { // rms + phase on
                let arr = []
                for(var phase=1; phase<=3; phase++) {
                    let jsonPhaseName = 'U%1'.arg(phase)
                    let jsonDataBase = declarativeJsonItem[jsonPhaseName]
                    let rmsVal = jsonDataBase && jsonDataBase.on ?
                            jsonDataBase.rms : 0.0
                    arr.push(rmsVal)
                }
                for(phase=1; phase<=3; phase++) {
                    let jsonPhaseName = 'I%1'.arg(phase)
                    let jsonDataBase = declarativeJsonItem[jsonPhaseName]
                    let rmsVal = jsonDataBase && jsonDataBase.on ?
                            jsonDataBase.rms : 0.0
                    arr.push(rmsVal)
                }
                return arr
            }
            readonly property var arrRmsXY: { // rms + phase on -> x/y
                let arr = []
                for(var phase=1; phase<=3; phase++) {
                    let jsonPhaseName = 'U%1'.arg(phase)
                    let jsonDataBase = declarativeJsonItem[jsonPhaseName]
                    let angleVal = jsonDataBase ? jsonDataBase.angle : 0.0
                    let xyArr = []
                    xyArr[0] = Math.sin(toRadianFactor * angleVal) * arrRms[phase-1]
                    xyArr[1] = -Math.cos(toRadianFactor * angleVal) * arrRms[phase-1]
                    arr.push(xyArr)
                }
                for(phase=1; phase<=3; phase++) {
                    let jsonPhaseName = 'I%1'.arg(phase)
                    let jsonDataBase = declarativeJsonItem[jsonPhaseName]
                    let angleVal = jsonDataBase ? jsonDataBase.angle : 0.0
                    let xyArr = []
                    xyArr[0] = Math.sin(toRadianFactor * angleVal) * arrRms[phase+3-1]
                    xyArr[1] = -Math.cos(toRadianFactor * angleVal) * arrRms[phase+3-1]
                    arr.push(xyArr)
                }
                return arr
            }

            maxVoltage: root.maxVoltage * maxNominalFactor
            maxCurrent: root.maxCurrent * maxNominalFactor

            vector1Data: vectorView != PhasorDiagram.VIEW_THREE_PHASE ?
                             [arrRmsXY[0][0],arrRmsXY[0][1]] :
                             [arrRmsXY[0][0]-arrRmsXY[1][0], arrRmsXY[0][1]-arrRmsXY[1][1]] /* UL1-UL2 */
            vector2Data: vectorView != PhasorDiagram.VIEW_THREE_PHASE ?
                             [arrRmsXY[1][0],arrRmsXY[1][1]] :
                             [arrRmsXY[2][0]-arrRmsXY[1][0], arrRmsXY[2][1]-arrRmsXY[1][1]] /* UL3-UL2 */
            vector3Data: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? [arrRmsXY[2][0],arrRmsXY[2][1]] : [0,0]
            vector4Data: [arrRmsXY[3][0],arrRmsXY[3][1]]
            vector5Data: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? [arrRmsXY[4][0],arrRmsXY[4][1]] : [0,0]
            vector6Data: [arrRmsXY[5][0],arrRmsXY[5][1]]

            vector1Label: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? "UL1" : "UL1-UL2"
            vector2Label: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? "UL2" : "UL3-UL2" // same as ACT_DFTPP2
            vector3Label: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? "UL3" : "UL3-UL1"
            vector4Label: "IL1"
            vector5Label: "IL2"
            vector6Label: "IL3"

            vectorView: GC.vectorMode
            din410: !GC.vectorIecMode
            currentVisible: true

            Popup {
                id: phasorViewPopup
                x: Math.round((parent.width - width))
                y: Math.round((parent.height - height))
                width: buttonWidth * 2
                readonly property real labelWidth: width*0.3
                height: lineHeight * 2 /* number of lines */ + bottomRow.topFreeSpace
                verticalPadding: 0
                horizontalPadding: 0
                Label {
                    text: "➚"
                    anchors.left: parent.left
                    width: phasorViewPopup.labelWidth
                    horizontalAlignment: Label.AlignHCenter
                    anchors.verticalCenter: dinIECSelector.verticalCenter
                    font.pointSize: pointSize * 1.5
                }
                ZComboBox {
                    id: dinIECSelector
                    height: lineHeight
                    anchors.right: parent.right
                    width: phasorViewPopup.width - phasorViewPopup.labelWidth
                    anchors.top: parent.top
                    fontSize: comboFontSize
                    arrayMode: true
                    model: ["DIN410", "IEC387"]
                    targetIndex: GC.vectorIecMode
                    property bool popupOpened: popup.opened
                    onPopupOpenedChanged: {
                        if(!popupOpened) {
                            phasorViewPopup.close()
                        }
                    }
                    onTargetIndexChanged: {
                        GC.setVectorIecMode(targetIndex)
                    }
                }
                Label {
                    text: "➚"
                    anchors.left: parent.left
                    width: phasorViewPopup.labelWidth
                    horizontalAlignment: Label.AlignHCenter
                    anchors.verticalCenter: viewModeSelector.verticalCenter
                    font.pointSize: pointSize * 1.5
                }
                ZComboBox {
                    id: viewModeSelector
                    height: lineHeight
                    anchors.right: parent.right
                    width: phasorViewPopup.width - phasorViewPopup.labelWidth
                    anchors.bottom: parent.bottom
                    centerVertical: true
                    fontSize: comboFontSize
                    arrayMode: true
                    model: ["U  PN", "U  △", "U  ∠"]
                    targetIndex: GC.vectorMode
                    property bool popupOpened: popup.opened
                    onPopupOpenedChanged: {
                        if(!popupOpened) {
                            phasorViewPopup.close()
                        }
                    }
                    onTargetIndexChanged: {
                        GC.setVectorMode(targetIndex)
                    }
                }
            }
            Button {
                id: phasorViewSettingsButton
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: lineHeight * 0.8
                width: height
                topInset: 1
                bottomInset: 2
                rightInset: topInset
                leftInset: topInset
                font.pointSize: pointSize
                font.family: FA.old
                text: FA.fa_cogs
                onClicked: {
                    phasorViewPopup.open()
                }
            }
        }
    }
    RowLayout {
        id: pqRow
        anchors.right: parent.right
        width: widthRightArea
        anchors.bottom: angleQuickRow.top
        height: lineHeight + (horizScrollbarOn ? scrollBarWidth : 0)
        readonly property int bottomFreeSpace: 1
        function calcAverageAngleDiff() {
            let arrAngleDiff = []
            let activePhases = 0
            let defaultAngle = 0.0 // for sources with current (or voltage??) only
            for(let phase=1; phase<=3; phase++) {
                let angleDiff = 0.0
                let jsonPhaseNameU = 'U%1'.arg(phase)
                let jsonPhaseNameI = 'I%1'.arg(phase)
                let jsonDataU = declarativeJsonItem[jsonPhaseNameU]
                let jsonDataI = declarativeJsonItem[jsonPhaseNameI]
                let angleValU = jsonDataU ? jsonDataU.angle : defaultAngle
                let angleValI = jsonDataI ? jsonDataI.angle : defaultAngle
                angleDiff = angleModulo(angleValI - angleValU)
                arrAngleDiff.push(angleDiff)
                defaultAngle += 120.0
                if(jsonDataU || jsonDataI) {
                    ++activePhases
                }
            }
            let angleDiffSum = 0.0
            arrAngleDiff.forEach(element => angleDiffSum+=element)
            let averageAngleDiff = angleDiffSum / (activePhases ? activePhases : 1)
            return averageAngleDiff
        }
        readonly property real cosSinAverAngle: {
            // TODO ???: do we have to rework this to an 'energy-weighted' factor
            let averageAngleDiff = calcAverageAngleDiff()
            let sinCos = comboPQ.currentText === "P" ? Math.cos(toRadianFactor * averageAngleDiff) : Math.sin(toRadianFactor * averageAngleDiff)
            return sinCos
        }
        readonly property int quadrantZeroBased: {
            let averageAngleDiff = calcAverageAngleDiff()
            return Math.floor(averageAngleDiff / 90)
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: buttonWidth * 0.55
            ZComboBox {
                id: comboPQ
                anchors.fill: parent
                anchors.bottomMargin: pqRow.bottomFreeSpace
                arrayMode: true
                fontSize: comboFontSize
                model: ['P', 'Q']
            }
        }
        Label {
            textFormat: Text.PlainText
            font.pointSize: pointSize
            Layout.fillWidth: true
            horizontalAlignment: Label.AlignRight
            Layout.preferredWidth: buttonWidth
            text: comboPQ.currentText === "P" ? "cos φ:" :"sin φ:"
        }
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: buttonWidth
            ZLineEdit {
                anchors.fill: parent
                pointSize: root.pointSize
                textField.topPadding: 9
                textField.bottomPadding: 9
                validator: ZDoubleValidator {
                    id: cosCosSinValidator
                    bottom: -1.0
                    top: 1.0
                    decimals: Math.min(3, Math.min(GC.digitsTotal-1, GC.decimalPlaces))
                }
                text: FT.formatNumber(pqRow.cosSinAverAngle, cosCosSinValidator.decimals)
                function doApplyInput(newText) {
                    let newCosSin = Number(newText)
                    let angleACosSin = (comboPQ.currentText === "P" ? Math.acos(newCosSin) : Math.asin(newCosSin)) / toRadianFactor
                    // Try to be of support: Due to limited digits it is not possible to
                    // reach a load exactly so round the angle a bit
                    let difftoNextInteger = angleACosSin - Math.round(angleACosSin)
                    if(Math.abs(difftoNextInteger) < 0.05) {
                        angleACosSin = angleACosSin - difftoNextInteger
                    }

                    // let's move around as few as possible
                    let averageAngleDiffCurr = pqRow.calcAverageAngleDiff()+0.0001 // 0.0001: prefer higher quadrants
                    let angleAlternate = comboPQ.currentText === "P" ? -angleACosSin : -(angleACosSin-90)+90
                    let diffAngleACosSin = angleModulo(angleACosSin - averageAngleDiffCurr)
                    let diffAngleAlternate = angleModulo(angleAlternate - averageAngleDiffCurr)
                    // scale down to 0-180° (kind of angle abs)
                    if(diffAngleACosSin > 180) {
                        diffAngleACosSin = 360-diffAngleACosSin
                    }
                    if(diffAngleAlternate > 180) {
                        diffAngleAlternate = 360-diffAngleAlternate
                    }
                    let angle = Math.abs(diffAngleACosSin) < Math.abs(diffAngleAlternate) ? angleACosSin : angleAlternate
                    autoAngle(true, angle)
                    // Our angle snapping above can lead to following situation:
                    // * current cos = 0.7071
                    // * user enters 0.707
                    // => Ruslting angles are same as before => no recalculation of sin/cos
                    // => fiels remains green
                    // So after angles make sure
                    discardInput() // This is what ZLineEdit does as soon as new value is set
                    // We have no unit tests yet but setting values sin/cos=0 are of interest - so test
                    // cos: test with +10°/-10° and set cos=0. Expected 90°/-90°
                    // cos: test with +190°/170° and set cos=0. Expected 270°/90°
                    // sin: test with +80°/100° and set sin=0. Expected 0°/180°
                    // sin: test with +260°/280° and set sin=0. Expected 180°/0°
                    // repeat angles but set sin/cos to +-0.1 (for proper digits)
                    return false
                }
            }
        }
        Label {
            textFormat: Text.PlainText
            font.pointSize: pointSize
            Layout.preferredWidth: qAndHzLabelWidth
            horizontalAlignment : Label.AlignRight
            text: "Q:"
        }
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: buttonWidth
            ZComboBox {
                anchors.fill: parent
                anchors.bottomMargin: pqRow.bottomFreeSpace
                arrayMode: true
                fontSize: comboFontSize
                model: {
                    // current quadrant is minimum content
                    let entryList = []
                    let currenQuadrantZero = pqRow.quadrantZeroBased
                    entryList.push(String(currenQuadrantZero+1))
                    // check for alternate quadrant
                    let cosSin = pqRow.cosSinAverAngle
                    let absCosSin = Math.abs(cosSin)
                    // cos/sin = 1 do not have alternate quadrants
                    if(absCosSin < 1-1e-6 ) {
                        let averageAngleCurr = pqRow.calcAverageAngleDiff()
                        let angleAlternate = comboPQ.currentText === "P" ? -averageAngleCurr : -(averageAngleCurr-90)+90
                        angleAlternate= angleModulo(angleAlternate)
                        let alternateQuadrantZero = Math.floor(angleAlternate / 90)
                        entryList.push(String(alternateQuadrantZero+1))
                    }
                    entryList.sort()
                    return entryList
                }
                currentIndex: {
                    let currenQuadrant = pqRow.quadrantZeroBased+1
                    let idx = model.findIndex(element => element === String(currenQuadrant))
                    return idx
                }
                automaticIndexChange: true
                onSelectedTextChanged: {
                    let quadrantString = model[targetIndex]
                    // filter out user change input
                    let averageAngleCurr = pqRow.calcAverageAngleDiff()
                    let angleAlternate = comboPQ.currentText === "P" ? -averageAngleCurr : -(averageAngleCurr-90)+90
                    angleAlternate = angleModulo(angleAlternate)
                    autoAngle(true, angleAlternate)
                }
            }
        }
    }
    Row { // angle buttons
        id: angleQuickRow
        anchors.right: parent.right
        width: widthRightArea
        anchors.bottom: bottomRow.top
        height: lineHeight
        readonly property int rightFreeSpace: 2
        Button {
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            rightInset: angleQuickRow.rightFreeSpace
            topInset: 0
            bottomInset: 0
            font.pointSize: pointSize * 0.9
            text: "0°"
            onClicked: autoAngle(true, 0.0)
        }
        Button {
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            rightInset: angleQuickRow.rightFreeSpace
            topInset: 0
            bottomInset: 0
            font.pointSize: pointSize * 0.9
            text: "180°"
            onClicked: autoAngle(true, 180.0)
        }
        Button {
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            rightInset: angleQuickRow.rightFreeSpace
            topInset: 0
            bottomInset: 0
            font.pointSize: pointSize * 0.9
            text: "-15°"
            autoRepeat: true
            //autoRepeatInterval: 150
            onReleased: autoAngle(false, -15) // onClicked is slow on repetitions
        }
        Button {
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            topInset: 0
            bottomInset: 0
            font.pointSize: pointSize * 0.9
            text: "+15°"
            autoRepeat: true
            onReleased: autoAngle(false, 15)
        }
    }
    ///////////// full width bottom area /////////////
    GridRect {
        id: bottomRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: lineHeight
        readonly property int topFreeSpace: 2
        Item {
            id: onOffRow
            anchors.left: parent.left
            anchors.right: frequencyRow.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            Button {
                text: Z.tr("On")
                width: buttonWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                topInset: bottomRow.topFreeSpace
                bottomInset: 0
                anchors.left: parent.left
                anchors.leftMargin: headerColumnWidth - jsonParamInfo.extraLinesRequired * scrollBarWidth
                font.pointSize: pointSize * 0.9
                onClicked: {
                    declarativeJsonItem.on = true
                    sendParamsToServer()
                }
                Rectangle {
                    id: buttonOnRect
                    anchors.fill: parent
                    anchors.topMargin: bottomRow.topFreeSpace
                    color: "red"
                    visible: declarativeJsonItem.on && !jsonState.busy
                    SequentialAnimation on opacity {
                        running: visible
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0.20
                            to: 0.35
                            duration: 1500
                        }
                        NumberAnimation {
                            from: 0.35
                            to: 0.20
                            duration: 1500
                        }
                    }
                }
            }
            CheckBox {
                id: symmetricCheckbox
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: Z.tr("symmetric")
                font.pointSize: pointSize * 0.9
                checked: GC.sourceSymmetric
                onCheckedChanged: {
                    symmetrize()
                }
            }
            Button {
                text: Z.tr("Off")
                width: buttonWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                topInset: bottomRow.topFreeSpace
                bottomInset: 0
                anchors.right: parent.right
                anchors.rightMargin: headerColumnWidth + jsonParamInfo.extraLinesRequired * scrollBarWidth
                font.pointSize: pointSize * 0.9
                onClicked: {
                    declarativeJsonItem.on = false
                    sendParamsToServer()
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: bottomRow.topFreeSpace
                    color: "#206040" // taken from MainToolBar - it is near by
                    opacity: 0.4
                    visible: !declarativeJsonItem.on && !jsonState.busy
                }
            }
        }
        Item {
            id: frequencyRow
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: widthRightArea
            RowLayout {
                anchors.fill: parent
                Label {
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    text: Z.tr("Frequency:")
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: buttonWidth
                    visible: frequencyMode.varSelected
                    ZLineEdit {
                        anchors.fill: parent
                        pointSize: root.pointSize
                        validator: ZDoubleValidator {
                            bottom: jsonParamInfo['Frequency']['params']['val'].min
                            top: jsonParamInfo['Frequency']['params']['val'].max
                            decimals: jsonParamInfo['Frequency']['params']['val'].decimals
                        }
                        text: declarativeJsonItem['Frequency'].val
                        function doApplyInput(newText) {
                            declarativeJsonItem['Frequency'].val = parseFloat(newText)
                            return true
                        }
                    }
                }
                Label {
                    textFormat: Text.PlainText
                    Layout.preferredWidth: qAndHzLabelWidth
                    font.pointSize: pointSize
                    horizontalAlignment: Label.AlignLeft
                    visible: frequencyMode.varSelected
                    text: "Hz"
                }
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: buttonWidth
                    ZComboBox {
                        id: frequencyMode
                        anchors.fill: parent
                        anchors.topMargin: bottomRow.topFreeSpace
                        arrayMode: true
                        fontSize: comboFontSize
                        centerVertical: true
                        model: jsonParamInfo.Frequency.params.type.list
                        readonly property bool varSelected: currentText === "var"
                        function setInitialIndex() {
                            currentIndex = model.indexOf(declarativeJsonItem.Frequency.type)
                        }
                        onModelChanged: setInitialIndex()
                        onSelectedTextChanged: {
                            declarativeJsonItem.Frequency.type = selectedText
                        }
                    }
                }
            }
        }
    }
}
