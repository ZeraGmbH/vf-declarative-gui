#include "updatewrapper.h"
#include <taskcontainersequence.h>
#include <tasklambdarunner.h>
#include <QDir>
#include <QDebug>
#include <QProcess>
#include <QStorageInfo>

void UpdateWrapper::startInstallation()
{
    qInfo() << "Start Installation of update";
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

    TaskTemplatePtr checkAvailableSpace = TaskLambdaRunner::create([this]() {
        QStorageInfo storageInfo = QStorageInfo::root();
        int megaBytesAvailable = storageInfo.bytesAvailable()/1000/1000;
        if (megaBytesAvailable < 400) {
            qWarning() << "Not enough space available: " << megaBytesAvailable << " MB";
            setStatus(UpdateStatus::NotEnoughSpace);
            return false;
        }
        return true;
    });
    m_tasks->addSub(std::move(checkAvailableSpace));

    TaskTemplatePtr accquirePackageList = TaskLambdaRunner::create([this]() {
        QStringList unOrderedZupList = QDir(m_pathToZups).entryList(QStringList("*.zup"), QDir::Files);
        QStringList orderedZupList = orderPackageList(unOrderedZupList);
        QStringList sanitizedList = removeNonMatchingLicenses(orderedZupList);
        if(sanitizedList.empty())
            return false;
        for (auto &item : sanitizedList)
            item = m_pathToZups + "/" + item;

        m_zupsToBeInstalled = sanitizedList;
        return true;
    });
    m_tasks->addSub(std::move(accquirePackageList));

    TaskTemplatePtr installPackagesViaClient = TaskLambdaRunner::create([this]() {
        QProcess updateClient;
        QString updateClientExecutable("zera-update-client");
        for (auto &item : m_zupsToBeInstalled) {
            QStringList clientArgs;
            clientArgs << "--auto-start" << "--auto-close" << item;
            qInfo() << "starting: " << updateClientExecutable << " " << clientArgs;
            updateClient.start(updateClientExecutable, clientArgs);
            updateClient.waitForFinished(-1);
            if(errorInLastLog() ||
                (updateClient.exitStatus() == QProcess::NormalExit && updateClient.exitCode() != 0))
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

QStringList UpdateWrapper::orderPackageList(QStringList zupList)
{
    QStringList orderedZups;

    for (auto &item : zupList)
        // ignore wm packages
        if (item.startsWith("wm"))
            continue;
        else
            orderedZups.append(item);

    if (orderedZups.contains("zera-updater.zup"))
        orderedZups.move(orderedZups.indexOf("zera-updater.zup"), 0);

    if (orderedZups.contains("zera-image.zup"))
        orderedZups.move(orderedZups.indexOf("zera-image.zup"), orderedZups.size() - 1);

    if (orderedZups.contains("com5003-mt310s2.zup"))
        orderedZups.move(orderedZups.indexOf("com5003-mt310s2.zup"), orderedZups.size() - 1);

    return orderedZups;
}

QStringList UpdateWrapper::removeNonMatchingLicenses(QStringList zupList)
{
    QString serialNumber;
    QStringList returnList = zupList;
    QFile serialFile(m_serialNumberFilePath);
    if (serialFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&serialFile);
        serialNumber = in.readAll().trimmed();
        serialFile.close();
    }else{
        qWarning("Could not read serial number!");
        return QStringList();
    }

    for (auto &item : zupList)
    {
        if (item.contains("licenses") && !item.contains(serialNumber))
            returnList.removeAll(item);
    }
    return returnList;
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

bool UpdateWrapper::errorInLastLog()
{
    QStringList updateLogFiles = QDir("/home/operator").entryList(QStringList("*.html"), QDir::Files, QDir::Name);
    QFile logFileOfLast("/home/operator/" + updateLogFiles.last());
    if (logFileOfLast.open(QFile::ReadOnly | QFile::Text)) {
        QTextStream in(&logFileOfLast);
        QString text = in.readAll();
        if(text.contains("returned error:") || text.contains("not started due to packages not fitting to machine")) {
            logFileOfLast.close();
            return true;
        }
        logFileOfLast.close();
    }
    return false;
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
