#ifndef ZeraGlueLogic_H
#define ZeraGlueLogic_H

#include <ve_eventsystem.h>

class QStandardItemModel;
class ZeraGlueLogicPrivate;
class GlueLogicPropertyMap;
class ZeraTranslation;

/**
 * @brief Glue logic / (buisness logic) handling class
 */
class ZeraGlueLogic : public VeinEvent::EventSystem
{
  Q_OBJECT
public:
  explicit ZeraGlueLogic(GlueLogicPropertyMap *t_propertyMap, ZeraTranslation *t_translation, QObject *t_parent=0);
  ~ZeraGlueLogic();

  // EventSystem interface
public:
  bool processEvent(QEvent *t_event) override;
private:
  ZeraGlueLogicPrivate *m_dPtr;
};

#endif // ZeraGlueLogic_H
