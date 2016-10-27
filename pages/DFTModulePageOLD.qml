import QtQuick 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import "qrc:/ccmp/common" as CCMP
import GlobalConfig 1.0

import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root

  readonly property QtObject dft: VeinEntity.getEntity("DFTModule1")
  readonly property QtObject rangeInfo: VeinEntity.getEntity("RangeModule1")

  readonly property int e_starView: 0;
  readonly property int e_triangleView: 1;
  readonly property int e_threePhaseView: 2;

  property int viewMode : e_starView;

  readonly property int e_DIN: 0;
  readonly property int e_IEC: 1;

  property int referencePhaseMode: e_DIN;

  property real phiOrigin: dinIECSelector.din410 ? Math.atan2(vData.getVector(0).y,vData.getVector(0).x)+Math.PI/2 : Math.atan2(vData.getVector(3).y,vData.getVector(3).x)
  property int selectedVector: 0
  property int animDuration: 0 //600
  property var vectorColors: getColors()

  function getColors() {
    var it = Array();

    it.push(GC.system1ColorDark);
    it.push(GC.system2ColorDark);
    it.push(GC.system3ColorDark);
    it.push(GC.system1ColorBright);
    it.push(GC.system2ColorBright);
    it.push(GC.system3ColorBright);

    return it;
  }

  CCMP.ZComboBox {
    id: viewModeSelector

    z: 1 + iOnOffSelector.z + dinIECSelector.z

    onTargetIndexChanged: {
      root.viewMode = targetIndex
    }

    arrayMode: true
    model: ["VEC  UL  PN", "VEC  UL  △", "VEC  UL  ∠"]

    anchors.topMargin: 20
    anchors.top: root.top;
    anchors.right: root.right
    anchors.rightMargin: 20
    height: root.height/14
    width: root.width/7
  }

  CCMP.ZComboBox {
    /// @fixme rename to currentOnOffSelector
    id: iOnOffSelector

    z: 1 + dinIECSelector.z

    property bool iOn: targetIndex===0

    arrayMode: true
    model: ["VEC  IL  ON", "VEC  IL  OFF"]

    anchors.topMargin: 24
    anchors.top: viewModeSelector.bottom;
    anchors.right: root.right
    anchors.rightMargin: 20
    height: root.height/14
    width: root.width/7
  }

  CCMP.ZComboBox {
    id: dinIECSelector

    z: 1

    property bool din410: targetIndex===0

    arrayMode: true
    model: ["DIN410", "IEC387"]

    anchors.topMargin: 24
    anchors.top: iOnOffSelector.bottom;
    anchors.right: root.right
    anchors.rightMargin: 20
    height: root.height/14
    width: root.width/7
  }

  Item {
    id: vData

    function getVectorName(vecIndex) {
      var retVal;
      if(root.viewMode===root.e_starView || root.viewMode===root.e_triangleView)
      {
        retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN"+parseInt(vecIndex+1)].ChannelName
      }
      if(root.viewMode===root.e_threePhaseView)
      {
        if(vecIndex<3)
        {
          retVal=metadata.ComponentInfo["ACT_DFTPP"+parseInt(vecIndex+1)].ChannelName;
        }
        else
        {
          retVal = ModuleIntrospection.dftIntrospection.ComponentInfo["ACT_DFTPN"+parseInt(vecIndex+1)].ChannelName
        }
      }
      return retVal;
    }

    function toVector(doubleList) {
      return Qt.vector2d(doubleList[0], doubleList[1]);
    }


    function getVector(vecIndex) {
      var retVal;
      if(root.viewMode===root.e_starView || root.viewMode===root.e_triangleView)
      {
        retVal = toVector(root.dft["ACT_DFTPN"+parseInt(vecIndex+1)])
      }
      else if(root.viewMode===root.e_threePhaseView)
      {
        switch(vecIndex)
        {
        case 0:
        case 1:
          retVal=toVector(root.dft["ACT_DFTPP"+parseInt(vecIndex+1)]);
          break;
        case 3:
        case 5:
          retVal=toVector(root.dft["ACT_DFTPN"+parseInt(vecIndex+1)]);
          break;
        case 2:
        case 4:
          retVal=Qt.vector2d(0,0);
          break;
        }
      }
      return retVal;
    }

    function getCircleValue(vecIndex) {
      var retVal = root.rangeInfo[String("INF_Channel%1ActREJ").arg(vecIndex)];
      return retVal;
    }

    function getMaxOVRRejectionU() {
      var retVal = 0;
      retVal = Math.max(retVal, root.rangeInfo.INF_Channel1ActOVLREJ)
      retVal = Math.max(retVal, root.rangeInfo.INF_Channel2ActOVLREJ)
      retVal = Math.max(retVal, root.rangeInfo.INF_Channel3ActOVLREJ)
      return retVal
    }

    function getMaxOVRRejectionI() {
      var retVal = 0;
      retVal = Math.max(retVal, root.rangeInfo.INF_Channel4ActOVLREJ)
      retVal = Math.max(retVal, root.rangeInfo.INF_Channel5ActOVLREJ)
      retVal = Math.max(retVal, root.rangeInfo.INF_Channel6ActOVLREJ)
      return retVal
    }
  }

  Behavior on phiOrigin {
    NumberAnimation {
      //This specifies how long the animation takes
      duration: root.animDuration
      //This selects an easing curve to interpolate with, the default is Easing.Linear
      easing.type: Easing.InOutCubic
    }
  }
  anchors.fill: parent


  ListModel { ///todo: TBD
    id: vectors

    ListElement { vColor: 0; origin: true; }
    ListElement { vColor: 1; }
    ListElement { vColor: 2; }
    ListElement { vColor: 3; }
    ListElement { vColor: 4; }
    ListElement { vColor: 5; }
  }

  CCMP.CanvasTriangle {
    phi: root.phiOrigin
    anchors.fill: parent

    visible: root.viewMode === root.e_triangleView
    onVisibleChanged: {
      if(visible === true)
      {
        replot()
      }
    }

    circleValue: vData.getMaxOVRRejectionU()
    circleColor: Material.frameColor
    v1: vData.getVector(0);
    v1Color: root.getColors()[0]
    v1Label: (v1.length()>maxValue/10 ) ? vData.getVectorName(0) : "";

    v2: vData.getVector(1);
    v2Color: root.getColors()[1]
    v2Label: (v2.length()>maxValue/10 ) ? vData.getVectorName(1) : "";

    v3: vData.getVector(2);
    v3Color: root.getColors()[2]
    v3Label: (v3.length()>maxValue/10 ) ? vData.getVectorName(2) : "";

    maxValue: vData.getMaxOVRRejectionU()*Math.sqrt(2)
  }

  PathView {
    visible: true
    anchors.fill: parent


    model: vectors
    delegate: vectorDelegate
    interactive: false //used to not swallow mouse events
    enabled: false //used to not swallow mouse events

    path: Path {
      startX: 0; startY: 0
      PathQuad { x: 0; y: 0; controlX: 0; controlY: 0 }
    }
    Component {
      id: vectorDelegate
      CCMP.CanvasVector {
        property vector2d vectorData: vData.getVector(index)
        anchors.fill: parent

        visible: ( root.viewMode===root.e_triangleView && index<3 ) ? false : (index<3 || iOnOffSelector.iOn)
        onVisibleChanged: replot()

        radius: ( root.viewMode===root.e_threePhaseView && index<3 ) ? vectorData.length()/Math.sqrt(3)  : vectorData.length()

        phi:  Math.atan2(vectorData.y, vectorData.x) - root.phiOrigin

        labelText: ( radius > maxValue/10) ? vData.getVectorName(index) : "";

        labelLengthFactor: (index<3) ? 1.0 : 0.5
        labelPhiOffset: (index<3) ? 0 : -10 * Math.PI/180

        color: root.vectorColors[vColor]
        circleColor: Material.frameColor
        circle: origin
        circleValue: vData.getMaxOVRRejectionU()
        grid: origin
        maxValue: (index<3) ? vData.getMaxOVRRejectionU()*Math.sqrt(2) : vData.getMaxOVRRejectionI()*Math.sqrt(2)
      }
    }
  }
}
