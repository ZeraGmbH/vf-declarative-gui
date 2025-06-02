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
import ".."
import "../../helpers"

Item {
    property real pointSize
    property real rowHeight

    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    readonly property var ttysJson: filesEntity ? filesEntity.Ttys : {}
    readonly property var ttys: filesEntity ? Object.keys(ttysJson) : []
    readonly property var ttyCount: filesEntity ? Object.keys(ttysJson).length : 0

    readonly property QtObject scpiEntity: VeinEntity.getEntity("SCPIModule1")
    readonly property string scpiSerial: scpiEntity ? scpiEntity.ACT_SerialScpiDeviceFile : ""

    readonly property QtObject sourceEntity: VeinEntity.getEntity("SourceModule1")
    readonly property int maxSourceCount: sourceEntity ? sourceEntity.ACT_MaxSources : 0

    visible: height > 0 && (sourceEntity || scpiEntity)

    WaitTransaction {
        id: waitPopup
    }
    property var warningsCollected: []
    property var errorsCollected: []

    readonly property int connTypeDisconnected: 0
    readonly property int connTypeScpi: 1
    readonly property int connTypeSouce: 2

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
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Label {
                text: ttysJson[modelData].manufacturer + ":"
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZComboBox {
                id: comboConnectionType
                arrayMode: true
                Layout.preferredWidth: root.width * 0.32
                Layout.preferredHeight: rowHeight-8

                property bool canSCPI: scpiEntity && ttyRow.ttyDev === scpiSerial
                property var enumModel
                model: {
                    let ret = []
                    let retEnum = []
                    ret.push(Z.tr("Not connected"))
                    retEnum.push(connTypeDisconnected)
                    if(sourceEntity) {
                        ret.push(Z.tr("Source device"))
                        retEnum.push(connTypeSouce)
                    }
                    if(canSCPI) {
                        ret.push(Z.tr("Serial SCPI"))
                        retEnum.push(connTypeScpi)
                    }
                    enumModel = retEnum
                    return ret
                }
                onModelChanged: {
                    setComboSelectionFromVein()
                }
                function getConnectionTypeFromVein() {
                    let connectionType = connTypeDisconnected
                    if(canSCPI && scpiConnected) {
                        connectionType = connTypeScpi
                    }
                    else {
                        for(let slot=0; slot<maxSourceCount; ++slot) {
                            let status = sourceEntity["ACT_DeviceState%1".arg(slot)]
                            if(status["deviceinfo"] === ttyRow.ttyDev) {
                                connectionType = connTypeSouce
                            }
                        }
                    }
                    return connectionType
                }
                property bool ignoreSelectionChange: true
                function setComboSelection(connectionType) {
                    let selectIdx = 0
                    for(let idx=0; idx<model.length; ++idx) {
                        if(enumModel[idx] === connectionType) {
                            selectIdx = idx
                            break
                        }
                    }
                    ignoreSelectionChange = true
                    comboConnectionType.targetIndex = selectIdx
                    lastIndex = selectIdx
                    if(connectionType !== connTypeDisconnected) {
                        let colorPrefix = "<font color='" + Qt.lighter(Material.color(Material.Amber)) + "'>"
                        let colorPostfix = "</font>"
                        currentText = colorPrefix + currentText + colorPostfix
                    }
                    ignoreSelectionChange = false
                }
                function setComboSelectionFromVein() {
                    setComboSelection(getConnectionTypeFromVein())
                }

                // user selection
                property int lastIndex
                onTargetIndexChanged: { // onCurrentIndexChanged does not work!
                    if(!ignoreSelectionChange) {
                        let connectionTypeTarget = enumModel[targetIndex]
                        let connectionTypeCurrent = enumModel[lastIndex]
                        lastIndex = targetIndex

                        let waitText = getWaitTitle(connectionTypeTarget, connectionTypeCurrent)
                        fillTaskList(connectionTypeTarget, connectionTypeCurrent)

                        waitPopup.startWait(waitText)
                        taskList.startRun()
                    }
                }
                TaskList {
                    id: taskList
                    Connections {
                        function onDone(error) {
                            comboConnectionType.setComboSelectionFromVein()
                            waitPopup.stopWait(warningsCollected, errorsCollected, null)
                            warningsCollected = []
                            errorsCollected = []
                        }
                    }
                }
                function getWaitTitle(connectionTypeTarget, connectionTypeCurrent) {
                    if(connectionTypeTarget === connTypeSouce) {
                        return Z.tr("Scanning for source device...")
                    }
                    if(connectionTypeTarget === connTypeScpi) {
                        return Z.tr("Opening SCPI serial...")
                    }
                    if(connectionTypeTarget === connTypeDisconnected) {
                        if(connectionTypeCurrent === connTypeSouce) {
                            return Z.tr("Disconnect source...")
                        }
                        else {
                            return Z.tr("Disconnect SCPI serial...")
                        }
                    }
                }
                function fillTaskList(connectionTypeTarget, connectionTypeCurrent) {
                    let scpiDisconnect = connectionTypeCurrent === connTypeScpi
                    let sourceDisconnect = connectionTypeCurrent === connTypeSouce
                    let scpiConnect = connectionTypeTarget === connTypeScpi
                    let sourceConnect = connectionTypeTarget === connTypeSouce

                    let taskArray = []
                    if(scpiDisconnect) {
                        taskArray.push( { 'type': 'unblock',
                                          'callFunction': () => setScpiConnected(false)
                                        })
                    }
                    if(sourceDisconnect) {
                        taskArray.push( { 'type': 'rpc',
                                          'rpcTarget': sourceEntity,
                                          'callFunction': () => startDisconnectSource(),
                                          'notifyCallback': (t_resultData) => disconnectSourceCallback(t_resultData)
                                        })
                    }
                    if(scpiConnect) {
                        taskArray.push( { 'type': 'unblock',
                                          'callFunction': () => setScpiConnected(true)
                                        })
                    }
                    if(sourceConnect) {
                        taskArray.push( { 'type': 'rpc',
                                          'rpcTarget': sourceEntity,
                                          'callFunction': () => startConnectSource(),
                                          'notifyCallback': (t_resultData) => connectSourceCallback(t_resultData)
                                        })
                    }
                    taskList.taskArray = taskArray
                }

                readonly property bool connected: scpiConnected || getConnectionTypeFromVein() !== connTypeDisconnected

                // SCPI type connect / disconnect
                readonly property bool scpiConnected: canSCPI && scpiEntity ? scpiEntity.PAR_SerialScpiActive : false
                function setScpiConnected(connected) {
                    scpiEntity.PAR_SerialScpiActive = connected
                    return true
                }
                onScpiConnectedChanged: {
                    if(taskList.running) {
                        taskList.startNextTask()
                    }
                    else {
                        setComboSelectionFromVein()
                    }
                }

                // Source type connect / disconnect
                function startDisconnectSource() {
                    return sourceEntity.invokeRPC("RPC_CloseSource(QString p_deviceInfo)", {
                                                  "p_deviceInfo": ttyDev })
                }
                function disconnectSourceCallback(t_resultData) {
                    let ok = t_resultData["RemoteProcedureData::resultCode"] === 0
                    if(!ok) {
                        warningsCollected.push(Z.tr('Source switch off failed'))
                    }
                    return true
                }
                function startConnectSource() {
                    return sourceEntity.invokeRPC("RPC_ScanInterface(QString p_deviceInfo,int p_type)", {
                                                  "p_type": 2,
                                                  "p_deviceInfo": ttyDev })
                }
                function connectSourceCallback(t_resultData) {
                    let ok = t_resultData["RemoteProcedureData::resultCode"] === 0
                    if(!ok) {
                        errorsCollected.push(Z.tr('No source found'))
                    }
                    return ok
                }
            }
        }
    }
}
