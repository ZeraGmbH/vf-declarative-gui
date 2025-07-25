pragma Singleton
import QtQuick 2.0
import GlobalConfig 1.0
import ColorSettings 1.0

Timer {
    /* Our target machine is terribly slow and some change of settings cause
       a property change storm. To avoid repsponse times of several seconds
       on in GUI, we keep the settings changes, start a timer and apply the
       changes later. Doing so the GUI reponse is immediate.
      */
    interval: 500
    repeat: false
    function startAuxPhaseChange(showAux) {
        nextShowAux = showAux
        auxPhaseSetPending = true
        restart()
    }
    function startShowFftTableAsRelativeChange(fftTableRelative) {
        nextFftTableRelative = fftTableRelative
        fftTableRelativePending = true
        restart()
    }
    function startShowFftAnglesChange(fftShowAngles) {
        nextFftShowAngles = fftShowAngles
        fftShowAnglesPending = true
        restart()
    }
    function startDigitsTotalChange(digitsTotal) {
        nextDigitsTotal = digitsTotal
        digitsTotalPending = true
        restart()
    }
    function startDecimalPlacesChange(decimalPlaces) {
        nextDecimalPlaces = decimalPlaces
        decimalPlacesPending = true
        restart()
    }
    function startAllColorChange(colorScheme) {
        nextColorScheme = colorScheme
        allColorChangePending = true
        restart()
    }
    function getCurrentColor(index) {
        if(!allColorChangePending) {
            return CS.currentColorTable[index-1]
        }
        else {
            return CS.defaultColorsTableArray[nextColorScheme][index-1]
        }
    }

    property bool auxPhaseSetPending: false
    property bool allColorChangePending: false
    property bool fftTableRelativePending: false
    property bool fftShowAnglesPending: false
    property bool digitsTotalPending: false
    property bool decimalPlacesPending: false

    property bool nextShowAux: false
    property int  nextColorScheme: 0
    property bool nextFftTableRelative: false
    property bool nextFftShowAngles: false
    property int  nextDigitsTotal: 0
    property int  nextDecimalPlaces: 0

    function applyPendingChanges() {
        if(auxPhaseSetPending) {
            GC.setShowAuxPhases(nextShowAux)
            auxPhaseSetPending = false
        }
        if(allColorChangePending) {
            CS.setSystemDefaultColors(nextColorScheme)
            allColorChangePending = false
        }
        if(fftTableRelativePending) {
            GC.setShowFftTableAsRelative(nextFftTableRelative)
            fftTableRelativePending = false
        }
        if(fftShowAnglesPending) {
            GC.setShowFftTableAngle(nextFftShowAngles)
            fftShowAnglesPending = false
        }
        if(digitsTotalPending) {
            GC.setDigitsTotal(nextDigitsTotal)
            digitsTotalPending = false
        }
        if(decimalPlacesPending) {
            GC.setDecimalPlaces(nextDecimalPlaces)
            decimalPlacesPending = false
        }
    }
    onTriggered: {
        applyPendingChanges()
    }
    Component.onDestruction: {
        applyPendingChanges()
    }
}
