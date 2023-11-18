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
import FontAwesomeQml 1.0
import uivectorgraphics 1.0
import ZeraComponents 1.0
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
// * Feature: Add an indicator right to 'ON' button to show that user has made
//   changes since last (active) switch on
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
            waitPopup.startWait((declarativeJsonItem.on ? Z.tr("Switching on %1...") : Z.tr("Switching off %1...")).arg(jsonParamInfo.Name))
        }
        else {
            if(waitPopup.opened) {
                waitPopup.stopWait(Z.tr(jsonState.warnings), Z.tr(jsonState.errors), null)
            }
            else if(jsonState.errors.length !== 0) { // poll
                waitPopup.startWait(Z.tr("Status error on %1...").arg(jsonParamInfo.Name))
                waitPopup.stopWait(Z.tr(jsonState.warnings), Z.tr(jsonState.errors), null)
            }
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
    readonly property real lineHeight: height > 0 ? (height / (linesStandardUI*2 + 3)) : 10 // +2 header+bottom line
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
    readonly property real widthLeftArea: width * 0.53
    readonly property real widthRightArea: width - widthLeftArea
    readonly property real headerColumnWidth: widthLeftArea * 0.12
    readonly property real buttonWidth: widthRightArea / 5
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
    property var baseColorTable: GC.currentColorTable
    onBaseColorTableChanged: darkenColorsForSymmetric()
    property var currentColorTable: []
    function darkenColorsForSymmetric() {
        let colorTable = [...GC.currentColorTable]
        if(symmetricCheckbox.checked) {
            let darken = 2.1
            colorTable[1] = Qt.darker(GC.currentColorTable[1], darken) // U2
            colorTable[2] = Qt.darker(GC.currentColorTable[2], darken) // U3
            colorTable[4] = Qt.darker(GC.currentColorTable[4], darken) // I2
            colorTable[5] = Qt.darker(GC.currentColorTable[5], darken) // I2
        }
        currentColorTable = colorTable
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
                    let decimals = jsonParamInfo[jsonPhaseNameU]['zj_params']['angle'].decimals
                    declarativeJsonItem[jsonPhaseNameU].angle = Number(FT.formatNumberCLocale(angleModulo(angleU + angleOffset), decimals))
                    declarativeJsonItem[jsonPhaseNameU].rms = rmsU
                }
                let jsonPhaseNameI = 'I%1'.arg(phase)
                if(declarativeJsonItem[jsonPhaseNameI]) {
                    let decimals = jsonParamInfo[jsonPhaseNameI]['zj_params']['angle'].decimals
                    declarativeJsonItem[jsonPhaseNameI].angle = Number(FT.formatNumberCLocale(angleModulo(angleI + angleOffset), decimals))
                    declarativeJsonItem[jsonPhaseNameI].rms = rmsI
                }
                angleOffset += 120
            }
        }
        darkenColorsForSymmetric()
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
                let decimals = jsonParamInfo[jsonPhaseNameI]['zj_params']['angle'].decimals
                declarativeJsonItem[jsonPhaseNameI].angle = Number(FT.formatNumberCLocale(angleModulo(angleINew), decimals))
            }
            defaultAngle += 120
        }
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
    GridRect {
        visible: false
        id: quickLoadSelectRect
        anchors.left: parent.left
        width: widthLeftArea
        anchors.top: parent.top
        height: lineHeight
        Label {
            id: quickLoadSelectLabel
            font.styleName: "Regular"
            text: FAQ.fa_heart + " :"
            font.pointSize: pointSize
            anchors.left: parent.left
            textFormat: Text.PlainText
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Label.AlignHCenter
            width: headerColumnUI.width
        }
        ComboBox { // TODO: replace by custom solution
            id: quickLoadSelectCombo
            anchors.left: quickLoadSelectLabel.right
            anchors.right: buttonSave.left
            font.pointSize: pointSize*0.9
            editable: true
            model: ["230V / 5A / cos 1", "230V / 5A / cos 0.5ind"]
            onAccepted: {
                focus = false
            }
            onActivated: {
                focus = false
            }
            Keys.onEscapePressed: {
                focus = false
            }
        }
        Button {
            id: buttonSave
            anchors.right: buttonDelete.left
            text: FAQ.fa_save
            height: lineHeight
            width: unitColumn.width
            topInset: 1
            bottomInset: 2
            rightInset: topInset
            leftInset: topInset
            font.pointSize: pointSize
        }
        Button {
            id: buttonDelete
            anchors.right: quickLoadSelectRect.right
            anchors.rightMargin: unitColumn.anchors.rightMargin
            font.styleName: "Regular"
            text: FAQ.fa_trash
            height: lineHeight
            width: unitColumn.width
            topInset: 1
            bottomInset: 2
            rightInset: topInset
            leftInset: topInset
            font.pointSize: pointSize
        }
    }
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
        anchors.top: quickLoadSelectRect.bottom
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
                                readonly property var jsonParamInfoBase: jsonParamInfo[jsonPhaseName]['zj_params']
                                readonly property bool isAngleU1: uiType === 'U' &&
                                                                  rowIndex === SourceModulePage.LineType.LineAngle &&
                                                                  // TODO more common: first phase U
                                                                  columnIndex === 0
                                Loader { // we load matching control dynamically
                                    anchors.fill: parent
                                    sourceComponent: {
                                        switch(rowIndex) {
                                        default:
                                            return phaseEdit
                                        case SourceModulePage.LineType.LineOnOff:
                                            return phaseCheckBoxComponent
                                        case SourceModulePage.LineType.LineHarmonics:
                                            return phaseComboHarmonics
                                        }
                                    }
                                    asynchronous: true
                                }
                                Component {
                                    id: phaseEdit
                                    ZLineEdit {
                                        id: valueEdit
                                        anchors.fill: parent
                                        pointSize: root.pointSize * 1.2
                                        textField.color: currentColorTable[uiType === 'U' ?
                                                                                  modelData.colorIndexU :
                                                                                  modelData.colorIndexI]
                                        text: jsonDataBase[arrJsonTypeKey[rowIndex]]
                                        textField.enabled: !valueRect.isAngleU1 && (!symmetricCheckbox.checked || columnIndex == 0 || columnIndex >= 3);
                                        textField.background: Rectangle {
                                            y: textField.height - height - textField.bottomPadding / 2
                                            implicitWidth: 120
                                            height: textField.activeFocus ? 2 : 1
                                            color: {
                                                if(textField.enabled) return textField.activeFocus ? textField.Material.accentColor : textField.Material.hintTextColor;
                                                return textField.Material.background
                                            }
                                        }
                                        function doApplyInput(newText) {
                                            newText = newText.replace(",", ".") /* C locale */
                                            if(rowIndex === SourceModulePage.LineType.LineAngle) { // correct negative angles immediately
                                                let angle = Number(newText)
                                                angle = angleModulo(angle)
                                                newText = FT.formatNumberCLocale(angle, jsonParamInfoBase['angle'].decimals)
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
                                }
                                Component {
                                    id: phaseCheckBoxComponent
                                    Item {
                                        anchors.fill: parent
                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            onClicked: phaseCheckbox.checked = !phaseCheckbox.checked
                                        }
                                        ZCheckBox {
                                            id: phaseCheckbox
                                            anchors.right: parent.right
                                            anchors.rightMargin: GC.standardTextHorizMargin
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            width: indicator.width
                                            checked: jsonDataBase.on
                                            onCheckStateChanged: jsonDataBase.on = checked
                                        }
                                    }
                                }
                                Component {
                                    id: phaseComboHarmonics
                                    ZComboBox {
                                        anchors.fill: parent
                                        arrayMode: true
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
        anchors.topMargin: lineHeightHeaderLine + lineHeight
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
    readonly property real qAndHzLabelWidth: buttonWidth * 0.5
    GridRect {
        id: phasorView
        anchors.right: parent.right
        width: widthRightArea
        anchors.top: parent.top
        anchors.bottom: pqRow.top

        PhasorDiagramEx {
            id: phasorDiagram
            maxNominalFactor: 1.2
            vector2Color: currentColorTable[1]
            vector3Color: currentColorTable[2]
            vector5Color: currentColorTable[4]
            vector6Color: currentColorTable[5]
            forceI1Top: symmetricCheckbox.checked
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
            readonly property var maxVoltageVal: {
                let max = 1e-6 // avoid division by 0
                for(let phase=1; phase<=3; phase++) {
                    let jsonPhaseNameU = 'U%1'.arg(phase)
                    if(declarativeJsonItem[jsonPhaseNameU]) {
                        max = Math.max(max, declarativeJsonItem[jsonPhaseNameU].rms)
                    }
                }
                return max
            }
            readonly property var maxCurrentVal: {
                let max = 1e-6 // avoid division by 0
                for(let phase=1; phase<=3; phase++) {
                    let jsonPhaseNameI = 'I%1'.arg(phase)
                    if(declarativeJsonItem[jsonPhaseNameI]) {
                        max = Math.max(max, declarativeJsonItem[jsonPhaseNameI].rms)
                    }
                }
                return max
            }
            maxVoltage: maxVoltageVal * maxNominalFactor
            maxCurrent: maxCurrentVal * maxNominalFactor

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

            vector1Label: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? Z.tr("UL1") : Z.tr("UL1") + "-" + Z.tr("UL2")
            vector2Label: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? Z.tr("UL2") : Z.tr("UL3") + "-" + Z.tr("UL2") // same as ACT_DFTPP2
            vector3Label: vectorView != PhasorDiagram.VIEW_THREE_PHASE ? Z.tr("UL3") : Z.tr("UL3") + "-" + Z.tr("UL1")
            vector4Label: Z.tr("IL1")
            vector5Label: Z.tr("IL2")
            vector6Label: Z.tr("IL3")

            vectorView: GC.vectorMode
            din410: !GC.vectorIecMode
        }
        Button {
            id: phasorViewSettingsButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: lineHeight
            width: buttonWidth
            topInset: 1
            bottomInset: 2
            rightInset: topInset
            leftInset: topInset
            font.pointSize: pointSize
            text: FAQ.fa_cogs
            onClicked: {
                phasorViewPopup.open()
            }
        }
        Popup {
            id: phasorViewPopup
            x: Math.round((parent.width - width))
            y: Math.round((parent.height - height))
            width: buttonWidth * 3
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
                arrayMode: true
                model: ["DIN410", "IEC387"]
                targetIndex: GC.vectorIecMode
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
                arrayMode: true
                model: ["U  PN", "U  △", "U  ∠"]
                targetIndex: GC.vectorMode
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
    }
    Item {
        id: pqRow
        anchors.right: parent.right
        width: widthRightArea
        anchors.bottom: angleQuickRow.top
        height: lineHeight
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

        ZComboBox {
            id: comboPQ
            anchors.left: parent.left
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: pqRow.bottomFreeSpace
            arrayMode: true
            model: ['P', 'Q']
        }
        Label {
            id: cosSinLabel
            anchors.left: comboPQ.right
            width: buttonWidth
            textFormat: Text.PlainText
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            font.pointSize: pointSize
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            text: comboPQ.currentText === "P" ? "cos φ:" :"sin φ:"
        }
        ZLineEdit {
            id: cosSinVal
            anchors.left: cosSinLabel.right
            width: buttonWidth*2 - qAndHzLabelWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            pointSize: root.pointSize
            textField.topPadding: 9 // underline visibility
            textField.bottomPadding: 9
            validator: ZDoubleValidator {
                id: cosCosSinValidator
                bottom: -1.0
                top: 1.0
                decimals: Math.min(3, Math.min(GC.digitsTotal-1, GC.decimalPlaces))
            }
            text: FT.formatNumberCLocale(pqRow.cosSinAverAngle, cosCosSinValidator.decimals)
            function doApplyInput(newText) {
                newText = newText.replace(",", ".") /* C locale */
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
        Label {
            id: quarantLabel
            textFormat: Text.PlainText
            anchors.left: cosSinVal.right
            width: qAndHzLabelWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            font.pointSize: pointSize
            horizontalAlignment : Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            text: "Q:"
        }
        ZComboBox {
            anchors.left: quarantLabel.right
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: pqRow.bottomFreeSpace
            arrayMode: true
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
    Row { // angle buttons + phase sequence combo
        id: angleQuickRow
        anchors.right: parent.right
        width: widthRightArea
        anchors.bottom: bottomRow.top
        height: lineHeight + (horizScrollbarOn ? scrollBarWidth : 0)
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
            rightInset: angleQuickRow.rightFreeSpace
            topInset: 0
            bottomInset: 0
            font.pointSize: pointSize * 0.9
            text: "+15°"
            autoRepeat: true
            onReleased: autoAngle(false, 15)
        }
        ZComboBox {
            width: buttonWidth
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            arrayMode: true
            model: {
                let retModel = []
                let lineStr = ""
                for(var idx of [1,2,3]) {
                    let strSpace = idx !== 1 ? " " : ""
                    let strPhase = Z.tr("Phase" + String(idx))
                    lineStr += strSpace + "<font color='" + GC.currentColorTable[idx-1] + "'>" + strPhase + "</font>"
                }
                retModel.push(lineStr)
                lineStr = ""
                for(idx of [1,3,2]) {
                    let strSpace = idx !== 1 ? " " : ""
                    let strPhase = Z.tr("Phase" + String(idx))
                    lineStr += strSpace + "<font color='" + GC.currentColorTable[idx-1] + "'>" + strPhase + "</font>"
                }
                retModel.push(lineStr)
                return retModel
            }
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
            height: parent.height
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
                    // on-target animations take 20% CPU - disable for now
                    opacity: 0.35
                    /*SequentialAnimation on opacity {
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
                    }*/
                }
            }
            ZCheckBox {
                id: symmetricCheckbox
                anchors {
                    top: parent.top; bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
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
            Label {
                id: frequencyLabel
                textFormat: Text.PlainText
                font.pointSize: pointSize
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: buttonWidth*2
                anchors.rightMargin: GC.standardTextHorizMargin
                horizontalAlignment: Label.AlignRight
                verticalAlignment: Label.AlignVCenter
                text: Z.tr("Frequency:")
            }
            ZLineEdit {
                id: frequencyVal
                visible: frequencyMode.varSelected
                anchors.left: frequencyLabel.right
                width: buttonWidth * 2 - qAndHzLabelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
                validator: ZDoubleValidator {
                    bottom: jsonParamInfo['Frequency']['zj_params']['val'].min
                    top: jsonParamInfo['Frequency']['zj_params']['val'].max
                    decimals: jsonParamInfo['Frequency']['zj_params']['val'].decimals
                }
                text: declarativeJsonItem['Frequency'].val
                function doApplyInput(newText) {
                    declarativeJsonItem['Frequency'].val = parseFloat(newText.replace(",", ".") /* C locale */)
                    return true
                }
            }
            Label {
                visible: frequencyMode.varSelected
                anchors.left: frequencyVal.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: qAndHzLabelWidth
                textFormat: Text.PlainText
                font.pointSize: pointSize
                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
                text: "Hz"
            }
            ZComboBox {
                id: frequencyMode
                anchors.right: parent.right
                width: buttonWidth
                anchors.topMargin: bottomRow.topFreeSpace
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                arrayMode: true
                model: jsonParamInfo.Frequency.zj_params.type.list
                readonly property bool varSelected: currentText === "var"
                currentIndex: model.indexOf(declarativeJsonItem.Frequency.type)
                onSelectedTextChanged: {
                    declarativeJsonItem.Frequency.type = selectedText
                }
            }
        }
    }
}
