import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import FontAwesomeQml 1.0

Item {
    id: root
    property var model;
    onModelChanged: {
        if(model && model.count > 0)
            pageLoaderSource = model.get(0).elementValue;
    }
    property alias sessionComponent: sessionSelector.intermediate
    property string pageLoaderSource;

    property bool gridViewEnabled: GC.pagesGridViewDisplay;
    onGridViewEnabledChanged: GC.setPagesGridViewDisplay(gridViewEnabled);

    signal closeView();
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
        font.pointSize: 18
        text: FAQ.fa_list_alt
        anchors.right: gridViewButton.left
        anchors.rightMargin: 8
        flat: true
        enabled: root.gridViewEnabled === true
        onClicked: root.gridViewEnabled = false;
    }
    Button {
        id: gridViewButton
        font.pointSize: 18
        text: FAQ.fa_circle_notch
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
                if(elementValue !== "")
                    root.elementSelected(elementValue.value);
            }
        }
    }
    Component {
        id: pagePathViewCmp
        PagePathView {
            model: root.model
            onElementSelected: {
                if(elementValue !== "")
                    root.elementSelected(elementValue.value);
            }
        }
    }
    Loader {
        anchors.fill: parent
        sourceComponent: root.gridViewEnabled ? pageGridViewCmp : pagePathViewCmp;
        active: root.visible === true && root.model !== undefined;
    }

    Button {
        height: root.height * 0.125
        width: root.width * 0.25
        font.pointSize: root.height * 0.04
        text: Z.tr("Close")
        anchors.right: parent.right
        anchors.rightMargin: root.width * 0.01
        anchors.bottom: parent.bottom
        onClicked: root.closeView()
    }

    Rectangle {
        anchors.top: root.top
        anchors.left: root.left
        height: root.height * 0.1
        width: root.width * 0.38
        color: Material.dropShadowColor
        visible: sessionSelector.model.length > 1

        ZComboBox {
            id: sessionSelector

            property QtObject systemEntity;
            property string intermediate
            property var arrDisplayStrings: [Z.tr("Default"), Z.tr("Changing energy direction"), Z.tr("Reference"), Z.tr("DC: 4*Voltage / 1*Current"), "EMOB AC", "EMOB DC", Z.tr("3 Systems / 2 Wires")]
            property var arrJSONDetectStrings: ["meas-session.json", "ced-session.json", "ref-session.json", "dc-session.json", "emob-session-ac.json", "emob-session-dc.json", "perphase-session.json"]
            property var arrJSONFileNames: []

            anchors.fill: parent
            arrayMode: true
            onIntermediateChanged: {
                var tmpIndex = arrJSONFileNames.indexOf(intermediate)
                if(tmpIndex >= 0)
                    sessionSelector.currentIndex = tmpIndex
            }

            onSelectedTextChanged: {
                var tmpIndex = model.indexOf(selectedText)
                if(systemEntity && systemEntity.SessionsAvailable)
                    systemEntity.Session = arrJSONFileNames[tmpIndex]
            }

            model: {
                var retVal = []
                if(systemEntity && systemEntity.SessionsAvailable) {
                    var jsonFileNames = []
                    for (var sessionFile of systemEntity.SessionsAvailable) {
                        jsonFileNames.push(sessionFile)
                        var replaced = false
                        for(var arrIdx=0; arrIdx<arrDisplayStrings.length; ++arrIdx) {
                            if(sessionFile.endsWith(arrJSONDetectStrings[arrIdx])) {
                                retVal.push(arrDisplayStrings[arrIdx])
                                replaced = true
                                break;
                            }
                        }
                        if(!replaced)
                            retVal.push(sessionFile)
                    }
                    arrJSONFileNames = jsonFileNames
                }
                else
                    retVal = ["Unsupported"] //fallback
                return retVal
            }

            Connections {
                target: VeinEntity
                function onSigEntityAvailable(t_entityName) {
                    if(t_entityName === "_System")
                        sessionSelector.systemEntity = VeinEntity.getEntity("_System");
                }
            }
        }
    }
}
