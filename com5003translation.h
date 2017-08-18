#ifndef COM5003TRANSLATION_H
#define COM5003TRANSLATION_H

#include <QQmlPropertyMap>
#include <QTranslator>
QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

/**
 * @brief The Com5003Translation class
 * @todo add search path variable for .ts files: /usr/share/vf-gui-com5003/translations as default ?
 */
class Com5003Translation : public QQmlPropertyMap
{
  Q_OBJECT
public:
  explicit Com5003Translation(QObject *parent = 0);

  static void setStaticInstance(Com5003Translation *t_instance);

  static QObject *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);

  Q_INVOKABLE void changeLanguage(const QString &t_language);

signals:

public slots:

private:
  void reloadStringTable();


  static Com5003Translation *s_instance;

  QString m_currentLanguage;
  QTranslator m_translator;

  // QQmlPropertyMap interface
protected:
  QVariant updateValue(const QString &key, const QVariant &input) override;
};

#endif // COM5003TRANSLATION_H
