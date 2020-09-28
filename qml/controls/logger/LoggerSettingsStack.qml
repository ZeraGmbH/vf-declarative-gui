import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

StackLayout {
    function showSettings() { currentIndex = 0 }
    LoggerSettings { }

    function showDataSetSelector() { currentIndex = 1 }
    LoggerDatasetSelector { }

    function showRecordNameSelector() { currentIndex = 2 }
    LoggerRecordNameSelector { id: loggerRecordnameSelector }
    property alias recordnameSelector: loggerRecordnameSelector // enable access to connect signal
}
