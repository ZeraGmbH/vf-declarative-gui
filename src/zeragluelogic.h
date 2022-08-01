#ifndef ZeraGlueLogic_H
#define ZeraGlueLogic_H

#include "gluelogicpropertymap.h"
#include <ve_eventsystem.h>
#include <zeratranslation.h>
#include <QStandardItemModel>
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

class ZeraGlueLogicItemModelBase : public QStandardItemModel
{
public:
    ZeraGlueLogicItemModelBase(int t_rows, int t_columns, QObject *t_parent);
    virtual void setupTable() = 0;
protected:
    ZeraTranslation *m_translation = nullptr;
};

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
