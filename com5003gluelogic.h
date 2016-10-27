#ifndef COM5003GLUELOGIC_H
#define COM5003GLUELOGIC_H

#include <ve_eventsystem.h>

class QStandardItemModel;
class Com5003GlueLogicPrivate;

class Com5003GlueLogic : public VeinEvent::EventSystem
{
  Q_OBJECT
public:
  explicit Com5003GlueLogic(QObject *t_parent=0);
  ~Com5003GlueLogic();
  void startIntrospection();

  // EventSystem interface
public:
  bool processEvent(QEvent *t_event) override;
private:
  Com5003GlueLogicPrivate *d_ptr;
};

#endif // COM5003GLUELOGIC_H
