import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0


Item {
    id: root

    // we need a reference to menu stack layout to call showSessionNameSelector
    property var menuStackLayout

    // layout calculations
    readonly property real rowHeight: parent.height > 0 ? parent.height/8 : 10
    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale
    readonly property real visibleWidth: parent.width - 2*GC.standardTextHorizMargin
    readonly property real labelWidth: visibleWidth / 4
    readonly property real contentWidth: visibleWidth * 3 / 4

    // vein entities
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    property QtObject exportEntity: VeinEntity.getEntity("ExportModule")
    property QtObject filesEntity: VeinEntity.getEntity("_Files")
    property QtObject statusEntity: VeinEntity.getEntity("StatusModule1")
    // vein components for convenience
    readonly property string databaseName: loggerEntity ? loggerEntity.DatabaseFile : ""
    readonly property string sessionName: loggerEntity ? loggerEntity.sessionName : ""
    readonly property var mountedPaths: filesEntity ? filesEntity.AutoMountedPaths : []
    readonly property var devicePath: statusEntity ? "zera-" + statusEntity.INF_DeviceType + '-' + statusEntity.PAR_SerialNr : "zera-undef"

    // make current export type commonly accessible / set by combo export type
    property string exportType
    // make current output path commonly accessible / set by combo target drive
    property string selectedMountPath
    // this is the filename for non vf-export export (=simple copying of database currently)
    property string targetFilePath

    // auto pass parameters to vf-export
    onDatabaseNameChanged: {
        exportEntity.PAR_InputPath = databaseName
        exportEntity.PAR_Session = sessionName
    }

    // keep storage paths
    function setOutputPath() {
        var storagePath = selectedMountPath + '/' + devicePath
        switch(exportType) {
        case "EXPORT_TYPE_MTVIS":
            exportEntity.PAR_OutputPath = storagePath + "/mtvis/" + editExportName.text
            break
        case "EXPORT_TYPE_SQLITE":
            targetFilePath = storagePath + "/datbase/" + editExportName.text
            break
        }
    }

    // 'enumerate' our export types
    readonly property var exportTypeEnum: {
        "EXPORT_TYPE_MTVIS": 0,
        "EXPORT_TYPE_SQLITE": 1,
    }

    // and the visible items
    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Export stored data")
        font.pointSize: pointSize * 1.5
        height: rowHeight
    }
    Column {
        id: selectionColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.bottom: buttonExport.top
        Row { // Export type
            height: rowHeight
            Label {
                text: Z.tr("Export type:")
                width: labelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                font.pointSize: pointSize
            }
            ComboBox {
                width: contentWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pointSize: root.pointSize
                model: [
                    { value: "EXPORT_TYPE_MTVIS",  label: Z.tr("MtVis XML") + (sessionName === "" ? "" : " (" + sessionName + ")") },
                    { value: "EXPORT_TYPE_SQLITE", label: Z.tr("SQLite DB (complete)") },
                ]
                textRole: "label"
                onCurrentIndexChanged: {
                    exportType = model[currentIndex].value // tried property binding but that did not work
                }
            }
        }
        Row { // Target drive (visible only if more than one drive is inserted)
            height: rowHeight
            visible: mountedPaths.length > 1
            Label {
                text: Z.tr("Target drive:")
                width: labelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                font.pointSize: pointSize
            }
            ComboBox {
                width: contentWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                font.pointSize: root.pointSize
                model: mountedPaths // TODO: make human readable
                onCurrentIndexChanged: {
                    selectedMountPath = model[currentIndex]
                    setOutputPath()
                }
            }
        }
        Row { // Export Name
            height: rowHeight
            visible: exportType !== "EXPORT_TYPE_MTVIS" || sessionName !== ""
            Label {
                text: Z.tr("Export name:");
                width: labelWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: editExportName
                width: contentWidth
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
                textField.anchors.rightMargin: 0
                property alias aliasExportType: root.exportType
                validator: RegExpValidator {
                    // our target is windows most likely so to avoid trouble:
                    // * allow lower case only - Windows is not case sensitive
                    // * start with a letter
                    // * for MTVis: do not allow '.' for paths
                    property var regExMTVis: /^[a-z][_\-a-z0-9]*$/
                    property var regExMTDB: /^[a-z][._\-a-z0-9]*$/
                    regExp: {
                        var regEx
                        switch(exportType) {
                        case "EXPORT_TYPE_MTVIS":
                            regEx = regExMTVis
                            break;
                        case "EXPORT_TYPE_SQLITE":
                            regEx = regExMTDB
                            break;
                        }
                        return regEx
                    }
                }
                onAliasExportTypeChanged: {
                    switch(exportType) {
                    case "EXPORT_TYPE_MTVIS":
                        // suggest sessionName (yes we need to ask for overwrite e.g for the cause
                        // of multiple storining of same session name in multiple dbs)
                        text = sessionName
                        readOnly = sessionName === ""
                        placeholderText = Z.tr("Name of export path")
                        break
                    case "EXPORT_TYPE_SQLITE":
                        text = databaseName.substr(databaseName.lastIndexOf('/') + 1)
                        readOnly = true
                        placeholderText = ""
                        break
                    }
                    setOutputPath()
                }
                onTextChanged: {
                    setOutputPath()
                }
            }
        }
        Button { // Quick link to select session form here
            height: rowHeight
            visible: exportType === "EXPORT_TYPE_MTVIS" && sessionName === ""
            id: buttonSessionSelect
            width: contentWidth
            anchors.right: parent.right
            text: Z.tr("Please select a session first...")
            font.pointSize: pointSize
            onClicked: {
                menuStackLayout.showSessionNameSelector()
            }
        }
    }
    Button { // the export 'action' button
        id: buttonExport
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        height: rowHeight
        text: Z.tr("Export")
        font.pointSize: pointSize
        enabled: {
            var _enabled = editExportName.hasValidInput()
            switch(exportType) {
            case "EXPORT_TYPE_MTVIS":
                _enabled = _enabled && sessionName !== ""
                break
            }
            return _enabled
        }
        onClicked: {
            // TODO RPC-business
        }
    }
}
