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
    readonly property real rowHeight: parent.height / 15

    Component.onCompleted: {
        initModel();
    }

    readonly property QtObject customerData: VeinEntity.getEntity("CustomerData");

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
    readonly property string currentFile: customerData.FileSelected
    onCurrentFileChanged: {
        //data becomes irrelevant if the file switches
        editableDataObject = ({});
    }

    readonly property string basicSectionName: "Basic"
    readonly property string customerSectionName: "Customer"
    readonly property string powerGridSectionName: "Power grid"
    readonly property string locationSectionName: "Location"
    readonly property string meterInfoSectionName: "Meter information"

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
            customerData[prop] = editableDataObject[prop];
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
                height: dataEditor.rowHeight
            }
            ZLineEdit {
                text: customerData[propName]
                Layout.fillWidth: true
                height: dataEditor.rowHeight*1.2
                visible: interactiveVisibility[section]
                onTextChanged: updateDataObject(propName, text)
                textField.horizontalAlignment: Text.AlignLeft
            }
        }

        section.property: "section"
        section.criteria: ViewSection.FullString
        section.delegate: RowLayout {
            width: dataEditor.width - (generalView.vBarVisible ? gvScrollBar.width : 0)
            Label {
                height: dataEditor.rowHeight*1.5
                verticalAlignment: Text.AlignBottom
                text: Z.tr(section)
                font.pointSize: 16
                font.bold: true
            }
            Item {Layout.fillWidth: true}
            CheckBox {
                text: Z.tr("Show")
                checked: interactiveVisibility[section]
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
        Layout.alignment: Qt.AlignHCenter
        id: buttonContainer
        height: parent.height / 10
        width: parent.width

        Item {
            // spacer
            Layout.fillWidth: true
        }
        Button {
            id: cancelButton
            text: Z.tr("Cancel")
            Layout.minimumWidth: okButton.width
            onClicked: {
                cancel()
            }
        }
        Button {
            id: okButton
            text: Z.tr("OK")
            Layout.minimumWidth: cancelButton.width
            onClicked: {
                ok()
            }
        }
    }
}
