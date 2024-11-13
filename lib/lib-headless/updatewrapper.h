#ifndef UPDATEWRAPPER_H
#define UPDATEWRAPPER_H

#include <taskcontainerinterface.h>
#include <QObject>

class UpdateWrapper : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE void startInstallation();
    QString searchForPackages(QString mountPath);
    QStringList getOrderedPackageList(QString zupLocation);
private:
    QString m_pathToZups;
    QStringList m_zupsToBeInstalled;
    std::unique_ptr<TaskContainerInterface> m_tasks;
signals:

};

#endif // UPDATEWRAPPER_H
