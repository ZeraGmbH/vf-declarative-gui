import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtQml.Models 2.14
import QtQuick.Controls.Material 2.14
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraComponents 1.0
import ZeraTranslation 1.0

Item {
    property real pointSize
    property real rowHeight

    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    readonly property var ttysJson: filesEntity === undefined ? {} : filesEntity.Ttys
    readonly property var ttys: filesEntity === undefined ? [] : Object.keys(ttysJson)
    readonly property var ttyCount: filesEntity === undefined ? 0 : Object.keys(ttysJson).length

    readonly property QtObject scpiEntity: VeinEntity.getEntity("SCPIModule1")
    readonly property string scpiSerial: scpiEntity ? scpiEntity.ACT_SerialScpiDeviceFile : ""

    readonly property QtObject sourceEntity: VeinEntity.getEntity("SourceModule1")
    readonly property int maxSourceCount: sourceEntity ? sourceEntity.ACT_MaxSources : 0

    visible: height > 0 && (sourceEntity || scpiEntity)

    ListView {
        anchors.fill: parent
        model: ttys
        clip: true
        boundsBehavior: ListView.OvershootBounds
        delegate: RowLayout {
            id: ttyRow
            property var ttyDev: modelData
            height: rowHeight
            width: parent.width
            Label {
                text: modelData.replace('/dev/tty', '') + " / "
                font.pointSize: pointSize
            }
            Label {
                text: ttysJson[modelData].manufacturer + ":"
                Layout.fillWidth: true
                font.pointSize: pointSize
            }
            ZComboBox {
                id: comboConnectionType
                arrayMode: true
                property bool canSCPI: scpiEntity && ttyRow.ttyDev === scpiSerial
                readonly property string labelDisconnected: Z.tr("Not connected")
                readonly property string labelScpi: Z.tr("Serial SCPI")
                readonly property string labelSource: Z.tr("Source device")
                model: {
                    let ret = []
                    ret.push(labelDisconnected)
                    // Global setting will go once we are ready to ship
                    if(sourceEntity && GC.sourceConnectEnabled) {
                        ret.push(labelSource)
                    }
                    if(canSCPI) {
                        ret.push(labelScpi)
                    }
                    return ret
                }
                centerVertical: true
                implicitWidth: root.width * 0.3
                fontSize: pointSize*1.4
                height: rowHeight-8

                property bool ignoreSelectionChange: true
                property string currentConnectionType
                function setComboSelection(idx) {
                    ignoreSelectionChange = true
                    comboConnectionType.targetIndex = idx
                    ignoreSelectionChange = false
                }
                function getComboIdx(strContent) {
                    let selection = 0
                    if(strContent !== "") {
                        for(let idx=0; idx<model.length; ++idx) {
                            if(model[idx] === strContent) {
                                selection = idx
                                break
                            }
                        }
                    }
                    return selection
                }
                function getCurrentConnectionTypeStr() {
                    let selectStr = ""
                    if(canSCPI && scpiConnected) {
                        selectStr = labelScpi
                    }
                    else {
                        for(let slot=0; slot<maxSourceCount; ++slot) {
                            let status = sourceEntity["ACT_DeviceState%1".arg(slot)]
                            if(status["deviceinfo"] === ttyRow.ttyDev) {
                                selectStr = labelSource
                            }
                        }
                    }
                    return selectStr
                }
                Component.onCompleted: {
                    currentConnectionType = getCurrentConnectionTypeStr()
                    setComboSelection(getComboIdx(currentConnectionType))
                }

                // SCPI type connect / disconnect
                property bool scpiConnected: scpiEntity ? scpiEntity.PAR_SerialScpiActive : false
                function setScpiConnected(connected) {
                    scpiEntity.PAR_SerialScpiActive = connected
                }
                onScpiConnectedChanged: {
                    if(canSCPI) {
                        currentConnectionType = scpiConnected ? currentText : ""
                        if(!scpiConnected) {
                            startNextAction()
                        }
                    }
                }
                function startDisconnectScpi() {
                    setScpiConnected(false)
                }
                function startConnectScpi() {
                    setScpiConnected(true)
                }

                // Source type connect / disconnect
                function startDisconnectSource() {

                    // move to cmd response
                    currentConnectionType = ""
                    startNextAction()
                }
                function startConnectSource() {

                    // move to cmd response
                    currentConnectionType = currentText
                }
                function startNextAction() {
                    if(currentConnectionType === labelScpi) {
                        startDisconnectScpi()
                    }
                    else if(currentConnectionType === labelSource) {
                        startDisconnectSource()
                    }
                    else if(currentText == labelScpi) {
                        startConnectScpi()
                    }
                    else if(currentText == labelSource) {
                        startConnectSource()
                    }
                }
                onCurrentTextChanged: {
                    if(!ignoreSelectionChange && currentText !== currentConnectionType) {
                        startNextAction()
                    }
                }
            }
        }
    }
}
