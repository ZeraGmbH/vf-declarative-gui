import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import SortFilterProxyModel 0.2
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraTranslation  1.0
import ZeraThemeConfig 1.0
import FontAwesomeQml 1.0
import "../controls"
import "../controls/settings"

Item {
    id: root

    readonly property int channelCount: GC.showAuxPhases ? ModuleIntrospection.rmsIntrospection.ModuleInfo.RMSPNCount : Math.min(ModuleIntrospection.rmsIntrospection.ModuleInfo.RMSPNCount, 6)
    readonly property bool displayAuxColumn: channelCount > 6
    readonly property real safeHeight: height > 0 ? height : 10
    readonly property real row1stHeight: safeHeight * 0.125
    readonly property real rowHeight: (safeHeight-row1stHeight) / 4
    readonly property real columnWidth1st: pixelSize * 2.35
    readonly property real columnWidthLast: pixelSize * 1.8
    readonly property real columnWidth: (width-(columnWidth1st+columnWidthLast))/(channelCount/2)
    readonly property real pixelSize: (displayAuxColumn ? rowHeight*0.36 : rowHeight*0.42)

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: columnWidth1st
        height: row1stHeight
        // hide item below
        z: 1
        color: Material.backgroundColor
        visible: settingsPopup.settingsRowCount > 0
        Button {
            id: settingsButton
            anchors.fill: parent
            anchors.topMargin: -4
            anchors.bottomMargin: -4
            text: FAQ.fa_cogs
            font.pointSize: row1stHeight*0.45
            onClicked: settingsPopup.open()
        }
    }
    InViewSettingsPopup {
        id: settingsPopup
        settingsRowCount: (hasAux ? 1 : 0)
        Column {
            anchors.topMargin: settingsPopup.rowHeight/2
            anchors.fill: parent
            InViewSettingsCheckShowAux {
                width: settingsPopup.width
                enabledHeight: settingsPopup.inPopupRowHeight
            }
        }
    }

    /* Two SortFilterProxyModel is a performance expensive crap quick fix for
       SortFilterProxyModel not reacting properly on model change at runtime.
       Test case:
       * Start application with AUX phases not displayed
       * Move to RMS4PhasePage (Actual values / most right tab)
       * Enable AUX -> AUX column empty / QML complaints for 'AUX' missing
     */
    SortFilterProxyModel {
        id: filteredActualValueModel
        sourceModel: ZGL.ActualValueModel
        filters: [
            RegExpFilter {
                roleName: "Name"
                // specify by Name-role (1st column) what to see (leading empty string for header row
                pattern: "^$|^"+Z.tr("UPN")+"$|^"+Z.tr("I")+"$|^"+Z.tr("∠U")+"$|^"+Z.tr("∠I")+"$"
                caseSensitivity: Qt.CaseInsensitive
            }
        ]
    }
    SortFilterProxyModel {
        id: filteredActualValueModelAux
        sourceModel: ZGL.ActualValueModelWithAux
        filters: [
            RegExpFilter {
                roleName: "Name"
                // specify by Name-role (1st column) what to see (leading empty string for header row
                pattern: "^$|^"+Z.tr("UPN")+"$|^"+Z.tr("I")+"$|^"+Z.tr("∠U")+"$|^"+Z.tr("∠I")+"$"
                caseSensitivity: Qt.CaseInsensitive
            }
        ]
    }
    Item {
        anchors.fill: parent
        ListView {
            anchors.fill: parent
            model: displayAuxColumn ? filteredActualValueModelAux : filteredActualValueModel
            boundsBehavior: Flickable.StopAtBounds
            delegate: Component {
                Row {
                    id: row
                    height: index === 0 ? row1stHeight : rowHeight
                    readonly property bool isCurrent: Name === Z.tr("kI") || Name === Z.tr("I") || Name === Z.tr("∠I")
                    readonly property string rowColor: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
                    GridItem {
                        width: columnWidth1st
                        height: parent.height
                        color: ZTC.tableHeaderColor
                        text: Name!==undefined ? Name : ""
                        font.pixelSize: root.pixelSize
                    }
                    GridItem {
                        width: columnWidth
                        height: parent.height
                        color: row.rowColor
                        text: FT.formatNumberForScaledValues(L1)
                        textColor: isCurrent ? CS.colorIL1 : CS.colorUL1
                        font.pixelSize: root.pixelSize
                    }
                    GridItem {
                        width: columnWidth
                        height: parent.height
                        color: row.rowColor
                        text: FT.formatNumberForScaledValues(L2)
                        textColor: isCurrent ? CS.colorIL2 : CS.colorUL2
                        font.pixelSize: root.pixelSize
                    }
                    GridItem {
                        width: columnWidth
                        height: parent.height
                        color: row.rowColor
                        text: FT.formatNumberForScaledValues(L3)
                        textColor: isCurrent ? CS.colorIL3 : CS.colorUL3
                        font.pixelSize: root.pixelSize
                    }
                    GridItem {
                        width: columnWidth
                        height: parent.height
                        color: row.rowColor
                        text: displayAuxColumn ? FT.formatNumberForScaledValues(AUX) : ""
                        textColor: isCurrent ? CS.colorIAux1 : CS.colorUAux1
                        font.pixelSize: root.pixelSize
                        visible: displayAuxColumn
                    }
                    GridItem {
                        width: columnWidthLast
                        height: parent.height
                        color: row.rowColor
                        text: Unit ? Unit : ""
                        font.pixelSize: root.pixelSize
                    }
                }
            }
        }
    }
}
