import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import FontAwesomeQml 1.0
import AppStarterForWebGLSingleton 1.0
import SessionState 1.0
import ZeraFa 1.0
import Vf_Recorder 1.0
import "../controls/error_comparison_common"
import "../controls/error_comparison_params"

Item {
    id: root
    clip: true

    property QtObject errCalEntity
    property var moduleIntrospection
    property int status: errCalEntity.ACT_Status
    property string actualValue
    readonly property alias statusHolder: stateEnum
    readonly property bool canStartMeasurement: errCalEntity.PAR_StartStop !== 1
    readonly property real pointSize: height > 0 ? height * 0.03 : 10
    readonly property bool rangeAutoActive: VeinEntity.getEntity("RangeModule1").PAR_RangeAutomatic

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
                width: parent.width*0.85
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
                    parStartStop: root.errCalEntity.PAR_StartStop
                    visible: !ASWGL.isServer
                }
            }

            ErrorMarginView {
                result: root.errCalEntity.ACT_Result
                width: parent.width*0.15
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
                width: root.width * 0.1425

                enabled: root.canStartMeasurement
                highlighted: true

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                onClicked: {
                    if(rangeAutoActive === true)
                        warningPopup.open()
                    if(errCalEntity.PAR_StartStop !== 1) {
                        errCalEntity.PAR_StartStop=1;
                    }
                    if(SessionState.emobSession && !ASWGL.isServer)
                        multiSwipe.currentIndex = 1
                }
            }

            Popup {
                 id: warningPopup
                 bottomMargin: root.height * 0.5
                 leftMargin: root.width * 0.3
                 parent: root.overlay
                 anchors.centerIn: parent
                 modal: true
                 focus: true
                 width: root.width / 2
                 height: root.height / 2
                 closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                 ColumnLayout {
                    id: warningPopupContent
                    width: parent.width
                    height: parent.height
                    Label {
                        Layout.fillWidth: true
                        text: Z.tr("Warning:")
                        font.pointSize: pointSize * 1.3
                        horizontalAlignment: Text.AlignHCenter
                        }
                    Label {
                        Layout.fillWidth: true
                        text: Z.tr("Switch off 'Range automatic'")
                        font.pointSize: pointSize
                         horizontalAlignment: Text.AlignHCenter
                         wrapMode: Text.Wrap
                    }
                    Label {
                        Layout.fillWidth: true
                        text: Z.tr("Select a matching range")
                        font.pointSize: pointSize
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
                    Button {
                        text: Z.tr("Close")
                        font.pointSize: pointSize
                        Layout.alignment: Qt.AlignHCenter
                        highlighted: true
                        onClicked: warningPopup.close()
                    }
                }
            }

            Button {
                id: stopButton
                text: Z.tr("Stop")
                font.pointSize: pointSize
                width: root.width * 0.1425

                enabled: root.canStartMeasurement === false

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: GC.standardTextHorizMargin

                onClicked: {
                    if(errCalEntity.PAR_StartStop !== 0) {
                        errCalEntity.PAR_StartStop=0;
                    }
                }
            }
            Loader {
                active: !ASWGL.isServer
                height: active ? root.rowHeight : 0
                width: root.width * 0.35
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                sourceComponent: Button {
                    id: graphicsWindow
                    text: FAQ.fa_chevron_up
                    font.pointSize: pointSize
                    visible: SessionState.emobSession
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
}
