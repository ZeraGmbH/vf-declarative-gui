pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0

/**
  * @b Lazy initialization of json metainformations that every measuring module should ship
  * These contain validation information of components (e.g. a list of valid ranges for RangeModule1.PAR_ChannelXRange)
  */
Item {
  property var rangeIntrospection: VeinEntity.hasEntity("RangeModule1") ? JSON.parse(VeinEntity.getEntity("RangeModule1").INF_ModuleInterface) : 0
  property var dftIntrospection: VeinEntity.hasEntity("DFTModule1") ? JSON.parse(VeinEntity.getEntity("DFTModule1").INF_ModuleInterface) : 0
  property var p1m1Introspection: VeinEntity.hasEntity("POWER1Module1") ? JSON.parse(VeinEntity.getEntity("POWER1Module1").INF_ModuleInterface) : 0
  property var p1m2Introspection: VeinEntity.hasEntity("POWER1Module2") ? JSON.parse(VeinEntity.getEntity("POWER1Module2").INF_ModuleInterface) : 0
  property var p1m3Introspection: VeinEntity.hasEntity("POWER1Module3") ? JSON.parse(VeinEntity.getEntity("POWER1Module3").INF_ModuleInterface) : 0
  property var p1m4Introspection: VeinEntity.hasEntity("POWER1Module4") ? JSON.parse(VeinEntity.getEntity("POWER1Module4").INF_ModuleInterface) : 0
  property var p2m1Introspection: VeinEntity.hasEntity("POWER2Module1") ? JSON.parse(VeinEntity.getEntity("POWER2Module1").INF_ModuleInterface) : 0
  property var p3m1Introspection: VeinEntity.hasEntity("Power3Module1") ? JSON.parse(VeinEntity.getEntity("Power3Module1").INF_ModuleInterface) : 0
  property var sec1m1Introspection: VeinEntity.hasEntity("SEC1Module1") ? JSON.parse(VeinEntity.getEntity("SEC1Module1").INF_ModuleInterface) : 0
  property var sec1m2Introspection: VeinEntity.hasEntity("SEC1Module2") ? JSON.parse(VeinEntity.getEntity("SEC1Module2").INF_ModuleInterface) : 0
  property var sem1Introspection: VeinEntity.hasEntity("SEM1Module1") ? JSON.parse(VeinEntity.getEntity("SEM1Module1").INF_ModuleInterface) : 0
  property var spm1Introspection: VeinEntity.hasEntity("SPM1Module1") ? JSON.parse(VeinEntity.getEntity("SPM1Module1").INF_ModuleInterface) : 0
  property var fftIntrospection: VeinEntity.hasEntity("FFTModule1") ? JSON.parse(VeinEntity.getEntity("FFTModule1").INF_ModuleInterface) : 0
  property var osciIntrospection: VeinEntity.hasEntity("OSCIModule1") ? JSON.parse(VeinEntity.getEntity("OSCIModule1").INF_ModuleInterface) : 0
  property var thdnIntrospection: VeinEntity.hasEntity("THDNModule1") ? JSON.parse(VeinEntity.getEntity("THDNModule1").INF_ModuleInterface) : 0
  property var rmsIntrospection: VeinEntity.hasEntity("RMSModule1") ? JSON.parse(VeinEntity.getEntity("RMSModule1").INF_ModuleInterface) : 0
  property var sampleIntrospection: VeinEntity.hasEntity("SampleModule1") ? JSON.parse(VeinEntity.getEntity("SampleModule1").INF_ModuleInterface) : 0
  property var burden1Introspection: VeinEntity.hasEntity("Burden1Module1") ? JSON.parse(VeinEntity.getEntity("Burden1Module1").INF_ModuleInterface) : 0
  property var burden2Introspection: VeinEntity.hasEntity("Burden1Module2") ? JSON.parse(VeinEntity.getEntity("Burden1Module2").INF_ModuleInterface) : 0
  property var transformer1Introspection: VeinEntity.hasEntity("Transformer1Module1") ? JSON.parse(VeinEntity.getEntity("Transformer1Module1").INF_ModuleInterface) : 0
  //property var customerdataIntrospection: VeinEntity.hasEntity("CustomerData") ? JSON.parse(VeinEntity.getEntity("CustomerData").INF_ModuleInterface) : 0
  property var introMap: ({});

  function reloadIntrospection() {
    rangeIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("RangeModule1") ? JSON.parse(VeinEntity.getEntity("RangeModule1").INF_ModuleInterface) : 0; })
    dftIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("DFTModule1") ? JSON.parse(VeinEntity.getEntity("DFTModule1").INF_ModuleInterface) : 0; })
    p1m1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("POWER1Module1") ? JSON.parse(VeinEntity.getEntity("POWER1Module1").INF_ModuleInterface) : 0; })
    p1m2Introspection = Qt.binding(function() { return VeinEntity.hasEntity("POWER1Module2") ? JSON.parse(VeinEntity.getEntity("POWER1Module2").INF_ModuleInterface) : 0; })
    p1m3Introspection = Qt.binding(function() { return VeinEntity.hasEntity("POWER1Module3") ? JSON.parse(VeinEntity.getEntity("POWER1Module3").INF_ModuleInterface) : 0; })
    p1m4Introspection = Qt.binding(function() { return VeinEntity.hasEntity("POWER1Module4") ? JSON.parse(VeinEntity.getEntity("POWER1Module4").INF_ModuleInterface) : 0; })
    p2m1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("POWER2Module1") ? JSON.parse(VeinEntity.getEntity("POWER2Module1").INF_ModuleInterface) : 0; })
    p3m1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("Power3Module1") ? JSON.parse(VeinEntity.getEntity("Power3Module1").INF_ModuleInterface) : 0; })
    sec1m1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("SEC1Module1") ? JSON.parse(VeinEntity.getEntity("SEC1Module1").INF_ModuleInterface) : 0; })
    sec1m2Introspection = Qt.binding(function() { return VeinEntity.hasEntity("SEC1Module2") ? JSON.parse(VeinEntity.getEntity("SEC1Module2").INF_ModuleInterface) : 0; })
    sem1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("SEM1Module1") ? JSON.parse(VeinEntity.getEntity("SEM1Module1").INF_ModuleInterface) : 0; })
    spm1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("SPM1Module1") ? JSON.parse(VeinEntity.getEntity("SPM1Module1").INF_ModuleInterface) : 0; })
    fftIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("FFTModule1") ? JSON.parse(VeinEntity.getEntity("FFTModule1").INF_ModuleInterface) : 0; })
    osciIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("OSCIModule1") ? JSON.parse(VeinEntity.getEntity("OSCIModule1").INF_ModuleInterface) : 0; })
    thdnIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("THDNModule1") ? JSON.parse(VeinEntity.getEntity("THDNModule1").INF_ModuleInterface) : 0; })
    rmsIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("RMSModule1") ? JSON.parse(VeinEntity.getEntity("RMSModule1").INF_ModuleInterface) : 0; })
    sampleIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("SampleModule1") ? JSON.parse(VeinEntity.getEntity("SampleModule1").INF_ModuleInterface) : 0; })
    burden1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("Burden1Module1") ? JSON.parse(VeinEntity.getEntity("Burden1Module1").INF_ModuleInterface) : 0; })
    burden2Introspection = Qt.binding(function() { return VeinEntity.hasEntity("Burden1Module2") ? JSON.parse(VeinEntity.getEntity("Burden1Module2").INF_ModuleInterface) : 0; })
    transformer1Introspection = Qt.binding(function() { return VeinEntity.hasEntity("Transformer1Module1") ? JSON.parse(VeinEntity.getEntity("Transformer1Module1").INF_ModuleInterface) : 0; })
//    customerdataIntrospection = Qt.binding(function() { return VeinEntity.hasEntity("CustomerData") ? JSON.parse(VeinEntity.getEntity("CustomerData").INF_ModuleInterface) : 0; })
    setMapping();
  }

  function setMapping() {
    var tmpMap = ({})

    var allEntities = VeinEntity.getEntity("_VEIN").Entities
    for(var i=0; i<allEntities.length; ++i)
    {
      var tmpEntity = VeinEntity.getEntityById(allEntities[i])
      if(tmpEntity && tmpEntity.hasComponent("INF_ModuleInterface"))
      {
        tmpMap[tmpEntity.EntityName] = JSON.parse(tmpEntity.INF_ModuleInterface);
      }
    }

    introMap = tmpMap;
  }

  function hasDependentEntities(t_list) {
    var retVal = false;
    if(t_list !== undefined)
    {
      if(t_list.length > 0)
      {
        var tmpEntityName;
        for(var tmpIndex in t_list)
        {
          tmpEntityName = t_list[tmpIndex];
          retVal = VeinEntity.hasEntity(tmpEntityName);

          if(retVal === false)
          {
            //exit loop
            break;
          }
        }
      }
      else
      {
        retVal = true;
      }
    }

    return retVal;
  }
}
