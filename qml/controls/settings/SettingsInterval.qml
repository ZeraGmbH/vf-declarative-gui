import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.2
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls

Column {
  id: root
  property int rowHeight
  property int rowWidth

  property var periodList;
  property var timeList;

  property var periodIntrospection: ModuleIntrospection.introMap[periodList[0].EntityName];
  property var timeIntrospection: ModuleIntrospection.introMap[timeList[0].EntityName];

  property bool hasPeriodEntries: false

  height: rowHeight
  width: rowWidth

  Component.onCompleted: {
    var allEntities = VeinEntity.getEntity("_System").Entities
    var tmpTimeList = [];
    var tmpPeriodList = [];
    for(var i=0; i<allEntities.length; ++i)
    {
      var tmpEntity = VeinEntity.getEntityById(allEntities[i])
      if(tmpEntity && tmpEntity.hasComponent("PAR_Interval"))
      {
        if(ModuleIntrospection.introMap[tmpEntity.EntityName].ComponentInfo.PAR_Interval.Unit === "sec")
        {
          tmpTimeList.push(tmpEntity);
        }
        else if(ModuleIntrospection.introMap[tmpEntity.EntityName].ComponentInfo.PAR_Interval.Unit === "period")
        {
          hasPeriodEntries = true;
          tmpPeriodList.push(tmpEntity);
        }
        else
        {
          console.warn("SettingsInterval.onCompleted(): ERROR IN METADATA")
        }
      }
    }
    timeList = tmpTimeList;
    periodList = tmpPeriodList;
  }

  Loader {
    sourceComponent: timeComponent
    active: timeList.length > 0;
    asynchronous: true
  }

  Loader {
    sourceComponent: periodComponent
    active: periodList.length > 0;
    asynchronous: true
  }

  Component {
    id: timeComponent
    Item {
      height: root.rowHeight
      width: root.rowWidth
      RowLayout {
        anchors.fill: parent
        Label {
          font.pixelSize: Math.max(height/2, 20)
          text: ZTR["Integration time interval:"]
        }
        Item {
          Layout.fillWidth: true
        }
        VFControls.VFSpinBox {
          height: root.rowHeight
          entity: timeList[0]
          controlPropertyName: "PAR_Interval"
          validator: CCMP.ZDoubleValidator{
            bottom: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[0];
            top: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[1];
            decimals: GC.ceilLog10Of1DividedByX(timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2]);
          }
          // we have to override doApplyInput because integration time displays
          // first entity's value but hast to change all in our list
          function doApplyInput(newText) {
            var newVal = parseFloat(newText)
            for(var i=0; i<timeList.length; ++i)
            {
              if(timeList[i].PAR_Interval !== newVal)
              {
                timeList[i].PAR_Interval = newVal;
              }
            }
            // wait to be applied
            return false
          }
        }
        Label {
          font.pixelSize: Math.max(height/2, 20)
          text: ZTR["seconds"];
        }
      }
    }
  }
  Component {
    id: periodComponent
    Item {
      height: root.rowHeight
      width: root.rowWidth
      RowLayout {
        anchors.fill: parent
        Label {
          font.pixelSize: Math.max(height/2, 20)
          text: ZTR["Integration period interval:"]
        }
        Item {
          Layout.fillWidth: true
        }
        VFControls.VFSpinBox {
          height: root.rowHeight
          entity: periodList[0]
          controlPropertyName: "PAR_Interval"
          validator: CCMP.ZDoubleValidator{
            bottom: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[0];
            top: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[1];
            decimals: GC.ceilLog10Of1DividedByX(periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2]);
          }
          // we have to override doApplyInput because integration period displays
          // first entity's value but hast to change all in our list
          function doApplyInput(newText) {
            var newVal = parseFloat(newText)
            for(var i=0; i<periodList.length; ++i)
            {
              if(periodList[i].PAR_Interval !== newVal)
              {
                periodList[i].PAR_Interval = newVal;
              }
            }
            // wait to be applied
            return false
          }
        }
        Label {
          font.pixelSize: Math.max(height/2, 20)
          text: ZTR["periods"];
        }
      }
    }
  }
}
