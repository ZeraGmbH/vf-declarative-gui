#ifndef ZeraTranslation_H
#define ZeraTranslation_H

#include <QQmlPropertyMap>
#include <QTranslator>
QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

/**
 * @brief Translation mapper with builtin qml notifications
 */
class ZeraTranslation : public QQmlPropertyMap
{
  Q_OBJECT
public:
  explicit ZeraTranslation(QObject *parent = nullptr);

  static void setStaticInstance(ZeraTranslation *t_instance);

  static QObject *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);

  Q_INVOKABLE void changeLanguage(const QString &t_language);

signals:
  void sigLanguageChanged();

public slots:

private:
  void setupTranslationFiles();
  void reloadStringTable();

  static ZeraTranslation *s_instance;

  QString m_currentLanguage;
  QTranslator m_translator;
  //key = locale name (e.g. en_US, de_DE)
  //value = absolute path
  QHash<QString, QString> m_translationFilesModel;
  QHash<QString, QString> m_translationFlagsModel;

  // QQmlPropertyMap interface
protected:
  QVariant updateValue(const QString &key, const QVariant &input) override;
};

#endif // ZeraTranslation_H
