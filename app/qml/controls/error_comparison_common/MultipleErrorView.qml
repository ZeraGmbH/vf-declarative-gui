import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraVeinComponents 1.0
import FunctionTools 1.0

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
    property string resultUnit: '%'

    // internals
    readonly property real rowHeight: height > 0 ? height / (resultRows + 3/* 2 lines + bar */) : 10
    readonly property real fontScale: 0.45
    readonly property real pointSize: rowHeight * fontScale
    readonly property real margins: 8

    onJsonResultsChanged: resultList.recalcModel()

    Column {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: margins
        spacing: rowHeight * 0.25

        // Header with statistics
        GridLayout {
            columns: 6
            columnSpacing: 3
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
                text: jsonResults.mean === null ? '---' : FT.formatNumberParam(jsonResults.mean, digitsTotal, decimalPlaces) + resultUnit
                font.pointSize: pointSize
            }
            // 2nd line
            Text {
                text: Z.tr("Range:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.range === null ? '---' : FT.formatNumberParam(jsonResults.range, digitsTotal, decimalPlaces) + resultUnit
                font.pointSize: pointSize
            }
            Text {
                text: Z.tr("Stddev. n:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.stddevN === null ? '---' : FT.formatNumberParam(jsonResults.stddevN, digitsTotal, decimalPlaces) + resultUnit
                font.pointSize: pointSize
            }
            Text {
                text: Z.tr("Stddev. n-1:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.stddevN1 === null ? '---' : FT.formatNumberParam(jsonResults.stddevN1, digitsTotal, decimalPlaces) + resultUnit
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
            property int lastIdxMin: -1
            property int lastIdxMax: -1
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
            function updateMinMax(entry) {
                if(entry >= 0) {
                    let block = Math.floor(entry / resultRows)
                    let horizBlock = block % resultColumns
                    let currLine = (block - horizBlock) * resultRows / resultColumns + entry % resultRows
                    let lineContent = resultModel.get(currLine)
                    let content = lineContent.arrColumns.get(horizBlock)
                    content.minMax = entry === jsonResults.idxMin || entry === jsonResults.idxMax
                }
            }
            function recalcModel() {
                // keep positions
                let isScrolledToEnd = atYEnd
                let resultArr = jsonResults.values
                let newResultCount = resultArr.length
                let newIdxMin = -1
                let newIdxMax = -1

                // we assume:
                // * data is appended only and never touched after
                // * if the number of results decreases we have to rebuild model
                if(resultList.lastResultCount > newResultCount) {
                    resultModel.clear()
                    resultList.lastIdxMin = -1
                    resultList.lastIdxMax = -1
                    resultList.lastResultCount = 0
                }
                let linesAdded = 0
                let sizeSection = resultRows * resultColumns
                let currEntry
                for (currEntry = resultList.lastResultCount; currEntry < newResultCount; ++currEntry) {
                    currSection = Math.floor(currEntry / sizeSection)
                    let currSectionStr = String(currSection * sizeSection + 1) + '-' + String((currSection+1) * sizeSection)

                    // TODO: same as updateMinMax calculations -> move to one common place
                    let currBlock = Math.floor(currEntry / resultRows)
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
                    // handle new min/max positions
                    let setMinMax = false
                    if(jsonResults.idxMin === currEntry) {
                        setMinMax = true
                        newIdxMin = currEntry
                    }
                    if(jsonResults.idxMax === currEntry) {
                        setMinMax = true
                        newIdxMax = currEntry
                    }
                    // add to model
                    if(resultModel.count-1 < currLine) { // add a line with one column
                        resultModel.append({section: currSectionStr, arrColumns: [{num: currEntry+1, val: errVal, strval: errValStr, rat: errRating, minMax: setMinMax}]})
                        ++linesAdded
                        /*let curLineTest = resultModel.get(currLine)
                        console.info("init", currEntry+1, JSON.stringify(curLineTest))*/
                    }
                    else { // add a column to an existing line
                        let curLine = resultModel.get(currLine)
                        curLine.arrColumns.append([{num: currEntry+1, val: errVal, strval: errValStr, rat: errRating, minMax: setMinMax}])
                        /*let curLineTest1 = resultModel.get(currLine)
                        console.info("add", currEntry+1, JSON.stringify(curLineTest1))*/
                    }
                }

                // up to here we just appended new results. In case min/max
                // positions have changed, update old positions
                if(newIdxMin >= 0) {
                    updateMinMax(lastIdxMin)
                    lastIdxMin = newIdxMin
                }
                if(newIdxMax >= 0) {
                    updateMinMax(lastIdxMax)
                    lastIdxMax = newIdxMax
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
                            text: strval !== "" ? strval : FT.formatNumberParam(val, digitsTotal, decimalPlaces) + resultUnit
                            font.pointSize: pointSize
                            width: mainColumn.width * 7.4 / (10*resultColumns)
                            font.bold: minMax
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

