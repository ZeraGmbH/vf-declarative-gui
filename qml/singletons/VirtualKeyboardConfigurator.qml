//this is not a "pragma Singleton", but it makes no sense to create more than one instance of this object
import QtQuick 2.0
import QtQuick.VirtualKeyboard.Settings 2.0

/**
  * @b sets the configuration for the system wide application independent QtVirtualKeyboard instance
  */
Item {
  property bool textPreviewMode: false;
  Component.onCompleted: {
    VirtualKeyboardSettings.fullScreenMode=textPreviewMode;
    console.log("Detected qtvirtualkeyboard, setting fullScreenMode:", textPreviewMode);
  }
}
