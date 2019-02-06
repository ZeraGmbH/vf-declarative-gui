import QtQuick 2.5
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import "qrc:/data/staticdata/FontAwesome.js" as FA
import "qrc:/components/common" as CCMP
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0

/**
  * @b A selection of the available pages/views laid out in an elliptic path
  */
Item {
  id: root

  property int lastSelecedIndex

  property bool gridViewEnabled: GC.pagesGridViewDisplay;
  onGridViewEnabledChanged: GC.setPagesGridViewDisplay(gridViewEnabled);
  property double m_w: width
  property double m_h: height
  readonly property double scaleFactor: Math.min(m_w/1024, m_h/600);

  property var model;
  property alias sessionComponent: sessionSelector.intermediate

  //negative for no element
  signal elementSelected(var elementValue)
  signal cancelSelected()

  function incrementElement() {
    delayedOperation.command = pathView.incrementCurrentIndex
    delayedOperation.start();
  }

  function decrementElement() {
    delayedOperation.command = pathView.decrementCurrentIndex
    delayedOperation.start();
  }

  onModelChanged: {
    pathView.currentIndex = 0;
  }

  onVisibleChanged: {
    if(visible)
    {
      lastSelecedIndex = pathView.currentIndex
    }
    else
    {
      pathView.currentIndex = lastSelecedIndex
    }
  }

  Timer {
    id: delayedOperation
    property var command
    interval: 50
    repeat: false
    onTriggered: {
      command();
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      ;; //prevents unintentional clicks to underlying elements
    }
  }

  Rectangle {
    color: Material.backgroundColor
    opacity: 0.7
    anchors.fill: parent
  }


  Button {
    font.family: "FontAwesome"
    font.pointSize: 18
    text: FA.icon(FA.fa_image)
    anchors.right: gridViewButton.left
    anchors.rightMargin: 8
    flat: true
    enabled: root.gridViewEnabled == true
    onClicked: root.gridViewEnabled = false;
  }
  Button {
    id: gridViewButton
    font.family: "FontAwesome"
    font.pointSize: 18
    text: FA.icon(FA.fa_list_ul)
    anchors.right: parent.right
    flat: true
    enabled: root.gridViewEnabled == false
    onClicked: root.gridViewEnabled = true;
  }

  Component {
    id: pageDelegate

    Item {
      id: wrapper
      width: 128; height: 64
      scale: PathView.iconScale
      opacity: PathView.iconOpacity
      z: -1/PathView.iconOpacity
      property string itemName: name

      Rectangle {
        id: previewImage
        anchors.centerIn: parent
        border.color: Qt.darker(Material.frameColor, 1.3)
        border.width: 3
        width: 410*scaleFactor+4
        height: 220*scaleFactor+6
        color: "transparent" //Material.backgroundColor
        radius: 4

        Image {
          anchors.centerIn: parent
          source: icon
          scale: 0.8*scaleFactor
          mipmap: false
        }

        MouseArea {
          anchors.fill: parent
          onPressed: {
            if(wrapper.PathView.isCurrentItem &&
                (pathView.offset - Math.floor(pathView.offset)) == 0) //prevents unexpected user activation of items while they move around
            {
              root.lastSelecedIndex = index
              root.elementSelected({"elementIndex": index, "value": elementValue})
            }
            else
            {
              if(mapToItem(root, mouse.x, mouse.y).x<=root.width/2)
              {
                pathView.incrementCurrentIndex()
              }
              else
              {
                pathView.decrementCurrentIndex()
              }
            }
          }
        }
      }
      Label {
        id: nameText
        text: ZTR[name]
        textFormat: Text.PlainText
        anchors.horizontalCenter: previewImage.horizontalCenter
        anchors.bottom: previewImage.bottom
        anchors.bottomMargin: -font.pointSize*2
        font.pointSize: 16
        color: (wrapper.PathView.isCurrentItem ? Material.accentColor : Material.primaryTextColor)
        Rectangle {
          anchors.fill: parent
          anchors.margins: -4
          radius: 4
          opacity: 0.8
          color: Material.dropShadowColor
          z: parent.z-1
        }
      }
    }
  }

  Component {
    id: gridDelegate

    Rectangle {
      id: gridWrapper
      property string itemName: name
      border.color: Qt.darker(Material.frameColor, 1.3)
      border.width: 3
      width: root.width/3 - 8
      height: 64*scaleFactor+6
      color: "#11ffffff" //Material.backgroundColor
      radius: 4

      MouseArea {
        anchors.fill: parent
        onClicked: {
          gridView.currentIndex = index;
          root.elementSelected({"elementIndex": index, "value": elementValue})
        }
      }
      Image {
        id: listImage
        width: height*1.83
        height: parent.height-8
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 4
        source: icon
        mipmap: true
      }
      Label {
        text: ZTR[name]
        textFormat: Text.PlainText
        anchors.left: listImage.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Label.WordWrap
        font.pointSize: 14
        color: (gridWrapper.ListView.isCurrentItem ? Material.accentColor : Material.primaryTextColor)
      }
    }
  }


  GridView {
    id: gridView
    visible: root.gridViewEnabled
    model: root.model
    flow: GridView.FlowTopToBottom
    boundsBehavior: Flickable.StopAtBounds
    cellHeight: 64*scaleFactor+12
    cellWidth: width/3
    anchors.fill: parent
    anchors.topMargin: root.height/10
    anchors.bottomMargin: root.height/10
    clip: true
    onCurrentItemChanged: {
      //untranslated raw text
      GC.currentViewName = currentItem.itemName;
    }

    delegate: gridDelegate
  }

  PathView {
    id: pathView
    visible: root.gridViewEnabled == false
    model: root.model
    interactive: false
    enabled: visible
    anchors.fill: parent
    highlightMoveDuration: 200

    onCurrentItemChanged: {
      //untranslated raw text
      GC.currentViewName = currentItem.itemName;
    }

    delegate: pageDelegate
    path: Path {
      startX: width/2;
      startY: height/1.8

      //describes an ellipse, the elements get scaled down and become more transparent the farther away they are from the current index on that ring
      PathAttribute { name: "iconScale"; value: 1.0 }
      PathAttribute { name: "iconOpacity"; value: 1.0 }
      PathQuad { x: m_w/2; y: 200; controlX: -m_w*0.3; controlY: m_h/4+100 }
      PathAttribute { name: "iconScale"; value: 0.4 }
      PathAttribute { name: "iconOpacity"; value: 0.2 }
      PathQuad { x: m_w/2; y: m_h/1.8; controlX: m_w*1.3; controlY: m_h/4+100 }
    }
  }

  Button {
    height: root.height/10
    width: height*3
    Material.accent: Material.color(Material.Red)
    highlighted: true
    font.family: "FontAwesome"
    font.pixelSize: 20
    text: FA.icon(FA.fa_times) + ZTR["Close"]
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: height/4
    onClicked: cancelSelected()
  }

  Rectangle {
    anchors.top: root.top
    anchors.left: root.left
    height: root.height/10
    width: root.width/3
    color: Material.dropShadowColor
    visible: sessionSelector.model.length > 1

    CCMP.ZComboBox {
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

        layoutStack.currentIndex=0;
        rangeIndicator.active = false;
        pageLoader.active = false;
        entitiesInitialized = false;
        loadingScreen.open();
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
