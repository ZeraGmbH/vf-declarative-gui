#ifndef QMLFILEIO_H
#define QMLFILEIO_H

#include "mountwatcherentrybase.h"
#include <simplecmdioclient.h>
#include <QObject>
#include <QVariant>
#include <QString>
#include <memory>

class QmlFileIO : public QObject
{
    Q_OBJECT
public:
    QmlFileIO(QObject *parent=0);
    static QmlFileIO *getInstance();

    Q_PROPERTY(QStringList mountedPaths READ mountedPaths NOTIFY sigMountedPathsChanged);

    Q_PROPERTY(bool writingLogsToUsb READ getWritingLogsToUsb NOTIFY sigWritingLogsToUsbChanged);
    Q_PROPERTY(bool lastWriteLogsOk READ getLastWriteLogsOk NOTIFY sigLastWriteLogsOkChanged);
    Q_INVOKABLE bool startWriteJournalctlOnUsb(QVariant versionMap, QString serverIp);

    Q_INVOKABLE bool fileExists(const QString& fileName);
    Q_INVOKABLE QString readTextFile(const QString& fileName);
    Q_INVOKABLE bool writeTextFile(const QString& fileName, const QString &content, bool overwrite = false, bool truncate = true);
    Q_INVOKABLE QVariant readJsonFile(const QString& fileName);
    Q_INVOKABLE bool writeJsonFile(const QString& fileName, const QVariant &content, bool overwrite = false);

    const QStringList &mountedPaths() const;
    bool getWritingLogsToUsb() const;
    bool getLastWriteLogsOk() const;

signals:
    void sigMountedPathsChanged();
    void sigWritingLogsToUsbChanged();
    void sigLastWriteLogsOkChanged();

private slots:
    void onMountPathsChanged(QStringList mountPaths);
    void onSimpleCmdFinish(bool ok);

private:
    bool checkFile(const QFile &file);

    vfFiles::MountWatcherEntryBase m_mountWatcher;
    QStringList m_mountedPaths;
    bool m_writingLogsToUsb = false;
    bool m_lastWriteLogsOk = false;
    std::unique_ptr<SimpleCmdIoClient> m_simpleCmdIoClient;
    static QmlFileIO *s_instance;
};

#endif // QMLFILEIO_H
