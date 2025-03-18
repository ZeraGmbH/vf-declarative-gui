import QtQuick 2.14
import QtQuick.Controls 2.0
import ModuleIntrospection 1.0

Popup {
    // Property to set
    property real settingsRowCount

    readonly property real rowHeight: parent.height * 0.075
    readonly property bool hasAux: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount > 6

    x: 0; y: 0
    width: parent.width * 0.55
    readonly property real heightMult: 1.25
    readonly property real inPopupRowHeight: rowHeight * heightMult
    height: rowHeight * (settingsRowCount + 1) * heightMult
    verticalPadding: 0
    horizontalPadding: 0
}
