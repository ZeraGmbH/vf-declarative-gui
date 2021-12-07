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
        WaitTransaction {
            id: waitPopup
            animationComponent: AnimationSlowBits { }
        }
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

                property string currentConnectionType
                readonly property string labelDisconnected: Z.tr("Not connected")
                readonly property string labelScpi: Z.tr("Serial SCPI")
                readonly property string labelSource: Z.tr("Source device")

                function getInitialConnectionTypeStr() {
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
                    currentConnectionType = getInitialConnectionTypeStr()
                    setComboSelection(currentConnectionType)
                }

                property bool ignoreSelectionChange: true
                function setComboSelection(connectionTypeStr) {
                    let selectIdx = 0
                    if(connectionTypeStr !== "") {
                        for(let idx=0; idx<model.length; ++idx) {
                            if(model[idx] === connectionTypeStr) {
                                selectIdx = idx
                                break
                            }
                        }
                    }
                    ignoreSelectionChange = true
                    comboConnectionType.targetIndex = selectIdx
                    ignoreSelectionChange = false
                }

                // User selection
                onCurrentTextChanged: {
                    if(!ignoreSelectionChange && currentText !== currentConnectionType) {
                        let waitText = ""
                        // (Re-)connect
                        if(currentText === labelSource) {
                            waitText = "Scanning for source device..."
                        }
                        else if(currentText === labelScpi) {
                            waitText = "Opening SCPI serial..."
                        }
                        // Disconnect
                        else if(currentText === labelDisconnected) {
                            if(currentConnectionType === labelSource) {
                                waitText = "Disconnect source..."
                            }
                            if(currentConnectionType === labelScpi) {
                                waitText = "Disconnect scpi serial..."
                            }
                        }
                        waitPopup.startWait(waitText)
                        startNextAction()
                    }
                }

                // SCPI type connect / disconnect
                property bool scpiConnected: scpiEntity ? scpiEntity.PAR_SerialScpiActive : false
                function setScpiConnected(connected) {
                    scpiEntity.PAR_SerialScpiActive = connected
                }
                onScpiConnectedChanged: {
                    if(canSCPI) {
                        if(scpiConnected) {
                            currentConnectionType = currentText
                            waitPopup.stopWait([], [], null)
                        }
                        else {
                            handleDisconnect()
                        }
                    }
                }

                // Source type connect / disconnect
                property var connectRpcId
                property var disconnectRpcId
                Connections {
                    target: sourceEntity
                    function onSigRPCFinished(t_identifier) {
                        let ok = t_resultData["RemoteProcedureData::resultCode"] === 0
                        if(t_identifier === comboConnectionType.connectRpcId) {
                            comboConnectionType.connectRpcId = undefined
                            if(ok) {
                                comboConnectionType.currentConnectionType = comboConnectionType.currentText
                                waitPopup.stopWait([], [], null)
                            }
                            else {
                                comboConnectionType.setComboSelection(comboConnectionType.currentConnectionType)
                                waitPopup.stopWait([], ['No source found'], null)
                            }
                        }
                        if(t_identifier === comboConnectionType.disconnectRpcId) {
                            comboConnectionType.disconnectRpcId = undefined
                            if(ok) {
                                comboConnectionType.handleDisconnect()
                            }
                            else {
                                setComboSelection(comboConnectionType.currentConnectionType)
                                waitPopup.stopWait(['SCPI disconnect failed'], [], null)
                            }
                        }
                    }
                }
                function startDisconnectSource() {
                    if(!disconnectRpcId) {
                        disconnectRpcId = sourceEntity.invokeRPC("RPC_CloseSource(QString p_deviceInfo)", {
                                                                 "p_deviceInfo": ttyDev })
                    }
                }
                function startConnectSource() {
                    if(!connectRpcId) {
                        connectRpcId = sourceEntity.invokeRPC("RPC_ScanInterface(QString p_deviceInfo,int p_type)", {
                                                              "p_type": 2,
                                                              "p_deviceInfo": ttyDev })
                    }
                }
                // lazy state machine
                function handleDisconnect() {
                    currentConnectionType = labelDisconnected
                    startNextAction()
                }
                function startNextAction() {
                    let nextStarted = false
                    if(currentConnectionType === labelScpi) {
                        setScpiConnected(false)
                        nextStarted = true
                    }
                    else if(currentConnectionType === labelSource) {
                        startDisconnectSource()
                        nextStarted = true
                    }
                    else if(currentText == labelScpi) {
                        setScpiConnected(true)
                        nextStarted = true
                    }
                    else if(currentText == labelSource) {
                        startConnectSource()
                        nextStarted = true
                    }
                    if(!nextStarted) {
                        waitPopup.stopWait([], [], null)
                    }
                }
            }
        }
    }
}
