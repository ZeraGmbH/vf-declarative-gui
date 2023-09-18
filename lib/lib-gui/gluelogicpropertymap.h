#ifndef GLUELOGICPROPERTYMAP_H
#define GLUELOGICPROPERTYMAP_H

#include <QQmlPropertyMap>
QT_BEGIN_NAMESPACE
class QQmlEngine;
class QJSEngine;
QT_END_NAMESPACE

/**
 * @brief Glue logic data holder with QML change notification support
 */
class GlueLogicPropertyMap : public QQmlPropertyMap
{
    Q_OBJECT
public:
    GlueLogicPropertyMap(QObject *t_parent=0);
    static void setStaticInstance(GlueLogicPropertyMap *t_instance);
    static QObject *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);

protected:
    /**
   * @brief Intercepts all value changes coming from the qml side and blocks them
   * @note calling insert() can not be intercepted
   * @returns The old value is returned and no binding is updated
   */
    QVariant updateValue(const QString &t_key, const QVariant &t_newValue) override;

private:
    static GlueLogicPropertyMap *s_instance;
};

#endif // GLUELOGICPROPERTYMAP_H
