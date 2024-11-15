#include "updatewrapper.h"
#include <taskcontainersequence.h>
#include <tasklambdarunner.h>
#include <QDir>
#include <QDebug>
#include <QProcess>

void UpdateWrapper::startInstallation()
{
    qWarning() << "Start Installation of update";
    m_tasks = TaskContainerSequence::create();
    TaskTemplatePtr findCorrectMountLocation = TaskLambdaRunner::create([this]() {
        QString searchResult(searchForPackages("/media"));
        if(searchResult.isEmpty()) {
            qWarning() << "Search in /media returned empty";
            return false;
        }
        else
            m_pathToZups = searchResult;
        return true;
    });
    m_tasks->addSub(std::move(findCorrectMountLocation));

    TaskTemplatePtr accquirePackageList = TaskLambdaRunner::create([this]() {
        m_zupsToBeInstalled = getOrderedPackageList(m_pathToZups);
        qWarning() << "zups to be installed: " << m_zupsToBeInstalled;
        return true;
    });
    m_tasks->addSub(std::move(accquirePackageList));

    TaskTemplatePtr installPackagesViaClient = TaskLambdaRunner::create([this]() {
        QProcess updateClient;
        QString updateClientExecutable("zera-update-client");
        for (auto &item : m_zupsToBeInstalled) {
            QStringList clientArgs;
            clientArgs << item;
            qWarning() << "staring: " << updateClientExecutable << " " << clientArgs;
            updateClient.start(updateClientExecutable, clientArgs);
            updateClient.waitForFinished(-1);
            QByteArray stdOut = updateClient.readAllStandardOutput();
            if(stdOut.contains("returned error:"))
                return false;
            if(updateClient.exitStatus() == QProcess::NormalExit && updateClient.exitCode() != 0)
                return false;
        }
        return true;
    });
    m_tasks->addSub(std::move(installPackagesViaClient));

    connect(m_tasks.get(), &TaskContainerSequence::sigFinish, this, &UpdateWrapper::onTaskFinished);
    m_tasks->start();
}

QString UpdateWrapper::searchForPackages(QString mountPath)
{
    QString pathToZups;
    QFileInfoList mountedPaths = QDir(mountPath).entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (auto &item : mountedPaths) {
        QStringList filesInsideMount = QDir(item.absoluteFilePath()).entryList(QDir::Files);
        if (filesInsideMount.contains("zera-updater.zup"))
            return item.absoluteFilePath();
    }
    return pathToZups;
}

QStringList UpdateWrapper::getOrderedPackageList(QString zupLocation)
{
    QStringList orderedZups = QDir(zupLocation).entryList(QStringList("*.zup"), QDir::Files);;

    if (orderedZups.contains("zera-updater.zup"))
        orderedZups.move(orderedZups.indexOf("zera-updater.zup"), 0);

    if (orderedZups.contains("zera-image.zup"))
        orderedZups.move(orderedZups.indexOf("zera-image.zup"), orderedZups.size() - 1);

    if (orderedZups.contains("com5003-mt310s2.zup"))
        orderedZups.move(orderedZups.indexOf("com5003-mt310s2.zup"), orderedZups.size() - 1);

    for (auto &item : orderedZups)
        item = zupLocation + "/" + item;
    return orderedZups;
}

bool UpdateWrapper::getUpdateOk() const
{
    return m_updateOk;
}

QString UpdateWrapper::getUpdateMessage() const
{
    return m_updateMessage;
}

void UpdateWrapper::onTaskFinished(bool ok, int taskId)
{
    Q_UNUSED(taskId)
    m_updateOk = ok;
    if (ok)
        m_updateMessage = "Update finished successfully!";
    else
        m_updateMessage = "Update failed, please see logs!";
    emit sigUpdateOkChanged();
    emit sigUpdateMessageChanged();
}
