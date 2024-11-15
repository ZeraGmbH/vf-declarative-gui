#ifndef UPDATEWRAPPER_H
#define UPDATEWRAPPER_H

#include <taskcontainerinterface.h>
#include <QObject>

class UpdateWrapper : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(bool updateOk READ getUpdateOk NOTIFY sigUpdateOkChanged);
    Q_PROPERTY(QString updateMessage READ getUpdateMessage NOTIFY sigUpdateMessageChanged);
    Q_INVOKABLE void startInstallation();
    QString searchForPackages(QString mountPath);
    QStringList getOrderedPackageList(QString zupLocation);
    bool getUpdateOk() const;
    QString getUpdateMessage() const;
private:
    QString m_pathToZups;
    QStringList m_zupsToBeInstalled;
    std::unique_ptr<TaskContainerInterface> m_tasks;
    bool m_updateOk;
    QString m_updateMessage;
signals:
    void sigUpdateOkChanged();
    void sigUpdateMessageChanged();
private slots:
    void onTaskFinished(bool ok, int taskId);
};

#endif // UPDATEWRAPPER_H
