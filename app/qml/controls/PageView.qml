import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import GlobalConfig 1.0
import SessionState 1.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import FontAwesomeHash 1.0

Item {
    id: root
    visible: false // init
    property var model
    signal sigPageSelected(pageSource: string)
    signal sigCloseViewRequest();

    Rectangle {
        color: Material.backgroundColor
        opacity: 0.9
        anchors.fill: parent
        // Hack: PagePathView is not interactive. That causes mouse activities
        // being performed in windows below and worst case open virtual keyboard
        // to avoid that add a dummy MouseArea. Tried better places e.g PagePathView
        // but that did not work
        MouseArea { anchors.fill: parent }
    }

    ZComboBox {
        id: sessionSelector
        anchors.top: root.top
        anchors.left: root.left
        height: root.height * 0.1
        width: root.width * 0.38
        visible: sessionSelector.model.length > 1
        z: 1

        arrayMode: true
        property var arrDisplayStrings: [Z.tr("Default"), Z.tr("Changing energy direction"), Z.tr("Reference"), Z.tr("DC: 4*Voltage / 1*Current"), "EMOB AC", "EMOB DC", Z.tr("3 Systems / 2 Wires")]
        property var arrJSONDetectStrings: ["meas-session.json", "ced-session.json", "ref-session.json", "dc-session.json", "emob-session-ac.json", "emob-session-dc.json", "perphase-session.json"]
        property var arrJSONFileNames: []
        model: {
            var retVal = []
            if (sessionsAvailable !== "") {
                var jsonFileNames = []
                for (var sessionFile of sessionsAvailable) {
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
            return retVal
        }

        readonly property QtObject systemEntity: GC.entityInitializationDone ? VeinEntity.getEntity("_System") : null
        readonly property var sessionsAvailable: systemEntity ? systemEntity.SessionsAvailable : ""
        readonly property string currentSession: systemEntity ? systemEntity.Session : ""
        function selectCurrentSession() {
            var tmpIndex = arrJSONFileNames.indexOf(SessionState.currentSession)
            if(tmpIndex >= 0)
                sessionSelector.currentIndex = tmpIndex
        }
        onModelChanged: { selectCurrentSession() }
        onCurrentSessionChanged: { selectCurrentSession() }
        onSelectedTextChanged: {
            var tmpIndex = model.indexOf(selectedText)
            if(systemEntity && systemEntity.SessionsAvailable) {
                var session = arrJSONFileNames[tmpIndex]
                systemEntity.Session = session
                // ZComboBox must close before view
                Qt.callLater(sigCloseViewRequest)
            }
        }
    }

    property bool gridViewEnabled: GC.pagesGridViewDisplay;
    onGridViewEnabledChanged: GC.setPagesGridViewDisplay(gridViewEnabled);
    ZButton {
        id: carouselViewButton
        font.pointSize: 18
        text: FAQH.strToGlyph("fa_list_alt")
        anchors.right: gridViewButton.left
        anchors.rightMargin: 8
        flat: true
        enabled: root.gridViewEnabled === true
        onClicked: root.gridViewEnabled = false;
    }
    ZButton {
        id: gridViewButton
        font.pointSize: 18
        text: FAQH.strToGlyph("fa_circle_notch")
        anchors.right: parent.right
        anchors.rightMargin: 32
        flat: true
        enabled: root.gridViewEnabled === false
        onClicked: root.gridViewEnabled = true;
    }

    Loader {
        id: tabSelector
        anchors.fill: parent
        sourceComponent: root.gridViewEnabled ? pageGridViewCmp : pagePathViewCmp;
        active: root.visible === true && root.model !== undefined;
        function elementSelected(elementValue) {
            sigPageSelected(elementValue)
            sigCloseViewRequest();
        }
        Component {
            id: pageGridViewCmp
            PageGridView {
                model: root.model
                onElementSelected: (elementValue) => {
                    if(elementValue !== "")
                        tabSelector.elementSelected(elementValue.value);
                }
            }
        }
        Component {
            id: pagePathViewCmp
            PagePathView {
                model: root.model
                onElementSelected: (elementValue) => {
                    if(elementValue !== "")
                        tabSelector.elementSelected(elementValue.value);
                }
            }
        }
    }

    ZButton {
        id: closeButton
        height: root.height * 0.125
        width: root.width * 0.25
        font.pointSize: Math.max(root.height * 0.04, 10)
        text: Z.tr("Close")
        anchors.right: parent.right
        anchors.rightMargin: root.width * 0.01
        anchors.bottom: parent.bottom
        onClicked: sigCloseViewRequest()
    }
}
