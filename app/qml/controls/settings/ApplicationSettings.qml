import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.14
import QtQuick.Controls.Material 2.0
import SessionState 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import AppStarterForWebGLSingleton 1.0
import AppStarterForWebserverSingleton 1.0
import AppStarterForApi 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraTranslationBackend 1.0
import ZeraComponents 1.0
import anmsettings 1.0
import ZeraLocale 1.0
import SlowMachineSettingsHelper 1.0
import FontAwesomeQml 1.0

SettingsView {
    id: root

    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    readonly property real safeHeight: height > 0.0 ? height : 10
    rowHeight: safeHeight / 7.1
    readonly property real pointSize: rowHeight * 0.275

    ApiInfoPopup {
        id: apiInfoPopup
    }

    TrustListPopup {
        id: trustListPopup
    }

    ColorPicker {
        id: colorPicker
        // set at rButton.onClicked
        property int systemIndex

        dim: true
        x: parent.width/2 - width/2
        width: root.width*0.7
        height: root.safeHeight*0.7
        onColorAccepted: {
            GC.setSystemColorByIndex(systemIndex, t_color)
        }
    }

    DefaultColorPopup {
        id: defaultColoursPopup
        x: root.width * 5 / 10
        y: 0
        height: root.safeHeight - y
        width: root.width - x
    }

    TimeSetterPopup {
        id: timesetterPopup
        pointSize: root.pointSize
    }

    readonly property real comboWidth: 4.5
    model: ObjectModel {
        Item {
            height: ASWGL.isServer ? 0: root.rowHeight
            width: root.rowWidth
            visible: !ASWGL.isServer
            RowLayout {
                anchors.fill: parent
                Label {
                    text: Z.tr("Display:")
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Label.AlignVCenter
                }
                ZComboBox {
                    id: xsessionSelector
                    arrayMode: true
                    readonly property var rawModel: ModuleIntrospection.systemIntrospection.ComponentInfo.XSession.Validation.Data
                    model: {
                        let xSessionsDisplay = []
                        for(let idx=0; idx<rawModel.length; ++idx) {
                            let text = rawModel[idx]
                            if(text === "Desktop")
                                text = "Desktop (slow)"
                            xSessionsDisplay.push(Z.tr(text))
                        }
                        return xSessionsDisplay
                    }
                    Layout.preferredHeight: root.rowHeight * 0.9
                    Layout.preferredWidth: Layout.preferredHeight * comboWidth
                    targetIndex: {
                        for(let idx=0; idx<rawModel.length; ++idx)
                            if(rawModel[idx] === VeinEntity.getEntity("_System").XSession)
                                return idx
                        return 0
                    }
                    onTargetIndexChanged: {
                        let newSessionName = rawModel[targetIndex]
                        VeinEntity.getEntity("_System").XSession = newSessionName
                    }
                }
            }
        }
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Language:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZVisualComboBox {
                id: localeCB
                model: ZTR.localesModel
                imageModel: ZTR.flagsModel
                Layout.preferredHeight: root.rowHeight * 0.9
                Layout.preferredWidth: Layout.preferredHeight * comboWidth
                property string intermediate: ZLocale.localeName

                onIntermediateChanged: {
                    if(model[currentIndex] !== intermediate) {
                        currentIndex = model.indexOf(intermediate)
                    }
                }
                onSelectedTextChanged: {
                    if(ZLocale.localeName !== selectedText) {
                        GC.setLocale(selectedText, true)
                    }
                }
            }
        }
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                textFormat: Text.PlainText
                text: Z.tr("Date/Time:")
                font.pointSize: pointSize
                Layout.rightMargin: pointSize*2
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Label {
                id: currentTime
                text: {
                    let now = ZTR.dateTimeNow
                    return ZTR.trDateTimeShort(now) + " (" + ZTR.trDateTimeTz(now) + ")"
                }
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignLeft
            }
            Button {
                id: openTimeSetPopupButton
                text: FAQ.fa_cogs
                font.pointSize: pointSize * 1.2
                Layout.leftMargin: rowHeight * 0.1
                Layout.fillHeight: true
                Layout.preferredWidth: rowHeight * 0.95
                onClicked: timesetterPopup.open()
            }
        }
        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Max decimals total:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZSpinBox {
                id: actDecimalPlacesTotal
                Layout.fillHeight: true
                pointSize: root.pointSize
                spinBox.width: root.rowWidth / 4
                Component.onCompleted: text = GC.digitsTotal
                validator: IntValidator {
                    bottom: 1
                    top: 7
                }
                function doApplyInput(newText) {
                    SlwMachSettingsHelper.startDigitsTotalChange(newText)
                    return true
                }
            }
        }

        RowLayout {
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("Max places after the decimal point:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ZSpinBox {
                id: actDecimalPlaces
                Layout.fillHeight: true
                pointSize: root.pointSize
                spinBox.width: root.rowWidth / 4
                Component.onCompleted: text = GC.decimalPlaces
                validator: IntValidator {
                    bottom: 1
                    top: 7
                }
                function doApplyInput(newText) {
                    SlwMachSettingsHelper.startDecimalPlacesChange(newText)
                    return true
                }
            }
        }

        RowLayout {
            visible: !SessionState.refSession
            height: root.rowHeight
            width: root.rowWidth
            Label {
                text: Z.tr("System colors:")
                textFormat: Text.PlainText
                font.pointSize: pointSize
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            ListView {
                clip: true
                interactive: false
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: root.channelCount
                orientation: ListView.Horizontal
                layoutDirection: "RightToLeft"
                spacing: 2
                delegate: Button {
                    id: rButton
                    width: pointSize * 3.4
                    height: rowHeight
                    font.pointSize: pointSize * 0.65
                    text: {
                        let workingIndex = root.channelCount-index
                        let colorLead = "<font color='" + SlwMachSettingsHelper.getCurrentColor(workingIndex) + "'>"
                        let colorTrail = "</font>"
                        return colorLead + Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(workingIndex)+"Range"].ChannelName) + colorTrail
                    }
                    onClicked: {
                        colorPicker.systemIndex = root.channelCount-index
                        /// @bug setting the the same value twice doesn't reset the sliders
                        colorPicker.oldColor = "transparent"
                        colorPicker.oldColor = SlwMachSettingsHelper.getCurrentColor(colorPicker.systemIndex)
                        colorPicker.open()
                    }
                }
            }
            Button {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillHeight: true
                Layout.preferredWidth: root.rowHeight * 0.7
                font.pointSize: root.rowHeight * 0.2
                text: "▼"
                onClicked: {
                    defaultColoursPopup.open()
                }
            }
        }

        Item {
            height: ASWGL.isServer ? 0 : root.rowHeight
            width: root.rowWidth
            visible: !ASWGL.isServer
            RowLayout {
                anchors.fill: parent
                Label {
                    text: Z.tr("Web-Server:")
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillHeight: true
                    Layout.rightMargin: parent.height * 0.1
                    verticalAlignment: Label.AlignVCenter
                }
                Rectangle {
                    id: rectWebServer
                    opacity: ASWS.run
                    Layout.fillHeight: true;
                    Layout.fillWidth: true;
                    Layout.topMargin: parent.height * 0.1
                    Layout.bottomMargin: Layout.topMargin
                    color: Material.backgroundDimColor
                    radius: 4

                    InfoInterface { id: realNetworkListModel }
                    readonly property bool isNetworkConnected: realNetworkListModel.entryCount > 0
                    readonly property real textPointSize: pointSize * 0.85
                    readonly property real textMarginHorizontal: parent.height / 6
                    ListView {
                        id: ipWebServer
                        visible: rectWebServer.isNetworkConnected
                        anchors { fill: parent; verticalCenter: parent.verticalCenter;
                                  leftMargin: rectWebServer.textMarginHorizontal;
                                  rightMargin: rectWebServer.textMarginHorizontal }
                        boundsBehavior: Flickable.OvershootBounds
                        orientation: ListView.Horizontal
                        spacing: parent.height / 2
                        model: realNetworkListModel
                        delegate: Text {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pointSize: rectWebServer.textPointSize
                            textFormat: Text.PlainText
                            text: ipv4 + " : " + ASWS.port
                        }
                    }
                    Text {
                        id: ipWebServerNotConnected
                        visible: !rectWebServer.isNetworkConnected
                        anchors { fill: parent; verticalCenter: parent.verticalCenter;
                                  leftMargin: rectWebServer.textMarginHorizontal;
                                  rightMargin: rectWebServer.textMarginHorizontal }
                        verticalAlignment: Text.AlignVCenter
                        text: Z.tr("Not connected")
                        font.pointSize: rectWebServer.textPointSize
                    }
                }
                ZCheckBox {
                    id: webServerOnOff
                    Layout.fillHeight: true
                    checked: ASWGL.running
                    onCheckedChanged: {
                        ASWS.run = checked
                        let userWantsOn = !ASWGL.running && checked
                        if(userWantsOn)
                            GC.setWebRemoteOn(true)
                        let userWantsOff = ASWGL.running && !checked
                        if(userWantsOff)
                            GC.setWebRemoteOn(false)
                        ASWGL.running = checked
                    }
                }
            }
        }

        Item {
            height: root.rowHeight
            width: root.rowWidth
            visible: true
            RowLayout {
                anchors.fill: parent
                Label {
                    text: Z.tr("API-Access:")
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillHeight: true
                    Layout.rightMargin: parent.height * 0.1
                    verticalAlignment: Label.AlignVCenter
                }
                Rectangle {
                    id: rectApiInfo
                    opacity: ASAPI.running
                    Layout.fillHeight: true;
                    Layout.fillWidth: true;
                    Layout.topMargin: parent.height * 0.1
                    Layout.bottomMargin: Layout.topMargin
                    color: Material.backgroundDimColor
                    radius: 4

                    InfoInterface { id: realNetworkListModelApi }
                    readonly property bool isNetworkConnected: realNetworkListModelApi.entryCount > 0
                    readonly property real textPointSize: pointSize * 0.85
                    readonly property real textMarginHorizontal: parent.height / 6
                    ListView {
                        id: ipApi
                        clip: true
                        visible: rectApiInfo.isNetworkConnected
                        anchors { fill: parent; verticalCenter: parent.verticalCenter;
                                  leftMargin: rectApiInfo.textMarginHorizontal;
                                  rightMargin: rectApiInfo.textMarginHorizontal }
                        boundsBehavior: Flickable.OvershootBounds
                        orientation: ListView.Horizontal
                        spacing: parent.height / 2
                        model: realNetworkListModelApi
                        delegate: Text {
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pointSize: rectApiInfo.textPointSize
                            textFormat: Text.PlainText
                            text: ipv4 + " : " + ASAPI.port
                        }
                    }
                    Text {
                        id: ipApiNotConnected
                        visible: !rectApiInfo.isNetworkConnected
                        anchors { fill: parent; verticalCenter: parent.verticalCenter;
                                  leftMargin: rectApiInfo.textMarginHorizontal;
                                  rightMargin: rectApiInfo.textMarginHorizontal }
                        verticalAlignment: Text.AlignVCenter
                        text: Z.tr("Not connected")
                        font.pointSize: rectApiInfo.textPointSize
                    }
                }
                Button {
                    id: apiTrustThumb
                    visible: ASAPI.running
                    text: FAQ.fa_info_circle
                    Layout.fillHeight: true
                    font.pointSize: pointSize * 1.2
                    Layout.preferredWidth: rowHeight * 0.95
                    onClicked: apiInfoPopup.open()
                }
                Button {
                    id: apiTrustList
                    text: FAQ.fa_cogs
                    Layout.fillHeight: true
                    font.pointSize: pointSize * 1.2
                    Layout.preferredWidth: rowHeight * 0.95
                    onClicked: trustListPopup.open()
                }
                ZCheckBox {
                    id: apiOnOff
                    Layout.fillHeight: true
                    checked: ASAPI.running
                    onCheckedChanged: {
                        let userWantsOn = !ASAPI.running && checked
                        if(userWantsOn)
                            GC.setRemoteApiOn(true)
                        let userWantsOff = ASAPI.running && !checked
                        if(userWantsOff)
                            GC.setRemoteApiOn(false)
                        ASAPI.running = checked
                    }
                }
            }
        }
    }
}
