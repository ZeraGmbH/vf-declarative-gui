import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ZeraTranslation  1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FontAwesomeQml 1.0
import AuthorizationRequestHandler 1.0

Popup {
    id: trustListPopup

    TrustDeletePopup {
        id: trustDeletePopup
    }

    property var trusts: GC.entityInitializationDone ? VeinEntity.getEntity("ApiModule").ACT_TrustList : []

    anchors.centerIn: parent
    width: parent.width * 0.85
    height: parent.height * 0.85
    modal: true
    readonly property real pointSize: displayWindow.pointSize

    ColumnLayout {
        id: trustListPopupContent
        width: parent.width
        height: parent.height

        Label {
            Layout.fillWidth: true

            text: Z.tr("Trusted API Clients")
            font.pointSize: pointSize * 1.25
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            color: "transparent"

            ListView {
                id: apiTrustEntries
                width: parent.width
                height: parent.height

                model: trusts.sort((l,r) => l.name.localeCompare(r.name, undefined, { sensitivity: "accent" }))
                delegate:
                    Component {
                        RowLayout {
                            visible: apiTrustEntries.count > 0
                            Button {
                                text: FAQ.fa_trash
                                font.pointSize: pointSize * 1.4
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: trustDeletePopup.confirm(modelData)
                            }

                            Text {
                                font.pointSize: pointSize
                                text: modelData.name
                                color: "white"
                            }
                        }
                    }
            }
            Text {
                anchors.fill: parent
                text: Z.tr("No trusted clients yet.")
                font.pointSize: pointSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: apiTrustEntries.count === 0
                color: "white"
            }
        }

        Button {
            text: Z.tr("Cancel")
            font.pointSize: pointSize
            Layout.alignment: Qt.AlignRight
            highlighted: true
            onClicked: close()
        }
    }
}

