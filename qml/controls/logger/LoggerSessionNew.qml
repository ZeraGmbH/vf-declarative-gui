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
    // we need a reference to menu stack layout to move around
    property var menuStackLayout

    readonly property real rowHeight: parent.height/12
    readonly property real fontScale: 0.45
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real scrollWidth: 16

    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    property QtObject customerData: VeinEntity.getEntity("CustomerData")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")
    readonly property var availableCustomerDataFiles: filesEntity === undefined ? [] : filesEntity.AvailableCustomerData

    LoggerSessionNameWithMacrosPopup {
        id: loggerSessionNameWithMacrosPopup
    }
    Connections {
        target: loggerSessionNameWithMacrosPopup
        onSessionNameSelected: {
            sessionNameField.text = newSessionName
        }
    }

    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Add new session")
        font.pointSize: root.pointSize * 1.5
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.topMargin: rowHeight/3
        anchors.bottom: parent.bottom

        RowLayout {
            height: rowHeight
            Label {
                height: rowHeight
                text: Z.tr("Session name:")
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: sessionNameField
                height: rowHeight
                Layout.fillWidth: true
                function hasValidInput() {
                    return textField.text !== "" && !loggerEntity.ExistingSessions.includes(textField.text)
                }
            }
            Button {
                height: rowHeight
                text: "..."
                onClicked: {
                    loggerSessionNameWithMacrosPopup.open()
                }
            }
        }
        RowLayout {
            height: rowHeight
            Label {
                height: rowHeight
                Layout.fillWidth: true
                text: Z.tr("Select customer data:")
                font.pointSize: pointSize
            }
            Button {
                text: FA.fa_cogs
                font.family: FA.old
                font.pointSize: pointSize
                height: rowHeight
                onClicked: {
                    menuStackLayout.showCustomerDataBrowser()
                }
            }
        }

        ListView {
            id: customerDataList
            Layout.fillHeight: true
            width: parent.width
            model: {
                var arrayCustomers = [""]
                var vfCustData = availableCustomerDataFiles
                arrayCustomers.push(...vfCustData)
                return arrayCustomers
            }
            //highlightFollowsCurrentItem: true
            currentIndex: model.indexOf(customerData.FileSelected)
            clip: true
            readonly property bool vBarVisible: contentHeight > height
            ScrollBar.vertical: ScrollBar {
                id: vBar
                anchors.right: parent.right
                width: scrollWidth
                orientation: Qt.Vertical
                policy: customerDataList.vBarVisible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
            delegate: ItemDelegate {
                width: parent.width - (customerDataList.vBarVisible ? 8 : 0) //don't overlap with the ScrollIndicator
                highlighted: ListView.isCurrentItem
                onClicked: {
                    if(customerData.FileSelected !== modelData) {
                        customerData.FileSelected = modelData
                    }
                }
                RowLayout {
                    height: rowHeight
                    Label {
                        id: activeIndicator
                        width: 24
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        font.family: FA.old
                        font.pointSize: pointSize
                        text: FA.fa_check
                        opacity: (modelData === customerData.FileSelected)? 1.0 : 0.0
                    }
                    Label {
                        x: scrollWidth+GC.standardTextHorizMargin
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: pointSize
                        width: parent.width - /*buttonWidth -*/ 2*GC.standardTextHorizMargin
                        text: modelData !== "" ? modelData : Z.tr("-- no customer --")
                    }
                }
            }
        }

        RowLayout { // Cancel / OK buttons
            id: cancelOKRow
            Item {
                id: spacerItem
                Layout.fillWidth: true
            }
            Button {
                id: cancelButton
                text: Z.tr("Cancel")
                font.pointSize: root.pointSize
                onClicked: {
                    menuStackLayout.pleaseCloseMe(false)
                }
            }
            Button {
                id: okButton
                text: Z.tr("OK")
                enabled: sessionNameField.text !== "" && sessionNameField.hasValidInput()
                font.pointSize: root.pointSize
                Layout.minimumWidth: cancelButton.width
                onClicked: {
                    loggerEntity.sessionName = sessionNameField.text
                    menuStackLayout.pleaseCloseMe(true)
                }
            }
        }
    }
}
