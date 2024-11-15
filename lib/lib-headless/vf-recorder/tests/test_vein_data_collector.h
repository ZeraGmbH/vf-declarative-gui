#ifndef TEST_VEIN_DATA_COLLECTOR_H
#define TEST_VEIN_DATA_COLLECTOR_H

#include "veindatacollector.h"
#include <testveinserver.h>
#include <memory>

class test_vein_data_collector : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void init();
    void cleanup();

    void oneTimestampOneEntityOneComponentChange();
    void oneTimestampOneEntityOneComponentChangesTwice();
    void twoTimestampsOneEntityOneComponentChange();
    void oneTimestampTwoEntitiesOneComponentChange();
    void twoTimestampsTwoEntitiesOneComponentChange();
private:
    void setupServer();
    std::unique_ptr<TestVeinServer> m_server;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    std::unique_ptr<VeinDataCollector> m_dataCollector;
    QHash<int, QStringList> m_collectorComponents;
};

#endif // TEST_VEIN_DATA_COLLECTOR_H
