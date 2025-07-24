import QtQuick 2.14
import QtQuick.Controls.Material 2.14
import ColorSettings 1.0

/**
  * @b substitute for QQC2 Frame that has stupid content padding
  */
Rectangle {
    color: Material.backgroundColor
    border.color: CS.dividerColor
}
