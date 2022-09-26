import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import ZeraFa 1.0

Item {
    id: root
    property var model;
    onModelChanged: {
        if(model && model.count > 0) {
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
        // Hack: PagePathView is not interactive. That causes mouse activities
        // being performed in windows below and worst case open virtual keyboard
        // to avoid that add a dummy MouseArea. Tried better places e.g PagePathView
        // but that did not work
        MouseArea {
            anchors.fill: parent
        }
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
        PageGridView {
            model: root.model
            onElementSelected: {
                if(elementValue !== "")  {
                    root.elementSelected(elementValue.value);
                }
            }
        }
    }

    Component {
        id: pagePathViewCmp
        PagePathView {
            model: root.model
            onElementSelected: {
                if(elementValue !== "") {
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
        width: root.width/2.8
        color: Material.dropShadowColor
        visible: sessionSelector.model.length > 1

        ZComboBox {
            id: sessionSelector

            property QtObject systemEntity;
            property string intermediate
            property var arrDisplayStrings: [Z.tr("Default"), Z.tr("Changing energy direction"), Z.tr("Reference"), Z.tr("DC 4U/1I"), "EMOB AC/DC"]
            property var arrJSONDetectStrings: ["meas-session.json", "ced-session.json", "ref-session.json", "dc-session.json", "emob-session.json"]
            property var arrJSONFileNames: []

            anchors.fill: parent
            arrayMode: true
            onIntermediateChanged: {
                let tmpIndex = arrJSONFileNames.indexOf(intermediate)
                if(tmpIndex >= 0) {
                    sessionSelector.currentIndex = tmpIndex
                }
            }

            onSelectedTextChanged: {
                var tmpIndex = model.indexOf(selectedText)
                if(systemEntity && systemEntity.SessionsAvailable) {
                    systemEntity.Session = arrJSONFileNames[tmpIndex];
                }
                root.sessionChanged()
            }

            model: {
                var retVal = [];
                if(systemEntity && systemEntity.SessionsAvailable) {
                    arrJSONFileNames = []
                    for(let sessionIndex in systemEntity.SessionsAvailable) {
                        let sessionFile = systemEntity.SessionsAvailable[sessionIndex]
                        arrJSONFileNames.push(sessionFile)
                        let replaced = false
                        for(let arrIdx=0; arrIdx<arrDisplayStrings.length; ++arrIdx) {
                            if(sessionFile.endsWith(arrJSONDetectStrings[arrIdx])) {
                                retVal.push(arrDisplayStrings[arrIdx])
                                replaced = true
                                break;
                            }
                        }
                        if(!replaced) {
                            retVal.push(sessionFile)
                        }
                    }
                }
                else {
                    retVal = ["Unsupprted"] //fallback
                }
                return retVal
            }

            Connections {
                target: VeinEntity
                function onSigEntityAvailable(t_entityName) {
                    if(t_entityName === "_System") {
                        sessionSelector.systemEntity = VeinEntity.getEntity("_System");
                    }
                }
            }
        }
    }
}
