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

Item {
    // set by our tab-page
    property var jsonSourceParamInfoRaw
    property string paramComponentName

    // convenient JSON property to simplify layout code below
    readonly property var jsonParamInfoExt: {
        // All changes on retJson will occore in jsonSourceParamInfoRaw either
        // but jsonSourceParamInfoRaw is set once and will not change by it's
        // own
        let retJson = jsonSourceParamInfoRaw

        // defaults for mandatory values
        retJson['extraLinesRequired'] = false

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
                }
            }
        }
        // * generate columInfo as an ordered array of
        // { 'phasenum': .. 'phaseNameDisplay': .., 'colorIndexU': .., 'colorIndexI': .. }
        let columInfo = []
        let maxPhaseAll = Math.max(jsonSourceParamInfoRaw['UPhaseMax'],
                                   jsonSourceParamInfoRaw['IPhaseMax'])
        retJson['maxPhaseAll'] = maxPhaseAll
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

    enum LineType {
        LineOnOff = 0,
        LineRMS,
        LineAngle,
        LineHarmonics
    }
    property var arrJsonTypeKey: [
        "on",
        "rms",
        "angle",
        "not-implemented"
    ]

    DeclarativeJsonItem {
        // this is magic: Feels like JSON but declarative (property binding possible)
        id: declarativeJsonItem
    }

    // local parameter load
    readonly property var paramComponent: VeinEntity.getEntity("SourceModule1")[paramComponentName]
    onParamComponentChanged: {
        if(!ignoreStatusChange) {
            declarativeJsonItem.fromJson(paramComponent)
        }
    }
    // local parameter store
    property bool ignoreStatusChange: false
    function sendParamsToServer() {
        // Avoid double full painting by our json property change
        ignoreStatusChange = true
        VeinEntity.getEntity("SourceModule1")[paramComponentName] = declarativeJsonItem.toJson()
        ignoreStatusChange = false
    }
    // To avoid waste of CPU by back & forth painting: Load view after jsonParamInfoExt is valid
    Loader {
        anchors.fill: parent
        sourceComponent: theViewComponent
        active: jsonParamInfoExt !== undefined && paramComponent !== undefined
    }
    // Graphical items start
    Component {
        id: theViewComponent
        Item {
            id: theView
            anchors.fill: parent
            Component.onCompleted: {
                symmetrize()
            }

            // convenient properties for layout vertical
            readonly property int linesStandardUI: 3 // RMS / Angle / OnOff
            readonly property real lineHeight: height / (linesStandardUI*2 + 2) // +2 header+bottom line
            readonly property real lineHeightHeaderLine: lineHeight - (horizScrollbarOn ? scrollBarWidth : 0)
            readonly property int linesU: jsonParamInfoExt.UPhaseMax ? (jsonParamInfoExt.supportsHarmonicsU ? 4: 3) : 0
            readonly property int linesI: jsonParamInfoExt.IPhaseMax ? (jsonParamInfoExt.supportsHarmonicsI ? 4: 3) : 0
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
                jsonParamInfoExt.maxPhaseAll >= columnsStandardUI ?
                    0 : (columnsStandardUI - jsonParamInfoExt.maxPhaseAll) * columnWidth

            // convenient properties fonts
            readonly property real headerPointSize: pointSize * 1.5
            readonly property real pointSize: height > 0 ? height / 30 : 10

            // convenient properties scrollbars
            readonly property int scrollBarWidth: width > 100 ? width / 100 : 8
            readonly property bool horizScrollbarOn: jsonParamInfoExt.columnInfo.length > 3
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
                            declarativeJsonItem[jsonPhaseNameU].angle = angleModulo(angleU + angleOffset)
                            declarativeJsonItem[jsonPhaseNameU].rms = rmsU
                        }
                        let jsonPhaseNameI = 'I%1'.arg(phase)
                        if(declarativeJsonItem[jsonPhaseNameI]) {
                            declarativeJsonItem[jsonPhaseNameI].angle = angleModulo(angleI + angleOffset)
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
                        declarativeJsonItem[jsonPhaseNameI].angle = angleModulo(angleINew)
                    }
                    defaultAngle += 120
                }
            }
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
                anchors.leftMargin: theView.moveTableRightForFewPhasors
                width: theView.headerColumnWidth - jsonParamInfoExt.extraLinesRequired * scrollBarWidth
                GridRect { // empty topmost
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: theView.lineHeightHeaderLine
                    color: GC.tableShadeColor
                }
                Repeater { // U/I rectangles
                    model: theView.uiModel
                    GridRect {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: theView.linesStandardUI * theView.lineHeight
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
                contentWidth: theView.columnWidth * jsonParamInfoExt.columnInfo.length
                contentHeight: height - (theView.horizScrollbarOn ? theView.scrollBarWidth : 0)
                clip: true
                Column { // header / U table / I table
                    width: dataTable.contentWidth
                    height: dataTable.contentHeight

                    Row { // header row
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: theView.lineHeightHeaderLine
                        Repeater {
                            model: jsonParamInfoExt.columnInfo
                            GridRect {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: theView.columnWidth
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
                                    model: jsonParamInfoExt.columnInfo
                                    GridRect { // the field
                                        id: valueRect
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: theView.columnWidth
                                        readonly property int columnIndex: index
                                        readonly property string jsonPhaseName: uiType + String(columnIndex+1)
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
                                                    text: declarativeJsonItem[jsonPhaseName][arrJsonTypeKey[rowIndex]]

                                                    function doApplyInput(newText) {
                                                        if(rowIndex === SourceModulePage.LineType.LineAngle) { // correct negative angles immediately
                                                            let angle = Number(newText)
                                                            angle = angleModulo(angle)
                                                            newText = FT.formatNumber(angle, jsonParamInfoExt[jsonPhaseName]['params']['angle'].decimals)
                                                        }
                                                        declarativeJsonItem[jsonPhaseName][arrJsonTypeKey[rowIndex]] = parseFloat(newText)
                                                        if(jsonPhaseName == 'U1' || jsonPhaseName == 'I1') {
                                                            symmetrize()
                                                        }
                                                        return false
                                                    }
                                                    readonly property var validatorInfo: {
                                                        let min, max, decimals = 0.0
                                                        switch(rowIndex) {
                                                        case SourceModulePage.LineType.LineRMS:
                                                            min = jsonParamInfoExt[jsonPhaseName]['params']['rms'].min
                                                            max = jsonParamInfoExt[jsonPhaseName]['params']['rms'].max
                                                            decimals = jsonParamInfoExt[jsonPhaseName]['params']['rms'].decimals
                                                            break
                                                        case SourceModulePage.LineType.LineAngle:
                                                            min = -jsonParamInfoExt[jsonPhaseName]['params']['angle'].max // we allow users entering +/-
                                                            max = jsonParamInfoExt[jsonPhaseName]['params']['angle'].max
                                                            decimals = jsonParamInfoExt[jsonPhaseName]['params']['angle'].decimals
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
                                                    checked: declarativeJsonItem[jsonPhaseName].on
                                                    onClicked: declarativeJsonItem[jsonPhaseName].on = checked
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
                anchors.rightMargin: jsonParamInfoExt.extraLinesRequired * scrollBarWidth
                width: theView.headerColumnWidth
                GridRect { // [ ] topmost
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: theView.lineHeightHeaderLine
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
                        delegate: GridRect {
                            anchors.left: parent.left
                            width: parent.width
                            height: theView.lineHeight
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
            GridRect {
                id: vectorView
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.top: parent.top
                anchors.bottom: pqRow.top

                PhasorDiagram {
                    anchors.fill: parent
                    readonly property real maxNominalFactor: 1.2
                    readonly property var arrRms: { // rms + phase on
                        let arr = []
                        for(var phase=1; phase<=3; phase++) {
                            let jsonPhaseName = 'U%1'.arg(phase)
                            let rmsVal = declarativeJsonItem[jsonPhaseName] && declarativeJsonItem[jsonPhaseName].on ?
                                    declarativeJsonItem[jsonPhaseName].rms : 0.0
                            arr.push(rmsVal)
                        }
                        for(phase=1; phase<=3; phase++) {
                            let jsonPhaseName = 'I%1'.arg(phase)
                            let rmsVal = declarativeJsonItem[jsonPhaseName] && declarativeJsonItem[jsonPhaseName].on ?
                                    declarativeJsonItem[jsonPhaseName].rms : 0.0
                            arr.push(rmsVal)
                        }
                        return arr
                    }
                    readonly property var arrRmsXY: { // rms + phase on -> x/y
                        let arr = []
                        for(var phase=1; phase<=3; phase++) {
                            let jsonPhaseName = 'U%1'.arg(phase)
                            let angleVal = declarativeJsonItem[jsonPhaseName] ? declarativeJsonItem[jsonPhaseName].angle : 0.0
                            let xyArr = []
                            xyArr[0] = Math.sin(toRadianFactor * angleVal) * arrRms[phase-1]
                            xyArr[1] = -Math.cos(toRadianFactor * angleVal) * arrRms[phase-1]
                            arr.push(xyArr)
                        }
                        for(phase=1; phase<=3; phase++) {
                            let jsonPhaseName = 'I%1'.arg(phase)
                            let angleVal = declarativeJsonItem[jsonPhaseName] ? declarativeJsonItem[jsonPhaseName].angle : 0.0
                            let xyArr = []
                            xyArr[0] = Math.sin(toRadianFactor * angleVal) * arrRms[phase+3-1]
                            xyArr[1] = -Math.cos(toRadianFactor * angleVal) * arrRms[phase+3-1]
                            arr.push(xyArr)
                        }
                        return arr
                    }

                    fromX: Math.floor(width/2)
                    fromY: Math.floor(height/2)
                    phiOrigin: 0

                    circleVisible: true
                    circleColor: Material.frameColor
                    circleValue: maxVoltage / maxNominalFactor

                    gridColor: Material.frameColor;
                    gridVisible: true
                    gridScale: Math.min(height,width)/maxVoltage/2

                    property real minRelValueDisplayed: 0.05
                    // Next time we re-use PhasorDiagram, we should think about rewriting it!!!
                    maxVoltage: theView.maxVoltage * maxNominalFactor / Math.sqrt(3)
                    minVoltage: maxVoltage * minRelValueDisplayed
                    maxCurrent: theView.maxCurrent * maxNominalFactor
                    minCurrent: maxCurrent * minRelValueDisplayed

                    vector1Color: GC.colorUL1
                    vector2Color: GC.colorUL2
                    vector3Color: GC.colorUL3
                    vector4Color: GC.colorIL1
                    vector5Color: GC.colorIL2
                    vector6Color: GC.colorIL3

                    vector1Data: [arrRmsXY[0][0],arrRmsXY[0][1]]
                    vector2Data: [arrRmsXY[1][0],arrRmsXY[1][1]]
                    vector3Data: [arrRmsXY[2][0],arrRmsXY[2][1]]
                    vector4Data: [arrRmsXY[3][0],arrRmsXY[3][1]]
                    vector5Data: [arrRmsXY[4][0],arrRmsXY[4][1]]
                    vector6Data: [arrRmsXY[5][0],arrRmsXY[5][1]]

                    vector1Label: "UL1"
                    vector2Label: "UL2"
                    vector3Label: "UL3"
                    vector4Label: "IL1"
                    vector5Label: "IL2"
                    vector6Label: "IL3"

                    vectorView: PhasorDiagram.VIEW_THREE_PHASE // TODO???
                    vectorMode: PhasorDiagram.DIN410
                    currentVisible: true
                }
            }
            RowLayout {
                id: pqRow
                anchors.right: parent.right
                width: theView.widthRightArea
                anchors.bottom: angleQuickRow.top
                height: theView.lineHeight + (theView.horizScrollbarOn ? theView.scrollBarWidth : 0)
                readonly property int bottomFreeSpace: 1
                function calcAverageAngleDiff() {
                    let arrAngleDiff = []
                    let activePhases = 0
                    let defaultAngle = 0.0 // for sources with current (or voltage??) only
                    for(let phase=1; phase<=3; phase++) {
                        let angleDiff = 0.0
                        let jsonPhaseNameU = 'U%1'.arg(phase)
                        let angleValU = declarativeJsonItem[jsonPhaseNameU] ? declarativeJsonItem[jsonPhaseNameU].angle : defaultAngle
                        let jsonPhaseNameI = 'I%1'.arg(phase)
                        let angleValI = declarativeJsonItem[jsonPhaseNameI] ? declarativeJsonItem[jsonPhaseNameI].angle : defaultAngle
                        angleDiff = angleModulo(angleValI - angleValU)
                        arrAngleDiff.push(angleDiff)
                        defaultAngle += 120.0
                        if(declarativeJsonItem[jsonPhaseNameU] || declarativeJsonItem[jsonPhaseNameI]) {
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
                            id: cosCosSinValidator
                            bottom: -1.0
                            top: 1.0
                            // we can display 4 digits but sign is one of them
                            decimals: Math.min(3, Math.min(GC.digitsTotal-1, GC.decimalPlaces))
                        }
                        text: FT.formatNumber(pqRow.cosSinAverAngle, cosCosSinValidator.decimals)
                        function doApplyInput(newText) {
                            // TODO

                            return false
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
                        currentIndex: pqRow.quadrantZeroBased
                        onTargetIndexChanged: {
                            let diffAngle = (targetIndex-currentIndex) * 90
                            autoAngle(false, diffAngle)
                        }
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
                    onClicked: autoAngle(true, 0.0)
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
                    onClicked: autoAngle(true, 180.0)
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
                    autoRepeat: true
                    //autoRepeatInterval: 150
                    onReleased: autoAngle(false, 15) // onClicked is slow on repetitions
                }
                Button {
                    width: theView.buttonWidth
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    topInset: 0
                    bottomInset: 0
                    font.pointSize: theView.pointSize * 0.9
                    text: "-15°"
                    autoRepeat: true
                    onReleased: autoAngle(false, -15)
                }
            }
            ///////////// full width bottom area /////////////
            GridRect {
                id: bottomRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: theView.lineHeight
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
                        anchors.leftMargin: theView.headerColumnWidth - jsonParamInfoExt.extraLinesRequired * scrollBarWidth
                        font.pointSize: theView.pointSize * 0.9
                        onClicked: {
                            declarativeJsonItem.on = true
                            sendParamsToServer()
                        }
                    }
                    CheckBox {
                        id: symmetricCheckbox
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Z.tr("symmetric")
                        font.pointSize: theView.pointSize * 0.9
                        checked: true // How should a per source setting not confuse
                        onCheckedChanged: {
                            symmetrize()
                        }
                    }
                    Button {
                        text: Z.tr("Off")
                        width: theView.buttonWidth
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        topInset: bottomRow.topFreeSpace
                        bottomInset: 0
                        anchors.right: parent.right
                        anchors.rightMargin: theView.headerColumnWidth + jsonParamInfoExt.extraLinesRequired * scrollBarWidth
                        font.pointSize: theView.pointSize * 0.9
                        onClicked: {
                            declarativeJsonItem.on = false
                            sendParamsToServer()
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
                                    bottom: jsonParamInfoExt['Frequency']['params']['val'].min
                                    top: jsonParamInfoExt['Frequency']['params']['val'].max
                                    decimals: jsonParamInfoExt['Frequency']['params']['val'].decimals
                                }
                                text: declarativeJsonItem['Frequency'].val
                                function doApplyInput(newText) {
                                    declarativeJsonItem['Frequency'].val = parseFloat(newText)
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
                                model: jsonParamInfoExt.Frequency.params.type.list
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
    }
}
