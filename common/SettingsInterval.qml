import QtQuick 2.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import Com5003Translation  1.0

Column {
  id: root
  property int rowHeight
  property int rowWidth

  property var periodList;
  property var timeList;

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
    VF.VFSpinBox {
      intermediateValue: timeList[0].PAR_Interval
      onOutValueChanged: {
        for(var i=0; i<timeList.length; ++i)
        {
          if(timeList[i].PAR_Interval !== outValue)
          {
            timeList[i].PAR_Interval = outValue;
          }
        }
      }
      CCMP.IntervalIntrospection {
        property var timeIntrospection: ModuleIntrospection.introMap[timeList[0].EntityName];
        unit: "seconds";
        upperBound: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[1];
        lowerBound: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[0];
        stepSize: timeIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2];
        Component.onCompleted: parent.introspection = this
      }

      text: ZTR["Integration time interval:"]
      height: root.rowHeight
      width: root.rowWidth
    }
  }
  Component {
    id: periodComponent
    VF.VFSpinBox {
      intermediateValue: periodList[0].PAR_Interval
      onOutValueChanged: {
        for(var i=0; i<periodList.length; ++i)
        {
          if(periodList[i].PAR_Interval !== outValue)
          {
            periodList[i].PAR_Interval = outValue;
          }
        }
      }
      CCMP.IntervalIntrospection {
        property var periodIntrospection: ModuleIntrospection.introMap[periodList[0].EntityName];
        unit: "periods";
        upperBound: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[1];
        lowerBound: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[0];
        stepSize: periodIntrospection.ComponentInfo.PAR_Interval.Validation.Data[2];
        Component.onCompleted: parent.introspection = this
      }

      text: ZTR["Integration period interval:"]
      height: root.rowHeight
      width: root.rowWidth
    }
  }
}
