#ifndef QMLFILEIO_H
#define QMLFILEIO_H

#include "mountwatcherentrybase.h"
#include <QObject>
#include <QVariant>
#include <QString>
#include <QQuickItem>

/**
 * @brief Currently only used to read license information
 */
class QmlFileIO : public QObject
{
    Q_OBJECT
public:
    QmlFileIO(QObject *parent=0);

    Q_PROPERTY(QStringList mountedPaths READ mountedPaths NOTIFY sigMountedPathsChanged);

    Q_INVOKABLE QString readTextFile(const QString& fileName);
    Q_INVOKABLE bool writeTextFile(const QString& fileName, const QString &content, bool overwrite = false, bool truncate = true);
    Q_INVOKABLE QVariant readJsonFile(const QString& fileName);
    Q_INVOKABLE bool writeJsonFile(const QString& fileName, const QVariant &content, bool overwrite = false);
    Q_INVOKABLE bool storeJournalctlOnUsb();

    static QObject *getStaticInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    static void setStaticInstance(QmlFileIO *instance);

    const QStringList &mountedPaths() const;

signals:
    void sigMountedPathsChanged();

private slots:
    void onMountPathsChanged(QStringList mountPaths);

private:
    bool checkFile(const QFile &file);

    vfFiles::MountWatcherEntryBase m_mountWatcher;
    QStringList m_mountedPaths;
    static QmlFileIO *s_instance;
};

#endif // QMLFILEIO_H
