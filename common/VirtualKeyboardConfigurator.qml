import QtQuick 2.0
import QtQuick.VirtualKeyboard.Settings 2.0

Item {
  property bool textPreviewMode: false;
  Component.onCompleted: {
    VirtualKeyboardSettings.fullScreenMode=textPreviewMode;
  }
}
