#ifndef VFCOMPONENTEVENTDISPATCHER_H
#define VFCOMPONENTEVENTDISPATCHER_H

#include "vfeventconsumerinterface.h"
#include <ve_eventsystem.h>
#include <vcmp_componentdata.h>

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
    TYPE=Qt::UserRole+1002,
    LOAD_TYPE1=Qt::UserRole+1003,
    LOAD_TYPE2=Qt::UserRole+1004,
    LOAD_TYPE3=Qt::UserRole+1005,
    LOAD_TYPE_SUM=Qt::UserRole+1006,
};
}

enum class Modules : int {
    SystemModule = 0,
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
    BurdenIModule = 1160,
    BurdenUModule = 1161,
    //TranformerModule = 1170,
    //AdjustmentModule = 1190,
    //ScpiModule = 9999,
    BleModule1 = 1400
};

class VfComponentEventDispatcher : public VeinEvent::EventSystem
{
    Q_OBJECT
public:
    explicit VfComponentEventDispatcher(std::shared_ptr<VfEventConsumerInterface> consumer);
    void processEvent(QEvent *t_event) override;
private:
    std::shared_ptr<VfEventConsumerInterface> m_consumer;
};

#endif // VFCOMPONENTEVENTDISPATCHER_H
