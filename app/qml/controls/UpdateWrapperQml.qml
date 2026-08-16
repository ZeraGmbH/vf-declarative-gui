import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import UpdateWrapper 1.0

Item {
    id: root

    function startUpdateNet() {
        waitPopup.startWait(Z.tr("Starting update..."))
        updateWrapperCpp.startUpdateNet()
    }
    function startUpdateUsb() {
        waitPopup.startWait(Z.tr("Starting update..."))
        updateWrapperCpp.startUpdateUsb()
    }

    WaitTransaction { id: waitPopup }

    UpdateWrapper { id: updateWrapperCpp }
    readonly property int installStatus: updateWrapperCpp.status
    onInstallStatusChanged: {
        if(installStatus === UpdateWrapper.PackageNotFound)
            waitPopup.stopWait([], [Z.tr("Could not update. Please check if necessary files are available.")])
        if(installStatus === UpdateWrapper.NotEnoughSpace)
            waitPopup.stopWait([], [Z.tr("Could not update. Not enough space (>400MB) available.")])
        if(installStatus === UpdateWrapper.Failure)
            waitPopup.stopWait([],[Z.tr("Update failed. Please save logs and send them to service@zera.de.")],null)
        if(installStatus === UpdateWrapper.Success)
            waitPopup.stopWait([],[],null)
    }
}
