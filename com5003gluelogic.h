#ifndef COM5003GLUELOGIC_H
#define COM5003GLUELOGIC_H

#include <ve_eventsystem.h>

class QStandardItemModel;
class Com5003GlueLogicPrivate;
class GlueLogicPropertyMap;

class Com5003GlueLogic : public VeinEvent::EventSystem
{
  Q_OBJECT
public:
  explicit Com5003GlueLogic(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent=0);
  ~Com5003GlueLogic();

  // EventSystem interface
public:
  bool processEvent(QEvent *t_event) override;
private:
  Com5003GlueLogicPrivate *d_ptr;
};

#endif // COM5003GLUELOGIC_H
