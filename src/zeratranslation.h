#ifndef ZeraTranslation_H
#define ZeraTranslation_H

#include <QQmlPropertyMap>
#include <QTranslator>
QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

/**
 * @brief
 * @todo add search path variable for .ts files: /usr/share/vf-gui-com5003/translations as default ?
 */
class ZeraTranslation : public QQmlPropertyMap
{
  Q_OBJECT
public:
  explicit ZeraTranslation(QObject *parent = 0);

  static void setStaticInstance(ZeraTranslation *t_instance);

  static QObject *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);

  Q_INVOKABLE void changeLanguage(const QString &t_language);

signals:

public slots:

private:
  void reloadStringTable();


  static ZeraTranslation *s_instance;

  QString m_currentLanguage;
  QTranslator m_translator;

  // QQmlPropertyMap interface
protected:
  QVariant updateValue(const QString &key, const QVariant &input) override;
};

#endif // ZeraTranslation_H
