import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

StackLayout {
    function showSettings() { currentIndex = 0 }
    LoggerSettings { }

    function showSessionNameSelector() { currentIndex = 1 }
    LoggerSessionNameSelector { id: loggerSessionNameSelector }

    function showCustomDataSelector() { currentIndex = 2 }
    LoggerCustomDataSelector{ }
}
