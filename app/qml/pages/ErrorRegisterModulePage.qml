import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import FontAwesomeQml 1.0
import SessionState 1.0
import ZeraFa 1.0
import "../controls/error_comparison_common"
import "../controls/error_comparison_params"

Item {
    id: root
    clip: true

    property QtObject errCalEntity
    property var storageEntity: VeinEntity.getEntity("Storage")
    property var moduleIntrospection
    property int status: errCalEntity.ACT_Status
    property string actualValue
    readonly property alias statusHolder: stateEnum
    readonly property bool canStartMeasurement: errCalEntity.PAR_StartStop !== 1
    readonly property real pointSize: height > 0 ? height * 0.03 : 10
    readonly property var jsonEnergyDC: { "foo":[{ "EntityId":1040, "Component":["ACT_RMSPN1", "ACT_RMSPN2"]},
                                                 { "EntityId":1073, "Component":["ACT_PQS1"]} ]} //"ACT_DC7" / "ACT_DC8"
    readonly property var jsonEnergyAC: { "foo":[{ "EntityId":1040, "Component":[ "ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"]},
                                                 { "EntityId":1071, "Component":["ACT_PQS1", "ACT_PQS2", "ACT_PQS3"]} ]} // , "ACT_RMSPN3", "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6"

    property int parStartStop: errCalEntity.PAR_StartStop
    onParStartStopChanged: {
        if(SessionState.emobSession) {
            if(parStartStop === 1) {
                if(SessionState.dcSession) {
                    var data = jsonEnergyDC
                    storageEntity.PAR_JsonWithEntities0 = JSON.stringify(data)
                }
                else {
                    data = jsonEnergyAC
                    storageEntity.PAR_JsonWithEntities0 = JSON.stringify(data)
                }
                storageEntity.PAR_StartStopLogging0 = true
            }
            else if(parStartStop === 0) {
                storageEntity.PAR_StartStopLogging0 = false
            }
        }
    }

    function extractComponents(data) {
        if(data.length !== 0 ) {
            data = JSON.parse(data)
            data = data.foo
            var compoList = []
            for(var i = 0; i < data.length; i++) {
                compoList.push(data[i].Component)
            }
            var flatCompoList = [].concat.apply([], compoList);
            return flatCompoList
        }
        return []
    }

    QtObject {
        id: stateEnum
        //some of these state bits can be active in parallel

        ///doing nothing waiting to start the measurement
        readonly property int idle: 0
        ///waiting for first pulse
        readonly property int armed: 1
        ///running
        readonly property int started: 2
        ///result is available
        readonly property int ready: 4
        ///measurement was aborted
        readonly property int aborted: 8
    }

    Column {
        MeasurementView {
            measurementResult: errCalEntity.ACT_Result
            progress: errCalEntity.PAR_Targeted ? errCalEntity.ACT_Time : 0
            progressTo: errCalEntity.PAR_Targeted ? errCalEntity.PAR_MeasTime : 1.0
            actualValue: root.actualValue
            logicalParent: root
            height: root.height*0.2
            width: root.width
        }
        Row {
            height: root.height*0.7
            width: root.width

            SwipeView {
                id: multiSwipe
                width: parent.width*0.8
                height: parent.height
                interactive: false
                orientation: Qt.Vertical
                clip: true
                ParamViewRegister {
                    logicalParent: root
                    validatorRefInput: moduleIntrospection.ComponentInfo.PAR_RefInput.Validation
                    validatorMeasTime: moduleIntrospection.ComponentInfo.PAR_MeasTime.Validation
                    validatorT0Input: moduleIntrospection.ComponentInfo.PAR_T0Input.Validation
                    validatorT1Input: moduleIntrospection.ComponentInfo.PAR_T1input.Validation
                    validatorTxUnit: moduleIntrospection.ComponentInfo.PAR_TXUNIT.Validation
                    validatorUpperLimit: moduleIntrospection.ComponentInfo.PAR_Uplimit.Validation
                    validatorLowerLimit: moduleIntrospection.ComponentInfo.PAR_Lolimit.Validation
                }
                EnergyGraphs {
                    id: energyChart
                    graphHeight: parent.height
                    graphWidth: parent.width
                    property var jsonIn: VeinEntity.getEntity("Storage").PAR_JsonWithEntities0
                    onJsonInChanged: {
                        var compoList = extractComponents(jsonIn)
                        energyChart.componentsList = compoList
                    }
                }
            }

            ErrorMarginView {
                result: root.errCalEntity.ACT_Result
                width: parent.width*0.2
                height: parent.height
                maxValue: errCalEntity.PAR_Uplimit
                minValue: errCalEntity.PAR_Lolimit
                rating: errCalEntity.ACT_Rating
                measNum: 0
                finished: errCalEntity.PAR_StartStop !== 1 && (errCalEntity.ACT_Status & stateEnum.aborted) === 0
            }
        }
        Item {
            height: root.height*0.1
            width: root.width
            Button {
                id: startButton
                text: Z.tr("Start")
                font.pointSize: pointSize
                width: root.width/5

                enabled: root.canStartMeasurement
                highlighted: true

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                onClicked: {
                    if(errCalEntity.PAR_StartStop !== 1) {
                        errCalEntity.PAR_StartStop=1;
                    }
                    if(SessionState.emobSession)
                        multiSwipe.currentIndex = 1
                }
            }

            Button {
                id: stopButton
                text: Z.tr("Stop")
                font.pointSize: pointSize
                width: root.width/5

                enabled: root.canStartMeasurement === false

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                onClicked: {
                    if(errCalEntity.PAR_StartStop !== 0) {
                        errCalEntity.PAR_StartStop=0;
                    }
                }
            }
            Button {
                id: graphicsWindow
                text: FAQ.fa_chevron_up
                font.pointSize: pointSize
                visible: SessionState.emobSession
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: stopButton.left
                anchors.left: startButton.right
                anchors.rightMargin: parent.width / 8
                anchors.leftMargin: parent.width / 8
                highlighted: multiSwipe.currentIndex !== 0
                onClicked: {
                    multiSwipe.currentIndex = !multiSwipe.currentIndex
                    if(graphicsWindow.text === FAQ.fa_chevron_up)
                        graphicsWindow.text = FAQ.fa_chevron_down
                    else
                        graphicsWindow.text = FAQ.fa_chevron_up
                }
            }
        }
    }
}
