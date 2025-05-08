import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ZeraTranslation  1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FontAwesomeQml 1.0

Popup {
    id: trustListPopup

    property var trusts: GC.entityInitializationDone ? VeinEntity.getEntity("ApiModule").ACT_TrustList : []

    anchors.centerIn: parent
    width: parent.width * 0.85
    height: parent.height * 0.85
    modal: true

    TrustDeletePopup {
        id: trustDeletePopup
    }

    ColumnLayout {
        id: trustListPopupContent
        width: parent.width
        height: parent.height

        Label {
            Layout.fillWidth: true

            text: Z.tr("Trusted API Clients")
            font.pointSize: pointSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            color: "transparent"

            ListView {
                width: parent.width
                height: parent.height

                model: trusts.sort((l,r) => l.name.localeCompare(r.name, undefined, { sensitivity: "accent" }))

                delegate:
                    Component {
                        RowLayout {
                            Button {
                                text: FAQ.fa_trash
                                font.pointSize: pointSize * 1.2
                                background: Rectangle {
                                    color: "transparent"
                                }
                                onClicked: trustDeletePopup.confirm(modelData)
                            }

                            Text {
                                font.pointSize: pointSize * 0.9
                                text: modelData.name
                                color: "white"
                            }
                        }
                    }
            }
        }

        Button {
            text: Z.tr("Cancel")
            font.pointSize: pointSize
            anchors {right: trustListPopupContent.right }
            highlighted: true
            onClicked: close()
        }
    }
}

