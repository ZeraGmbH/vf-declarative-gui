import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item {
  id: root

  readonly property int rowHeight: Math.floor(height/20)
  property var errorDataModel: [];

  TabBar {
    id: informationSelector
    width: parent.width
    height: root.rowHeight*1.5
    currentIndex: 0
    TabButton {
      id: errorLogButton
      text: FA.icon(FA.fa_exclamation_triangle, GC.tmpStatusNewErrors ? Material.color(Material.Yellow) : "#44ffffff" )+ZTR["Device log"]
      font.family: "FontAwesome"
      height: parent.height
      font.pixelSize: height/2
    }
    TabButton {
      text: FA.icon(FA.fa_info_circle)+ZTR["Device info"]
      font.family: "FontAwesome"
      height: parent.height
      font.pixelSize: height/2
      enabled: VeinEntity.hasEntity("StatusModule1")
    }
    TabButton {
      text: FA.icon("<b>§</b>")+ZTR["License information"]
      font.family: "FontAwesome"
      height: parent.height
      font.pixelSize: height/2
    }
  }

  StackLayout {
    id: stackLayout
    anchors.fill: parent
    anchors.topMargin: informationSelector.height + root.rowHeight/2
    currentIndex: informationSelector.currentIndex

    Loader {
      active: stackLayout.currentIndex === 0
      sourceComponent: Notifications {
        errorDataModel: root.errorDataModel
      }
      onActiveChanged: {
        if(active === false)
        {
          GC.tmpStatusNewErrors = false;
        }
      }
      Component.onDestruction: GC.tmpStatusNewErrors = false;
    }
    Loader {
      active: stackLayout.currentIndex === 1
      sourceComponent: DeviceInformation {
      }
    }
    Loader {
      active: stackLayout.currentIndex === 2
      sourceComponent: LicenseInformation {
      }
    }
  }
}
