#include "test_vein_data_collector.h"
#include "veindatacollector.h"
#include <timemachineobject.h>
#include <timemachinefortest.h>
#include <timerfactoryqtfortest.h>
#include <QSignalSpy>
#include <QTest>

QTEST_MAIN(test_vein_data_collector)

void test_vein_data_collector::initTestCase()
{
    TimerFactoryQtForTest::enableTest();
}

void test_vein_data_collector::init()
{
    setupServer();
}

void test_vein_data_collector::cleanup()
{
    m_server = nullptr;
    TimeMachineObject::feedEventLoop();
}

void test_vein_data_collector::oneChangeWithinOnePeriod()
{
    VeinStorage::TimeStamperSettablePtr timeStamper = VeinStorage::TimeStamperSettable::create();
    VeinDataCollector dataCollector(m_server->getStorage(), timeStamper);
    QSignalSpy spy(&dataCollector, &VeinDataCollector::newStoredValue);

    QHash<int, QStringList> collectorComponents;
    collectorComponents[10] = QStringList() << "ComponentName1";
    dataCollector.startLogging(collectorComponents);

    m_server->setComponentServerNotification(10, "ComponentName1", "foo");
    TimeMachineObject::feedEventLoop();

    QCOMPARE(spy.count(), 0);
    TimeMachineForTest::getInstance()->processTimers(100);
    QCOMPARE(spy.count(), 1);
    QVariant var = spy[0][0];
    QVERIFY(var.isValid());

}

void test_vein_data_collector::setupServer()
{
    m_server = std::make_unique<TestVeinServer>();

    m_server->addTestEntities(3, 3);
    TimeMachineObject::feedEventLoop();

    m_server->simulAllModulesLoaded("test-session1.json", QStringList() << "test-session1.json" << "test-session2.json");
}
