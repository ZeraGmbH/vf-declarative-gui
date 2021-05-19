import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraFa 1.0

Item {
    id: root
    // holds the state data
    property QtObject logicalParent;
    property real measurementResult;
    property alias progress: actProgressBar.value
    property alias progressTo: actProgressBar.to
    property string progressText: parseInt(progress / progressTo * 100)+"%"
    property string actualValue;

    Column {
        anchors.fill: parent
        Item {
            height: root.height*0.8
            width: root.width
            Item {
                height: parent.height
                width: 3*root.width/7
                anchors.left: parent.left
                readonly property int statusNotify: logicalParent.status;
                Label {
                    width: parent.width
                    textFormat: Text.PlainText
                    font.pixelSize: 40
                    fontSizeMode: Text.HorizontalFit
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    text: actualValue
                }
            }
            Item {
                visible: logicalParent.status & logicalParent.statusHolder.armed
                anchors.centerIn: parent
                height: parent.height*0.8
                width: root.width/7
                clip: true
                Image {
                    source: "qrc:/data/staticdata/resources/Armed.svg"
                    sourceSize.width: parent.width
                    fillMode: Image.TileHorizontally
                    height: parent.height
                    width: parent.width
                }
            }
            Item {
                id: animatedReady
                visible: logicalParent.status & logicalParent.statusHolder.started
                anchors.centerIn: parent
                height: parent.height*0.8
                width: root.width/7
                clip: true
                Image {
                    source: "qrc:/data/staticdata/resources/Ready.svg"
                    sourceSize.width: parent.width
                    fillMode: Image.TileHorizontally
                    height: parent.height
                    width: parent.width*2

                    SequentialAnimation on x {
                        running: logicalParent.status & logicalParent.statusHolder.started
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0
                            to: -animatedReady.width
                            duration: 1000
                        }
                        NumberAnimation {
                            to: 0
                            duration: 0
                        }
                    }
                }
            }
            Item {
                id: waitAnimantion
                visible: logicalParent.status & logicalParent.statusHolder.wait
                anchors.centerIn: parent
                height: parent.height * 0.5 *(1+animationValue)
                width: root.width * 0.1
                property real animationValue
                property real pointSizeBase: height > 0 ? height * 0.5 : 5
                Label {
                    id: z1
                    text: "Z"
                    font.pointSize: waitAnimantion.pointSizeBase
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignBottom
                }
                Label {
                    id: z2
                    text: "Z"
                    font.pointSize: waitAnimantion.pointSizeBase * 0.8
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    x: parent.width * (0.48 - waitAnimantion.animationValue*0.08)
                    y: parent.height * (0.12 - waitAnimantion.animationValue*0.05)
                }
                Label {
                    id: z3
                    text: "Z"
                    font.pointSize: waitAnimantion.pointSizeBase * 0.6
                    anchors.right: parent.right
                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignBottom
                    anchors.top: parent.top
                }
                SequentialAnimation on animationValue {
                    running: waitAnimantion.visible
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0
                        to: 0.5
                        duration: 600
                    }
                    NumberAnimation {
                        duration: 700
                    }
                    NumberAnimation {
                        from: 0.5
                        to: 0
                        duration: 1500
                    }
                    NumberAnimation {
                        duration: 100
                    }
                }
            }
            Item {
                height: parent.height
                width: 3*root.width/7
                anchors.right: parent.right
                readonly property int statusNotify: logicalParent.status;
                visible: false;
                onStatusNotifyChanged: {
                    if(statusNotify & logicalParent.statusHolder.ready) {
                        visible = true;
                    }
                    else if(statusNotify & logicalParent.statusHolder.started) {
                        visible = false;
                    }
                }
                Label {
                    id: resultLabel
                    width: parent.width
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: 40
                    fontSizeMode: Text.HorizontalFit
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    text: FT.formatNumber(measurementResult)+"%"
                }
            }
        }
        Item { //spacer
            height: 8
            width: parent.width
        }
        ProgressBar {
            id: actProgressBar
            from: 0
            width: parent.width
            height: parent.height/20
            indeterminate: logicalParent.status & logicalParent.statusHolder.armed
            Label {
                visible: logicalParent.status !== logicalParent.statusHolder.ready
                textFormat: Text.PlainText
                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                text: root.progressText
            }
        }
    }
}
