#ifndef TABLEEVENTDISTRIBUTOR_H
#define TABLEEVENTDISTRIBUTOR_H

#include "gluelogicpropertymap.h"
#include <ve_eventsystem.h>
#include <vcmp_componentdata.h>
#include <zeratranslation.h>
#include <QPoint>
#include <QHash>

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

enum class Modules : int {
    ModeModule = 1000,
    ReferenceModule = 1001,
    RangeModule = 1020,
    SampleModule = 1030,
    RmsModule = 1040,
    DftModule = 1050,
    FftModule = 1060,
    Power1Module1 = 1070, // P
    Power1Module2 = 1071, // Q
    Power1Module3 = 1072, // S
    Power1Module4 = 1073, // P+Q+S for SCPI clients / or DC EMOB
    //Power2Module1 = 1090, // CED session
    Power3Module = 1100,
    ThdnModule1 = 1110,
    ThdnModule2 = 1111,
    OsciModule = 1120,
    Sec1Module = 1130,
    LambdaModule = 1140,
    //StatusModule = 1150,
    Burden1Module = 1160,
    Burden2Module = 1161,
    //TranformerModule = 1170,
    //AdjustmentModule = 1190,
    //ScpiModule = 9999,
};

class TableEventConsumer;

class TableEventDistributor : public VeinEvent::EventSystem
{
    Q_OBJECT
public:
    explicit TableEventDistributor(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent=nullptr);
    ~TableEventDistributor() override;
public:
    bool processEvent(QEvent *t_event) override;
private:
    TableEventConsumer *m_dPtr;
};

#endif // TABLEEVENTDISTRIBUTOR_H
