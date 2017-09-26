import QtQuick 2.5
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import "qrc:/data/staticdata/FontAwesome.js" as FA
import "qrc:/components/common" as CCMP
import VeinEntity 1.0
import Com5003Translation  1.0

Item {
  id: root
  function incrementElement() {
    delayedOperation.command = pathView.incrementCurrentIndex
    delayedOperation.start();
  }

  function decrementElement() {
    delayedOperation.command = pathView.decrementCurrentIndex
    delayedOperation.start();
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

  //negative for no element
  signal elementSelected(var elementValue)
  signal cancelSelected()

  property int lastSelecedIndex

  property double m_w: width
  property double m_h: height

  property alias model: pathView.model
  property alias sessionComponent: sessionSelector.intermediate

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
  Component {
    id: pageDelegate

    Item {
      id: wrapper
      width: 128; height: 64
      scale: PathView.iconScale
      opacity: PathView.iconOpacity
      z: -1/PathView.iconOpacity

      Rectangle {
        id: previewImage
        anchors.centerIn: parent
        border.color: Qt.darker(Material.frameColor, 1.3)
        border.width: 3

        color: "transparent" //Material.backgroundColor
        radius: 4

        Image {
          anchors.centerIn: parent
          source: icon
          scale: 0.8
          mipmap: false
        }

        width: 410+4
        height: 220+6

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



  PathView {
    id: pathView
    interactive: false
    enabled: visible
    anchors.fill: parent
    highlightMoveDuration: 200

    delegate: pageDelegate
    path: Path {
      startX: width/2;
      startY: height/1.8

      //describes an ellipse, the elements get scaled down and become more transparent the farther away they are from the current index on that circle
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

    CCMP.ZComboBox {
      id: sessionSelector

      property string intermediate
      onIntermediateChanged: {
        var tmpIndex;

        if(intermediate === "0_default-session.json")
          tmpIndex=0;
        else if(intermediate === "1_ref-session.json")
          tmpIndex=1;
        else if(intermediate === "2_ced-session.json")
          tmpIndex=2;

        if(tmpIndex !== undefined && sessionSelector.currentIndex !== tmpIndex)
        {
          sessionSelector.currentIndex = tmpIndex
        }
      }

      onSelectedTextChanged: {
        var tmpIndex = model.indexOf(selectedText)
        switch(tmpIndex)
        {
        case 0:
          VeinEntity.getEntity("_System").Session="0_default-session.json";
          break;
        case 1:
          VeinEntity.getEntity("_System").Session="1_ref-session.json";
          break;
        case 2:
          VeinEntity.getEntity("_System").Session="2_ced-session.json";
          break;
        default:
          console.assert(tmpIndex < 3 && tmpIndex > 0, "Faulty code in PagePathView::sessionSelector::onTargetIndexChanged");
          break;
        }
        layoutStack.currentIndex=0;
        rangeIndicator.active = false;
        pageLoader.active = false;
        loadingScreen.open();
      }

      arrayMode: true
      model: [ZTR["Default session"], ZTR["Reference session"], ZTR["CED session"]]


      anchors.fill: parent
    }
  }
}
