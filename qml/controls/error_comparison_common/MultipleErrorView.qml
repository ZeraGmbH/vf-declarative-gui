import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0

Rectangle {
    id: root
    // Our data to display. At the time of writing sec1-module is the only
    // module creating multiple json results.
    property var jsonResults

    // settings, our parent has to take care of
    property int resultColumns: 3
    property int resultRows

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
            width: parent.width
            // 1st line
            Text {
                text: Z.tr("Count:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.values.length
                font.pointSize: pointSize
            }
            Text {
                id: passLabel
                text: Z.tr("Passed:")
                font.pointSize: pointSize
                font.bold: true
                color: jsonResults.countPass > 0 && jsonResults.countPass === jsonResults.values.length ?
                           "darkgreen" : "black"
            }
            Text {
                text: jsonResults.countPass
                font.pointSize: pointSize
                color: passLabel.color
            }
            Text {
                id: failLabel
                text: Z.tr("Failed:")
                font.pointSize: pointSize
                font.bold: true
                color: jsonResults.countFail > 0 ?
                           "red" : "black"
            }
            Text {
                text: jsonResults.countFail
                font.pointSize: pointSize
                color: failLabel.color
            }
            // 2nd line
            Text {
                text: Z.tr("Mean:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.mean === null ? '---' : GC.formatNumber(jsonResults.mean) + "%"
                font.pointSize: pointSize
            }
            Text {
                text: Z.tr("Stddev. n:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.stddevN === null ? '---' : GC.formatNumber(jsonResults.stddevN) + "%"
                font.pointSize: pointSize
            }
            Text {
                text: Z.tr("Stddev. n-1:")
                font.pointSize: pointSize
                font.bold: true
            }
            Text {
                text: jsonResults.stddevN1 === null ? '---' : GC.formatNumber(jsonResults.stddevN1) + "%"
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
            function recalcModel() {
                var resultArr = jsonResults.values
                var newResultCount = resultArr.length
                // we assume:
                // * data is appended only and never touched after
                // * if the number of results decreases we have to rebuild model
                if(resultList.lastResultCount > newResultCount) {
                    resultModel.clear()
                    resultList.lastResultCount = 0
                }
                var sizeSection = resultRows * resultColumns
                for (var currEntry = resultList.lastResultCount; currEntry < newResultCount; ++currEntry) {
                    var currBlock = Math.floor(currEntry / resultRows)
                    var currSection = Math.floor(currEntry / sizeSection)
                    var currSectionStr = String(currSection * sizeSection + 1) + '-' + String((currSection+1) * sizeSection)
                    var currHorizBlock = currBlock % resultColumns
                    var currLine = (currBlock - currHorizBlock) * resultRows / resultColumns + currEntry % resultRows
                    //console.info(currEntry, currBlock, currSectionStr, currHorizBlock, currLine)

                    var errVal = GC.formatNumber(resultArr[currEntry].V)
                    var errRating = resultArr[currEntry].R
                    if(resultModel.count-1 < currLine) { // add a line with one column
                        resultModel.append({section: currSectionStr, arrColumns: [{num: currEntry+1, val: errVal, rat: errRating}]})
                        var curLineTest = resultModel.get(currLine)
                        //console.info("init", currEntry+1, JSON.stringify(curLineTest))
                    }
                    else { // add a column to an existing line
                        var curLine = resultModel.get(currLine)
                        curLine.arrColumns.append([{num: currEntry+1, val: errVal, rat: errRating}])
                        var curLineTest1 = resultModel.get(currLine)
                        //console.info("add", currEntry+1, JSON.stringify(curLineTest1))
                    }
                }
                resultList.lastResultCount = newResultCount
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
                            text: val + "%"
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
                height: rowHeight * 0.25
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

