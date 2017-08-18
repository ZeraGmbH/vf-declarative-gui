#include "gluelogicpropertymap.h"

GlueLogicPropertyMap::GlueLogicPropertyMap(QObject *t_parent) : QQmlPropertyMap(this, t_parent)
{

}

void GlueLogicPropertyMap::setStaticInstance(GlueLogicPropertyMap *t_instance)
{
  if(s_instance == nullptr)
  {
    s_instance = t_instance;
  }
}

QObject *GlueLogicPropertyMap::getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
  Q_UNUSED(t_engine);
  Q_UNUSED(t_scriptEngine);

  return s_instance;
}

QVariant GlueLogicPropertyMap::updateValue(const QString &t_key, const QVariant &t_newValue)
{
  Q_UNUSED(t_newValue);
  return value(t_key);
}


GlueLogicPropertyMap *GlueLogicPropertyMap::s_instance=nullptr;
