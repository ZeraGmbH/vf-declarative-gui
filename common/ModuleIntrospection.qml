pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0

Item {
  property var rangeIntrospection: VeinEntity.hasEntity("RangeModule1") ? JSON.parse(VeinEntity.getEntity("RangeModule1").INF_ModuleInterface) : 0
  property var dftIntrospection: VeinEntity.hasEntity("DFTModule1") ? JSON.parse(VeinEntity.getEntity("DFTModule1").INF_ModuleInterface) : 0
  property var p1m1Introspection: VeinEntity.hasEntity("POWER1Module1") ? JSON.parse(VeinEntity.getEntity("POWER1Module1").INF_ModuleInterface) : 0
  property var p1m2Introspection: VeinEntity.hasEntity("POWER1Module2") ? JSON.parse(VeinEntity.getEntity("POWER1Module2").INF_ModuleInterface) : 0
  property var p1m3Introspection: VeinEntity.hasEntity("POWER1Module3") ? JSON.parse(VeinEntity.getEntity("POWER1Module3").INF_ModuleInterface) : 0
  property var p2m1Introspection: VeinEntity.hasEntity("POWER2Module1") ? JSON.parse(VeinEntity.getEntity("POWER2Module1").INF_ModuleInterface) : 0
  property var secIntrospection: VeinEntity.hasEntity("SEC1Module1") ? JSON.parse(VeinEntity.getEntity("SEC1Module1").INF_ModuleInterface) : 0
  property var fftIntrospection: VeinEntity.hasEntity("FFTModule1") ? JSON.parse(VeinEntity.getEntity("FFTModule1").INF_ModuleInterface) : 0
  property var thdnIntrospection: VeinEntity.hasEntity("THDNModule1") ? JSON.parse(VeinEntity.getEntity("THDNModule1").INF_ModuleInterface) : 0
  property var rmsIntrospection: VeinEntity.hasEntity("RMSModule1") ? JSON.parse(VeinEntity.getEntity("RMSModule1").INF_ModuleInterface) : 0
  property var sampleIntrospection: VeinEntity.hasEntity("SampleModule1") ? JSON.parse(VeinEntity.getEntity("SampleModule1").INF_ModuleInterface) : 0
  property var burden1Introspection: VeinEntity.hasEntity("Burden1Module1") ? JSON.parse(VeinEntity.getEntity("Burden1Module1").INF_ModuleInterface) : 0
  property var burden2Introspection: VeinEntity.hasEntity("Burden1Module2") ? JSON.parse(VeinEntity.getEntity("Burden1Module2").INF_ModuleInterface) : 0
  property var transformer1Introspection: VeinEntity.hasEntity("Transformer1Module1") ? JSON.parse(VeinEntity.getEntity("Transformer1Module1").INF_ModuleInterface) : 0

  function reloadIntrospection() {
    rangeIntrospection = VeinEntity.hasEntity("RangeModule1") ? JSON.parse(VeinEntity.getEntity("RangeModule1").INF_ModuleInterface) : 0
    dftIntrospection = VeinEntity.hasEntity("DFTModule1") ? JSON.parse(VeinEntity.getEntity("DFTModule1").INF_ModuleInterface) : 0
    p1m1Introspection = VeinEntity.hasEntity("POWER1Module1") ? JSON.parse(VeinEntity.getEntity("POWER1Module1").INF_ModuleInterface) : 0
    p1m2Introspection = VeinEntity.hasEntity("POWER1Module2") ? JSON.parse(VeinEntity.getEntity("POWER1Module2").INF_ModuleInterface) : 0
    p1m3Introspection = VeinEntity.hasEntity("POWER1Module3") ? JSON.parse(VeinEntity.getEntity("POWER1Module3").INF_ModuleInterface) : 0
    p2m1Introspection = VeinEntity.hasEntity("POWER2Module1") ? JSON.parse(VeinEntity.getEntity("POWER2Module1").INF_ModuleInterface) : 0
    secIntrospection = VeinEntity.hasEntity("SEC1Module1") ? JSON.parse(VeinEntity.getEntity("SEC1Module1").INF_ModuleInterface) : 0
    fftIntrospection = VeinEntity.hasEntity("FFTModule1") ? JSON.parse(VeinEntity.getEntity("FFTModule1").INF_ModuleInterface) : 0
    thdnIntrospection = VeinEntity.hasEntity("THDNModule1") ? JSON.parse(VeinEntity.getEntity("THDNModule1").INF_ModuleInterface) : 0
    rmsIntrospection = VeinEntity.hasEntity("RMSModule1") ? JSON.parse(VeinEntity.getEntity("RMSModule1").INF_ModuleInterface) : 0
    sampleIntrospection = VeinEntity.hasEntity("SampleModule1") ? JSON.parse(VeinEntity.getEntity("SampleModule1").INF_ModuleInterface) : 0
    burden1Introspection = VeinEntity.hasEntity("Burden1Module1") ? JSON.parse(VeinEntity.getEntity("Burden1Module1").INF_ModuleInterface) : 0
    burden2Introspection = VeinEntity.hasEntity("Burden1Module2") ? JSON.parse(VeinEntity.getEntity("Burden1Module2").INF_ModuleInterface) : 0
    transformer1Introspection = VeinEntity.hasEntity("Transformer1Module1") ? JSON.parse(VeinEntity.getEntity("Transformer1Module1").INF_ModuleInterface) : 0
    setMapping();
  }

  property var introMap: ({});

  function setMapping() {
    var tmpMap = ({})

    var allEntities = VeinEntity.getEntity("_System").Entities
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
}
