#ifndef QMLFILEIO_H
#define QMLFILEIO_H

#include <QObject>
#include <QVariant>
#include <QString>
#include <QQuickItem>

class QmlFileIO : public QObject
{
  Q_OBJECT
public:
  QmlFileIO(QObject *t_parent=0);

  Q_INVOKABLE QString readTextFile(const QString& t_fileName);
  Q_INVOKABLE bool writeTextFile(const QString& t_fileName, const QString &t_content, bool t_overwrite = false, bool t_tuncate = true);
  Q_INVOKABLE QVariant readJsonFile(const QString& t_fileName);
  Q_INVOKABLE bool writeJsonFile(const QString& t_fileName, const QVariant &t_content, bool t_overwrite = false);

  static QObject *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);

  static void setStaticInstance(QmlFileIO *t_instance);

signals:

public slots:

private:
  bool checkFile(const QFile &t_file);

  static QmlFileIO *s_instance;
};

#endif // QMLFILEIO_H
