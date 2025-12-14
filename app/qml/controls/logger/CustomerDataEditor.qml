import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.14
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import DeclarativeJson 1.0

Item {
    id: dataEditor
    // we need a reference to menu stack layout to move around
    property var menuStackLayout

    anchors.fill: parent
    readonly property real rowHeight: parent.height / 12
    readonly property real fontScale: 0.35
    readonly property real largeScale: 1.25
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    Component.onCompleted: {
        initModel()
        if (customerDataVein["PAR_DatasetIdentifier"] === "")
            generalView.itemAtIndex(0).children[1].startFocusDelay()
    }

    readonly property QtObject customerDataVein: VeinEntity.getEntity("CustomerData");

    readonly property var basicProperties: ["PAR_DatasetIdentifier", "PAR_DatasetComment"]
    readonly property var customerProperties: ["PAR_CustomerNumber", "PAR_CustomerFirstName", "PAR_CustomerLastName",
        "PAR_CustomerCountry", "PAR_CustomerCity", "PAR_CustomerPostalCode", "PAR_CustomerStreet", "PAR_CustomerComment"]
    readonly property var powergridProperties: ["PAR_PowerGridOperator", "PAR_PowerGridSupplier", "PAR_PowerGridComment"]
    readonly property var locationProperties: ["PAR_LocationNumber", "PAR_LocationFirstName", "PAR_LocationLastName",
        "PAR_LocationCountry", "PAR_LocationCity", "PAR_LocationPostalCode", "PAR_LocationStreet", "PAR_LocationComment"]
    readonly property var meterProperties: ["PAR_MeterFactoryNumber", "PAR_MeterManufacturer", "PAR_MeterOwner", "PAR_MeterComment"]

    property var editableDataObject: ({});
    function updateDataObject(prop, text) {
        if(editableDataObject !== undefined)
            editableDataObject[prop] = text
    }
    readonly property string currentFile: customerDataVein.FileSelected
    onCurrentFileChanged: {
        //data becomes irrelevant if the file switches
        editableDataObject = ({});
    }

    readonly property string basicSectionName: "Basic"
    readonly property string customerSectionName: "Customer"
    readonly property string powerGridSectionName: "Power grid"
    readonly property string locationSectionName: "Location"
    readonly property string meterInfoSectionName: "Meter information"

    function getNextSection(prop) {
        let currentSessionAtLast = ""
        if (prop === basicProperties[basicProperties.length-1])
            currentSessionAtLast = basicSectionName
        if (prop === customerProperties[customerProperties.length-1])
            currentSessionAtLast = customerSectionName
        if (prop === powergridProperties[powergridProperties.length-1])
            currentSessionAtLast = powerGridSectionName
        if (prop === locationProperties[locationProperties.length-1])
            currentSessionAtLast = locationSectionName
        if (prop === meterProperties[meterProperties.length-1])
            currentSessionAtLast = meterInfoSectionName

        if (currentSessionAtLast !== "")
            return nextSessionInfo[currentSessionAtLast]
        return ""
    }
    readonly property var nextSessionInfo: {
        let sessInfo = {}
        sessInfo[basicSectionName] = customerSectionName
        sessInfo[customerSectionName] = powerGridSectionName
        sessInfo[powerGridSectionName] = locationSectionName
        sessInfo[locationSectionName] = meterInfoSectionName
        sessInfo[meterInfoSectionName] = ""
        return sessInfo
    }

    DeclarativeJsonItem { id: interactiveVisibility }
    function initModel() {
        let visibility = {}
        visibility[basicSectionName] = true
        visibility[customerSectionName] = false
        visibility[powerGridSectionName] = false
        visibility[locationSectionName] = false
        visibility[meterInfoSectionName] = false
        interactiveVisibility.fromJson(visibility)

        for(var gpIndex in basicProperties)
            objModel.append({ propertyName: basicProperties[gpIndex], section: basicSectionName });
        for(var cIndex in customerProperties)
            objModel.append({ propertyName: customerProperties[cIndex], section: customerSectionName });
        for(var pIndex in powergridProperties)
            objModel.append({ propertyName: powergridProperties[pIndex], section: powerGridSectionName });
        for(var lIndex in locationProperties)
            objModel.append({ propertyName: locationProperties[lIndex], section: locationSectionName });
        for(var mIndex in meterProperties)
            objModel.append({ propertyName: meterProperties[mIndex], section: meterInfoSectionName });
    }

    function ok() {
        for(var prop in editableDataObject) {
            customerDataVein[prop] = editableDataObject[prop];
        }
        menuStackLayout.goBack()
    }
    function cancel() {
        menuStackLayout.goBack()
    }

    ListModel {
        id: objModel
    }

    ListView {
        id: generalView

        model: objModel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: buttonContainer.top

        focus: true
        clip: true
        Keys.onEscapePressed: cancel()

        // keep everything in the buffer to not lose input data
        cacheBuffer: model.count * dataEditor.rowHeight*1.2 // delegate height
        property bool vBarVisible: contentHeight > height

        delegate: RowLayout {
            property string propName: propertyName;
            height: interactiveVisibility[section] ? dataEditor.rowHeight*1.2 : 0
            width: dataEditor.width - (generalView.vBarVisible ? gvScrollBar.width : 0)
            Label {
                text: interactiveVisibility[section] ? Z.tr(propName) : ""
                Layout.minimumWidth: dataEditor.width / 4;
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: lineEdit
                text: customerDataVein[propName]
                Layout.fillWidth: true
                height: dataEditor.rowHeight*1.2
                visible: interactiveVisibility[section]
                function startFocusDelay() {
                    generalView.currentIndex = index
                    focusDelayForVirtKeyboard.start()
                }
                Timer {
                    id: focusDelayForVirtKeyboard
                    repeat: false
                    interval: 300
                    onTriggered: lineEdit.textField.forceActiveFocus()
                }
                onTextChanged: updateDataObject(propName, text)
                function focusNext() {
                    let nextItem = generalView.itemAtIndex(index + 1)
                    if (nextItem)
                        nextItem.children[1].startFocusDelay()
                }
                function tryOpenNextSection() {
                    let nextSection = getNextSection(propName)
                    if (nextSection !== "")
                        interactiveVisibility[nextSection] = true
                }
                function doApplyInput(newText) {
                    tryOpenNextSection()
                    focusNext()
                    return true
                }
                textField.horizontalAlignment: Text.AlignLeft
            }
        }

        section.property: "section"
        section.criteria: ViewSection.FullString
        section.delegate: RowLayout {
            width: dataEditor.width - (generalView.vBarVisible ? gvScrollBar.width : 0)
            height: rowHeight * largeScale
            Label {
                verticalAlignment: Text.AlignVCenter
                text: Z.tr(section)
                font.pointSize: pointSize * largeScale
                Layout.fillHeight: true
                font.bold: true
            }
            Item {Layout.fillWidth: true}
            ZCheckBox {
                text: Z.tr("Show")
                checked: interactiveVisibility[section]
                Layout.preferredHeight: rowHeight
                onCheckedChanged: {
                    interactiveVisibility[section] = checked
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: gvScrollBar
            policy: generalView.vBarVisible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }
    }
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        id: buttonContainer
        height: rowHeight * 1.5

        Item {
            // spacer
            Layout.fillWidth: true
        }
        ZButton {
            id: cancelButton
            text: Z.tr("Cancel")
            font.pointSize: pointSize * largeScale
            Layout.minimumWidth: okButton.width
            Layout.fillHeight: true
            onClicked: {
                cancel()
            }
        }
        ZButton {
            id: okButton
            text: Z.tr("OK")
            font.pointSize: pointSize * largeScale
            Layout.minimumWidth: cancelButton.width
            Layout.fillHeight: true
            onClicked: {
                ok()
            }
        }
    }
}
