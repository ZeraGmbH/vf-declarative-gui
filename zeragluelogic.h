#ifndef ZeraGlueLogic_H
#define ZeraGlueLogic_H

#include <ve_eventsystem.h>

class QStandardItemModel;
class ZeraGlueLogicPrivate;
class GlueLogicPropertyMap;

class ZeraGlueLogic : public VeinEvent::EventSystem
{
  Q_OBJECT
public:
  explicit ZeraGlueLogic(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent=0);
  ~ZeraGlueLogic();

  // EventSystem interface
public:
  bool processEvent(QEvent *t_event) override;
private:
  ZeraGlueLogicPrivate *d_ptr;
};

#endif // ZeraGlueLogic_H
