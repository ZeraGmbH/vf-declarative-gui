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
  QmlFileIO(QObject *t_parent=0);

  Q_PROPERTY(QStringList mountedPaths READ mountedPaths NOTIFY sigMountedPathsChanged);

  Q_INVOKABLE QString readTextFile(const QString& t_fileName);
  Q_INVOKABLE bool writeTextFile(const QString& t_fileName, const QString &t_content, bool t_overwrite = false, bool t_truncate = true);
  Q_INVOKABLE QVariant readJsonFile(const QString& t_fileName);
  Q_INVOKABLE bool writeJsonFile(const QString& t_fileName, const QVariant &t_content, bool t_overwrite = false);
  Q_INVOKABLE bool storeJournalctlOnUsb();

  static QObject *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);

  static void setStaticInstance(QmlFileIO *t_instance);

  const QStringList &mountedPaths() const;

signals:
  void sigMountedPathsChanged();

private slots:
  void onMountPathsChanged(QStringList mountPaths);

private:
  bool checkFile(const QFile &t_file);

  vfFiles::MountWatcherEntryBase m_mountWatcher;
  QStringList m_mountedPaths;
  static QmlFileIO *s_instance;
};

#endif // QMLFILEIO_H
