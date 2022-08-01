#ifndef ZeraGlueLogic_H
#define ZeraGlueLogic_H

#include <ve_eventsystem.h>
#include <zeratranslation.h>
#include "gluelogicpropertymap.h"
class ZeraGlueLogicPrivate;

namespace CommonTable
{
enum RoleIndexes
{
    NAME=Qt::UserRole,
    L1,
    L2,
    L3,
    AUX=Qt::UserRole+500,
    SUM=Qt::UserRole+1000,
    UNIT=Qt::UserRole+1001,
};
}

class ZeraGlueLogic : public VeinEvent::EventSystem
{
    Q_OBJECT
public:
    explicit ZeraGlueLogic(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent=nullptr);
    ~ZeraGlueLogic() override;
public:
    bool processEvent(QEvent *t_event) override;
private:
    ZeraGlueLogicPrivate *m_dPtr;
};

#endif // ZeraGlueLogic_H
