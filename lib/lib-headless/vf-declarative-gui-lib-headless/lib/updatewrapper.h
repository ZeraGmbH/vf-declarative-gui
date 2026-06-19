#ifndef UPDATEWRAPPER_H
#define UPDATEWRAPPER_H

#include <taskcontainerinterface.h>
#include <QNetworkAccessManager>
#include <QObject>

class UpdateWrapper : public QObject
{
    Q_OBJECT
public:
    enum class UpdateStatus : int {
        Invalid = 0,
        InProgress = 1,
        PackageNotFound = 2,
        NotEnoughSpace = 3,
        Failure = 4,
        Success = 5
    };
    Q_ENUM(UpdateStatus)

    Q_PROPERTY(bool updateOk READ getUpdateOk NOTIFY sigUpdateOkChanged);
    Q_PROPERTY(UpdateStatus status READ getStatus NOTIFY sigStatusChanged);
    Q_PROPERTY(QString releaseVersion READ getReleaseVersion NOTIFY sigReleaseVersionChanged);
    Q_PROPERTY(QString releaseText READ getReleaseText NOTIFY sigReleaseTextChanged);

    Q_INVOKABLE void startInstallation();
    Q_INVOKABLE void updateDevice();
    Q_INVOKABLE void prepareReleaseUpdate();

    QString searchForPackages(const QString &mountPath);
    QStringList orderPackageList(const QStringList &zupList);
    QStringList removeNonMatchingLicenses(const QStringList &zupList);

    bool getUpdateOk() const;
    void setUpdateOk(bool ok);

    UpdateStatus getStatus() const;
    void setStatus(UpdateStatus status);

    QString getReleaseVersion();
    void setReleaseVersion(QString releaseVersion);
    QString getReleaseText();
    void setReleaseText(QString releaseText);
private:
    bool errorInLastLog();
    void downloadZupFile(const QString &fileName);
    void continueUpdate();

    QString m_releaseVersion;
    QString m_releaseText;
    int m_zupFilesNum = 0;
    QString m_pathToZups;
    QStringList m_zupsToBeInstalled;
    std::unique_ptr<TaskContainerInterface> m_tasks;
    bool m_updateOk;
    UpdateStatus m_status = UpdateStatus::Invalid;
    QString m_serialNumberFilePath = "/opt/zera/conf/serialnumber";
    QNetworkAccessManager m_manager;

signals:
    void sigUpdateOkChanged();
    void sigStatusChanged();
    void sigReleaseVersionChanged();
    void sigReleaseTextChanged();

private slots:
    void onTaskFinished(bool ok, int taskId);
};

#endif // UPDATEWRAPPER_H
