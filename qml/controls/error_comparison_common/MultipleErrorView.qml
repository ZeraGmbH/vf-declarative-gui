import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraLocale 1.0 // for now - see removeDecimalGroupSeparators / formatNumber below
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0

Rectangle {
    id: root
    // Our data to display. At the time of writing sec1-module is the only
    // module creating multiple json results.
    property var jsonResults

    // settings, our parent can override / bind
    property int resultColumns: 3
    property int resultRows: 10
    property int digitsTotal: 6
    property int decimalPlaces: 4

    // internals
    readonly property real rowHeight: height > 0 ? height / (resultRows + 3/* 2 lines + bar */) : 10
    readonly property real fontScale: 0.45
    readonly property real pointSize: rowHeight * fontScale
    readonly property real margins: 8

    onJsonResultsChanged: resultList.recalcModel()

    // Stolen - more or less from GlobalConfig.qml. We should find a more common
    // place for this...
    // Reasoning: By having these functions in here we can use property bindings
    // for digitsTotal / decimalPlaces. Doing so is cool: In case they change
    // all contents are updated and scroll position remains
    function removeDecimalGroupSeparators(strNum) {
        // remove group separators (this is ugly but don't get documented examples to fly here...)
        let groupSepChar = ZLocale.getDecimalPoint() === "," ? "." : ","
        while(strNum.includes(groupSepChar)) {
            strNum = strNum.replace(groupSepChar, "")
        }
        return strNum
    }
    function formatNumber(num, _digitsTotal, _decimalPlaces) {
        if(typeof num === "string") { //parsing strings as number is not desired
            return num;
        }
        else {
            let dec = _decimalPlaces
            let leadDigits = Math.floor(Math.abs(num)).toString()
            // leading zero is not a digit
            if(leadDigits === '0') {
                leadDigits  = ''
            }
            let preDecimals = leadDigits.length
            if(dec + preDecimals > _digitsTotal) {
                dec = _digitsTotal - preDecimals
                if(dec < 0) {
                    dec = 0
                }
            }
            let strNum = Number(num).toLocaleString(ZLocale.getLocale(), 'f', dec)
            strNum = removeDecimalGroupSeparators(strNum)
            return strNum
        }
    }

    Column {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: margins
        spacing: rowHeight * 0.25

        // Header with statistics
        GridLayout {
            columns: 6
            width: parent.width
            // 1st line
            Text {
                id: totalLabel
                text: Z.tr("Count:")
                font.pointSize: pointSize
                font.bold: true
                color: jsonResults.countPass > 0 && jsonResults.countPass === jsonResults.values.length ?
                           "darkgreen" : "black"
            }
            Text {
                text: jsonResults.values.length
                font.pointSize: pointSize
                color: totalLabel.color
            }
            Text {
                id: failLabel
                text: Z.tr("Failed:")
                font.pointSize: pointSize
                font.bold: true
                color: jsonResults.countFail + jsonResults.countUnfinish > 0 ?
                           "red" : "black"
            }
            Text {
                text: jsonResults.countFail + jsonResults.countUnfinish
                font.pointSize: pointSize
                color: failLabel.color
            }
            Text {
                text: Z.tr("Mean:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.mean === null ? '---' : formatNumber(jsonResults.mean, digitsTotal, decimalPlaces) + "%"
                font.pointSize: pointSize
            }
            // 2nd line
            Text {
                text: Z.tr("Range:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.range === null ? '---' : formatNumber(jsonResults.range, digitsTotal, decimalPlaces) + "%"
                font.pointSize: pointSize
            }
            Text {
                text: Z.tr("Stddev. n:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.stddevN === null ? '---' : formatNumber(jsonResults.stddevN, digitsTotal, decimalPlaces) + "%"
                font.pointSize: pointSize
            }
            Text {
                text: Z.tr("Stddev. n-1:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.stddevN1 === null ? '---' : formatNumber(jsonResults.stddevN1, digitsTotal, decimalPlaces) + "%"
                font.pointSize: pointSize
            }
        }
        ListView { // result list
            id: resultList
            height: rowHeight * (resultRows + 0.5)
            width: parent.width
            clip: true

            model: ListModel { id: resultModel }
            property int lastResultCount: 0
            property bool needsScroll: false
            property int currSection: 0
            readonly property real sectionHeight: rowHeight * 0.25
            onDraggingVerticallyChanged: {
                if(draggingVertically) {
                    needsScroll = false
                }
            }
            onContentHeightChanged: {
                if(needsScroll && contentHeight > height) {
                    // Do not understand exactly why we need to divide section
                    // size by 2 - anyway it works perfectly fine on all
                    // resolutions
                    contentY = contentHeight + (currSection*sectionHeight/2) - height
                }
            }
            function recalcModel() {
                // keep positions
                let isScrolledToEnd = atYEnd
                let resultArr = jsonResults.values
                let newResultCount = resultArr.length
                // we assume:
                // * data is appended only and never touched after
                // * if the number of results decreases we have to rebuild model
                if(resultList.lastResultCount > newResultCount) {
                    resultModel.clear()
                    resultList.lastResultCount = 0
                }
                let linesAdded = 0
                let sizeSection = resultRows * resultColumns
                for (let currEntry = resultList.lastResultCount; currEntry < newResultCount; ++currEntry) {
                    let currBlock = Math.floor(currEntry / resultRows)
                    currSection = Math.floor(currEntry / sizeSection)
                    let currSectionStr = String(currSection * sizeSection + 1) + '-' + String((currSection+1) * sizeSection)
                    let currHorizBlock = currBlock % resultColumns
                    let currLine = (currBlock - currHorizBlock) * resultRows / resultColumns + currEntry % resultRows
                    //console.info(currEntry, currBlock, currSectionStr, currHorizBlock, currLine)
                    let errVal = resultArr[currEntry].V
                    let errValStr = ""
                    if(errVal === null) {
                        errVal = -100
                        errValStr = "---"
                    }
                    let errRating = resultArr[currEntry].R
                    if(resultModel.count-1 < currLine) { // add a line with one column
                        resultModel.append({section: currSectionStr, arrColumns: [{num: currEntry+1, val: errVal, strval: errValStr, rat: errRating}]})
                        ++linesAdded
                        /*let curLineTest = resultModel.get(currLine)
                        console.info("init", currEntry+1, JSON.stringify(curLineTest))*/
                    }
                    else { // add a column to an existing line
                        let curLine = resultModel.get(currLine)
                        curLine.arrColumns.append([{num: currEntry+1, val: errVal, strval: errValStr, rat: errRating}])
                        /*let curLineTest1 = resultModel.get(currLine)
                        console.info("add", currEntry+1, JSON.stringify(curLineTest1))*/
                    }
                }
                resultList.lastResultCount = newResultCount
                needsScroll |= isScrolledToEnd && linesAdded > 0
            }
            delegate: Item {
                width: parent.width
                height: rowHeight
                Repeater {
                    model: arrColumns
                    Row {
                        x: index * mainColumn.width / resultColumns
                        width: mainColumn.width / resultColumns -10
                        height: rowHeight
                        Text {
                            id: numText
                            text: num + ":"
                            font.pointSize: pointSize
                            font.bold: true
                            width: mainColumn.width * 2.6 / (10*resultColumns)
                            color: rat === 1 ? "black" : "red"
                        }
                        Text {
                            text: strval !== "" ? strval : formatNumber(val, digitsTotal, decimalPlaces)  + "%"
                            font.pointSize: pointSize
                            width: mainColumn.width * 7.4 / (10*resultColumns)
                            color: numText.color
                        }
                    }
                }
            }
            section.property: "section"
            section.criteria: ViewSection.FullString
            section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
            section.delegate: Item {
                height: resultList.sectionHeight
                width: parent.width
                Rectangle { // line
                    color: "#FFE082" // Material.Amber
                    width: parent.width
                    height: pointSize * 0.2
                }
            }
            // TODO: Where is it?
            ScrollIndicator.vertical: ScrollIndicator {
                width: 8
                active: true
                onActiveChanged: {
                    if(active !== true) {
                        active = true;
                    }
                }
            }
        }
    }
}

