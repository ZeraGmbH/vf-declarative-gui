import QtQuick 2.0
import QtQuick.VirtualKeyboard 2.3

// Workaround to avoid writing a complete new keyboard style
Key {
    keyPanelDelegate: keyboard.style ? keyboard.style.symbolKeyPanel : undefined
}
