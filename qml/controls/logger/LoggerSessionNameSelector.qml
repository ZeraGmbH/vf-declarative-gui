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
    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")

    LoggerSessionNameDefaultPopup {
        id: loggerSessionNameDefaultPopup
    }
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            preview.text = GC.loggerSessionNameReplace(GC.loggerSessionNameDefault)
        }
    }

    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Select session name")
        font.pointSize: root.pointSize * 1.5
    }
    ColumnLayout {
        id: selectionColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.bottom: parent.bottom
        RowLayout { // Default session
            width: selectionColumn.width
            height: root.rowHeight
            Label {
                id: defNameLabel
                text: Z.tr("Set default name:")
                font.pointSize: root.pointSize
            }
            Item {
                // spacer
                Layout.fillWidth: true
            }
            Label { // For sake of seconds text is set by timer
                id: preview
                font.pointSize: root.pointSize
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                Layout.maximumWidth: selectionColumn.width - // Ugly: suggestions welcome...
                                     selectionColumn.anchors.leftMargin - selectionColumn.anchors.rightMargin -
                                     defNameLabel.width - defSettingsButton.width - makeDefaultCurrentButton.width
            }
            Button {
                id: defSettingsButton
                text: FA.fa_cogs
                Layout.preferredWidth: height
                font.family: FA.old
                font.pointSize: root.pointSize
                focusPolicy: Qt.NoFocus
                onPressed: {
                    loggerSessionNameDefaultPopup.open()
                }
            }
            Button {
                id: makeDefaultCurrentButton
                text: enabled ? FA.colorize(FA.fa_check, "lawngreen") : FA.colorize(FA.fa_check, "grey")
                Layout.preferredWidth: height
                font.family: FA.old
                font.pointSize: root.pointSize
                focusPolicy: Qt.NoFocus
                //enabled: preview.text !== currentSessionName.textField.text
                onPressed: {
                    loggerEntity.sessionName = preview.text
                }
            }
        }
        Item {
            // vert. spacer
            width: selectionColumn.width
            height: root.rowHeight / 2
        }
        Label {
            text: Z.tr("Select existing:");
            font.pointSize: root.pointSize
            visible: existingList.visible
        }
        RowLayout {
            width: selectionColumn.width
            Layout.fillHeight: true
            ListView {
                id: existingList
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentIndex: model ? model.indexOf(loggerEntity.sessionName) : -1
                clip: true
                property bool vBarVisible: existingList.contentHeight > existingList.height
                visible: model.length !== 0
                ScrollBar.vertical: ScrollBar {
                    id: vBar
                    anchors.right: parent.right
                    width: 16
                    orientation: Qt.Vertical
                    policy: existingList.vBarVisible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }
                model: loggerEntity.ExistingSessions.sort()

                delegate: ItemDelegate {
                    anchors.left: parent.left
                    width: parent.width - (existingList.vBarVisible ? vBar.width : 0)
                    height: root.rowHeight
                    highlighted: ListView.isCurrentItem
                    RowLayout {
                        anchors.fill: parent
                        Label {
                            id: activeIndicator
                            font.family: FA.old
                            font.pointSize: root.pointSize
                            horizontalAlignment: Text.AlignLeft
                            text: FA.fa_check
                            opacity: (modelData === loggerEntity.sessionName) ? 1.0 : 0.0
                            Layout.preferredWidth: root.pointSize * 1.5
                        }
                        Label {
                            font.pointSize: root.pointSize
                            horizontalAlignment: Text.AlignLeft
                            text: modelData
                            Layout.fillWidth: true
                        }
                    }
                    onClicked: {
                        if(loggerEntity.sessionName !== modelData) {
                            loggerEntity.sessionName = modelData
                        }
                    }
                }
            }
        }
        Button {
            text: "+"
            onClicked: {
                menuStackLayout.showSessionNew()
            }
        }
    }
}
