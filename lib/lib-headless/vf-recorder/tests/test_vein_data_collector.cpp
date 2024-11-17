#include "test_vein_data_collector.h"
#include <timemachineobject.h>
#include <timemachinefortest.h>
#include <timerfactoryqtfortest.h>
#include <testloghelpers.h>
#include <QSignalSpy>
#include <QTest>

QTEST_MAIN(test_vein_data_collector)

static constexpr int entityId1 = 10;
static constexpr int entityId2 = 11;


void test_vein_data_collector::initTestCase()
{
    TimerFactoryQtForTest::enableTest();
}

void test_vein_data_collector::init()
{
    TimeMachineForTest::reset();
    setupServer();
    m_timeStamper = VeinStorage::TimeStamperSettable::create();
    m_dataCollector = std::make_unique<VeinDataCollector>(m_server->getStorage(), m_timeStamper);
}

void test_vein_data_collector::cleanup()
{
    m_timeStamper = nullptr;
    m_dataCollector = nullptr;
    m_server = nullptr;
    TimeMachineObject::feedEventLoop();
}

void test_vein_data_collector::oneTimestampOneEntityOneComponentChange()
{
    QSignalSpy spy(m_dataCollector.get(), &VeinDataCollector::newStoredValue);
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_dataCollector->startLogging(m_collectorComponents);

    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    TimeMachineObject::feedEventLoop();

    QCOMPARE(spy.count(), 1);

    QFile file(":/oneTimestampOneEntityOneComponent.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getLastStoredValues());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
}

void test_vein_data_collector::oneTimestampOneEntityOneComponentChangesTwice()
{
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_dataCollector->startLogging(m_collectorComponents);

    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    TimeMachineForTest::getInstance()->processTimers(50);
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "bar");
    TimeMachineObject::feedEventLoop();

    QFile file(":/oneTimestampOneEntityOneComponentChangesTwice.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getLastStoredValues());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
}

void test_vein_data_collector::twoTimestampsOneEntityOneComponentChange()
{
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_dataCollector->startLogging(m_collectorComponents);

    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    TimeMachineForTest::getInstance()->processTimers(500);
    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "bar");
    TimeMachineObject::feedEventLoop();

    QFile file(":/twoTimestampsOneEntityOneComponent.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getStoredValues());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
}

void test_vein_data_collector::oneTimestampTwoEntitiesOneComponentChange()
{
    QSignalSpy spy(m_dataCollector.get(), &VeinDataCollector::newStoredValue);
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_collectorComponents[entityId2] = QStringList() << "ComponentName2";
    m_dataCollector->startLogging(m_collectorComponents);

    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    TimeMachineForTest::getInstance()->processTimers(5000);
    QCOMPARE(spy.count(), 0);

    m_server->setComponentServerNotification(entityId2, "ComponentName2", "bar");
    TimeMachineObject::feedEventLoop();
    QCOMPARE(spy.count(), 1);

    QFile file(":/oneTimestampTwoEntitiesOneComponent.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getLastStoredValues());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
}

void test_vein_data_collector::twoTimestampsTwoEntitiesOneComponentChange()
{
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_collectorComponents[entityId2] = QStringList() << "ComponentName2";
    m_dataCollector->startLogging(m_collectorComponents);

    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    TimeMachineForTest::getInstance()->processTimers(50);
    m_server->setComponentServerNotification(entityId2, "ComponentName2", "bar");

    TimeMachineForTest::getInstance()->processTimers(500);

    m_timeStamper->setTimestampToNow();
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "abc");
    TimeMachineForTest::getInstance()->processTimers(50);
    m_server->setComponentServerNotification(entityId2, "ComponentName2", "pqs");

    QFile file(":/twoTimestampsTwoEntitiesOneComponent.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getStoredValues());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
}

void test_vein_data_collector::setupServer()
{
    m_server = std::make_unique<TestVeinServer>();
    m_server->addTestEntities(3, 3);
    TimeMachineObject::feedEventLoop();
    m_server->simulAllModulesLoaded("test-session1.json", QStringList() << "test-session1.json" << "test-session2.json");
}
