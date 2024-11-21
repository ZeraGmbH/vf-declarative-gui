#ifndef UPDATEWRAPPER_H
#define UPDATEWRAPPER_H

#include <taskcontainerinterface.h>
#include <QObject>

class UpdateWrapper : public QObject
{
    Q_OBJECT
public:
    enum class UpdateStatus : int {
        Invalid = 0,
        InProgress = 1,
        PackageNotFound = 2,
        Failure = 3,
        Success = 4
    };
    Q_ENUM(UpdateStatus)

    Q_PROPERTY(bool updateOk READ getUpdateOk NOTIFY sigUpdateOkChanged);
    Q_PROPERTY(UpdateStatus status READ getStatus NOTIFY sigStatusChanged);
    Q_INVOKABLE void startInstallation();
    QString searchForPackages(QString mountPath);
    QStringList orderPackageList(QStringList zupList);
    bool getUpdateOk() const;
    void setUpdateOk(bool ok);
    UpdateStatus getStatus() const;
    void setStatus(UpdateStatus status);
private:
    bool errorInLastLog();
    QString m_pathToZups;
    QStringList m_zupsToBeInstalled;
    std::unique_ptr<TaskContainerInterface> m_tasks;
    bool m_updateOk;
    UpdateStatus m_status = UpdateStatus::Invalid;
signals:
    void sigUpdateOkChanged();
    void sigStatusChanged();
private slots:
    void onTaskFinished(bool ok, int taskId);
};

#endif // UPDATEWRAPPER_H
