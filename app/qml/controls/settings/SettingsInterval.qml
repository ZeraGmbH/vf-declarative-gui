import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.2
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

Item {
    id: root
    property real pointSize
    property real rowHeight

    property var periodList;
    property var timeList;

    property var periodIntrospection: ModuleIntrospection.introMap[(periodList.length ? periodList[0].EntityName : "")];
    property var timeIntrospection: ModuleIntrospection.introMap[(timeList.length ? timeList[0].EntityName : "")];

    property bool hasPeriodEntries: false
    height: hasPeriodEntries ? 2*rowHeight : rowHeight

    Component.onCompleted: {
        var allEntities = VeinEntity.getEntity("_System").Entities
        var tmpTimeList = [];
        var tmpPeriodList = [];
        for(var i=0; i<allEntities.length; ++i) {
            var tmpEntity = VeinEntity.getEntityById(allEntities[i])
            if(tmpEntity && tmpEntity.hasComponent("PAR_Interval")) {
                if(ModuleIntrospection.introMap[tmpEntity.EntityName].ComponentInfo.PAR_Interval.Unit === "s") {
                    tmpTimeList.push(tmpEntity);
                }
                else if(ModuleIntrospection.introMap[tmpEntity.EntityName].ComponentInfo.PAR_Interval.Unit === "period") {
                    hasPeriodEntries = true;
                    tmpPeriodList.push(tmpEntity);
                }
                else {
                    console.warn("SettingsInterval.onCompleted(): ERROR IN METADATA")
                }
            }
        }
        timeList = tmpTimeList;
        periodList = tmpPeriodList;
    }

    Loader {
        id: loaderTime
        anchors.top: parent.top
        width: parent.width
        height: parent.rowHeight
        sourceComponent: timeComponent
        active: timeList.length > 0;
        asynchronous: true
    }

    Loader {
        anchors.top: loaderTime.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.rowHeight
        sourceComponent: periodComponent
        active: periodList.length > 0;
        asynchronous: true
    }

    Component {
        id: timeComponent
        RowLayout {
            anchors.fill: parent
            Label {
                text: Z.tr("Integration time interval") + " [s]:"
                font.pointSize: root.pointSize
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Item {
                Layout.fillWidth: true
            }
            VFSpinBox {
                spinBox.width: root.width / 4
                pointSize: root.pointSize
                Layout.fillHeight: true
                entity: timeList[0]
                controlPropertyName: "PAR_Interval"
                stepSize: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2] * Math.pow(10, validatorTime.decimals)
                validator: ZDoubleValidator{
                    id: validatorTime
                    bottom: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[0];
                    top: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[1];
                    decimals: FT.ceilLog10Of1DividedByX(timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2]);
                }
                // we have to override doApplyInput because integration time displays
                // first entity's value but hast to change all in our list
                function doApplyInput(newText) {
                    var newVal = parseFloat(newText)
                    for(var i=0; i<timeList.length; ++i) {
                        if(timeList[i].PAR_Interval !== newVal) {
                            timeList[i].PAR_Interval = newVal;
                        }
                    }
                    // wait to be applied
                    return false
                }
            }
        }
    }
    Component {
        id: periodComponent
        RowLayout {
            anchors.fill: parent
            Label {
                text: Z.tr("Integration period interval:")
                font.pointSize: root.pointSize
                Layout.fillHeight: true
                verticalAlignment: Label.AlignVCenter
            }
            Item {
                Layout.fillWidth: true
            }
            VFSpinBox {
                spinBox.width: root.width / 4
                Layout.fillHeight: true
                pointSize: root.pointSize
                entity: periodList[0]
                controlPropertyName: "PAR_Interval"
                stepSize: 5
                validator: ZDoubleValidator{
                    id: validatorPeriod
                    bottom: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[0];
                    top: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[1];
                    decimals: FT.ceilLog10Of1DividedByX(periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2]);
                }
                // we have to override doApplyInput because integration period displays
                // first entity's value but hast to change all in our list
                function doApplyInput(newText) {
                    var newVal = parseFloat(newText)
                    for(var i=0; i<periodList.length; ++i) {
                        if(periodList[i].PAR_Interval !== newVal) {
                            periodList[i].PAR_Interval = newVal;
                        }
                    }
                    // wait to be applied
                    return false
                }
            }
        }
    }
}
