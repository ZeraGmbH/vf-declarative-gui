import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP

Item {
  id: root
  property var model;
  onModelChanged: {
    if(model && model.count>0)
    {
      pageLoaderSource = model.get(0).elementValue;
    }
  }
  property alias sessionComponent: sessionSelector.intermediate
  property string pageLoaderSource;

  property bool gridViewEnabled: GC.pagesGridViewDisplay;
  onGridViewEnabledChanged: GC.setPagesGridViewDisplay(gridViewEnabled);

  signal closeView();
  signal sessionChanged();

  function elementSelected(elementValue) {
    pageLoaderSource = elementValue
    closeView();
  }

  Rectangle {
    color: Material.backgroundColor
    opacity: 0.9
    anchors.fill: parent
  }

  Button {
    font.family: FA.old
    font.pointSize: 18
    text: FA.icon(FA.fa_image)
    anchors.right: gridViewButton.left
    anchors.rightMargin: 8
    flat: true
    enabled: root.gridViewEnabled === true
    onClicked: root.gridViewEnabled = false;
  }
  Button {
    id: gridViewButton
    font.family: FA.old
    font.pointSize: 18
    text: FA.icon(FA.fa_list_ul)
    anchors.right: parent.right
    anchors.rightMargin: 32
    flat: true
    enabled: root.gridViewEnabled === false
    onClicked: root.gridViewEnabled = true;
  }

  Component {
    id: pageGridViewCmp
    CCMP.PageGridView {
      model: root.model

      onElementSelected: {
        if(elementValue !== "")
        {
          root.elementSelected(elementValue.value);
        }
      }
    }
  }

  Component {
    id: pagePathViewCmp
    CCMP.PagePathView {
      model: root.model

      onElementSelected: {
        if(elementValue !== "")
        {
          root.elementSelected(elementValue.value);
        }
      }
    }
  }

  Loader {
    anchors.fill: parent
    sourceComponent: root.gridViewEnabled ? pageGridViewCmp : pagePathViewCmp;
    active: root.visible === true && root.model !== undefined;
  }

  Button {
    height: root.height/10
    Material.accent: Material.color(Material.Red)
    highlighted: true
    font.family: FA.old
    font.pixelSize: 20
    text: FA.icon(FA.fa_times) + Z.tr("Close")
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    onClicked: root.closeView()
  }

  Rectangle {
    anchors.top: root.top
    anchors.left: root.left
    height: root.height/10
    width: root.width/3
    color: Material.dropShadowColor
    visible: sessionSelector.model.length > 1

    ZComboBox {
      id: sessionSelector

      property QtObject systemEntity;
      property string intermediate


      anchors.fill: parent
      arrayMode: true
      onIntermediateChanged: {
        var tmpIndex = model.indexOf(intermediate)

        if(tmpIndex !== undefined && sessionSelector.currentIndex !== tmpIndex)
        {
          sessionSelector.currentIndex = tmpIndex
        }
      }

      onSelectedTextChanged: {
        var tmpIndex = model.indexOf(selectedText)
        //console.assert(tmpIndex >= 0 && tmpIndex < model.length)
        if(systemEntity && systemEntity.SessionsAvailable)
        {
          systemEntity.Session = systemEntity.SessionsAvailable[tmpIndex];
        }
        root.sessionChanged()
      }

      model: {
        var retVal = [];
        if(systemEntity && systemEntity.SessionsAvailable) {
          for(var sessionIndex in systemEntity.SessionsAvailable)
          {
            retVal.push(systemEntity.SessionsAvailable[sessionIndex]);
          }
        }
        else {
          retVal = ["Default session", "Reference session", "CED session"]; //fallback
        }

        return retVal;
      }

      Connections {
        target: VeinEntity
        onSigEntityAvailable: {
          if(t_entityName === "_System")
          {
            sessionSelector.systemEntity = VeinEntity.getEntity("_System");
          }
        }
      }
    }
  }
}
