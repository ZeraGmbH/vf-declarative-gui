#include "updatewrapper.h"
#include <taskcontainersequence.h>
#include <tasklambdarunner.h>
#include <QDir>
#include <QDebug>
#include <QProcess>

void UpdateWrapper::startInstallation()
{
    qWarning() << "Start Installation of update";
    setStatus(UpdateStatus::InProgress);
    m_tasks = TaskContainerSequence::create();
    TaskTemplatePtr findCorrectMountLocation = TaskLambdaRunner::create([this]() {
        QString searchResult(searchForPackages("/media"));
        if(searchResult.isEmpty()) {
            qWarning() << "Search in /media returned empty";
            setStatus(UpdateStatus::PackageNotFound);
            return false;
        }
        else
            m_pathToZups = searchResult;
        return true;
    });
    m_tasks->addSub(std::move(findCorrectMountLocation));

    TaskTemplatePtr accquirePackageList = TaskLambdaRunner::create([this]() {
        m_zupsToBeInstalled = getOrderedPackageList(m_pathToZups);
        return true;
    });
    m_tasks->addSub(std::move(accquirePackageList));

    TaskTemplatePtr installPackagesViaClient = TaskLambdaRunner::create([this]() {
        QProcess updateClient;
        QString processOutput;
        QString updateClientExecutable("zera-update-client");
        for (auto &item : m_zupsToBeInstalled) {
            processOutput.clear();
            QStringList clientArgs;

            clientArgs << "--auto-start" << "--auto-close" << item;
            qDebug() << "starting: " << updateClientExecutable << " " << clientArgs;
            updateClient.start(updateClientExecutable, clientArgs);
            updateClient.waitForFinished(-1);
            QStringList updateLogFiles = QDir("/home/operator").entryList(QStringList("*.html"), QDir::Files, QDir::Name);
            QFile logFileOfLast("/home/operator/" + updateLogFiles.last());
            if (logFileOfLast.open(QFile::ReadOnly | QFile::Text)) {
                QTextStream in(&logFileOfLast);
                QString text = in.readAll();
                if(text.contains("returned error:") || text.contains("not started due to packages not fitting to machine"))
                    return false;
                logFileOfLast.close();
            }

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
    QStringList orderedZups = QDir(zupLocation).entryList(QStringList("*.zup"), QDir::Files);
    // remove all packages of the form wm*.zup
    for (auto &item : orderedZups)
        if (item.indexOf("wm") == 0)
            orderedZups.removeAll(item);
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

void UpdateWrapper::setUpdateOk(bool ok)
{
    m_updateOk = ok;
    emit sigUpdateOkChanged();
}

UpdateWrapper::UpdateStatus UpdateWrapper::getStatus() const
{
    return m_status;
}

void UpdateWrapper::setStatus(UpdateStatus status)
{
    m_status = status;
    emit sigStatusChanged();
}


void UpdateWrapper::onTaskFinished(bool ok, int taskId)
{
    Q_UNUSED(taskId)
    if(ok)
        setStatus(UpdateStatus::Success);
    else if(!ok && m_status == UpdateStatus::InProgress)
        setStatus(UpdateStatus::Failure);
    setUpdateOk(ok);
}
