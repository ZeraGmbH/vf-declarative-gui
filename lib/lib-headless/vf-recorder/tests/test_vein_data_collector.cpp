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
    m_dataCollector = std::make_unique<VeinDataCollector>(m_server->getStorage());
}

void test_vein_data_collector::cleanup()
{
    m_dataCollector = nullptr;
    m_server = nullptr;
    TimeMachineObject::feedEventLoop();
}

void test_vein_data_collector::oneTimestampOneEntityOneComponentChange()
{
    QSignalSpy spy(m_dataCollector.get(), &VeinDataCollector::newValueCollected);
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_dataCollector->startLogging(m_collectorComponents);

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();

    QCOMPARE(spy.count(), 1);

    QFile file(":/oneTimestampOneEntityOneComponentChange.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getLatestJsonObject());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
    QCOMPARE(m_dataCollector->getFirstTimeStamp(), msAfterEpoch(0));
}

void test_vein_data_collector::oneTimestampOneEntityOneComponentChangesTwice()
{
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_dataCollector->startLogging(m_collectorComponents);

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    TimeMachineForTest::getInstance()->processTimers(50);
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "bar");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();

    QFile file(":/oneTimestampOneEntityOneComponentChangesTwice.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getLatestJsonObject());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
    QCOMPARE(m_dataCollector->getFirstTimeStamp(), msAfterEpoch(50));
}

void test_vein_data_collector::twoTimestampsOneEntityOneComponentChange()
{
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_dataCollector->startLogging(m_collectorComponents);

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();
    QJsonObject storedValues = m_dataCollector->getLatestJsonObject();
    QString timeStamp = storedValues.keys().first();
    QCOMPARE(timeStamp, msAfterEpoch(0));
    QCOMPARE(getComponentValue(storedValues, entityId1, "ComponentName1"), "foo");

    TimeMachineForTest::getInstance()->processTimers(500);

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "bar");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();
    storedValues = m_dataCollector->getLatestJsonObject();
    timeStamp = storedValues.keys().first();
    QCOMPARE(timeStamp, msAfterEpoch(500));
    QCOMPARE(getComponentValue(storedValues, entityId1, "ComponentName1"), "bar");

    QCOMPARE(m_dataCollector->getFirstTimeStamp(), msAfterEpoch(0));
}

void test_vein_data_collector::oneTimestampTwoEntitiesOneComponentChange()
{
    QSignalSpy spy(m_dataCollector.get(), &VeinDataCollector::newValueCollected);
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_collectorComponents[entityId2] = QStringList() << "ComponentName2";
    m_dataCollector->startLogging(m_collectorComponents);

    //set initial values
    m_server->setComponentServerNotification(entityId1, "ComponentName1", "init");
    m_server->setComponentServerNotification(entityId2, "ComponentName2", "init");
    TimeMachineObject::feedEventLoop();

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(spy.count(), 1);

    QFile file(":/oneTimestampTwoEntitiesOneComponentChange.json");
    QVERIFY(file.open(QFile::ReadOnly));
    QByteArray jsonExpected = file.readAll();
    QByteArray jsonDumped = TestLogHelpers::dump(m_dataCollector->getLatestJsonObject());
    QVERIFY(TestLogHelpers::compareAndLogOnDiff(jsonExpected, jsonDumped));
}

void test_vein_data_collector::twoTimestampsTwoEntitiesTwoComponentChange()
{
    m_collectorComponents[entityId1] = QStringList() << "ComponentName1";
    m_collectorComponents[entityId2] = QStringList() << "ComponentName2";
    m_dataCollector->startLogging(m_collectorComponents);

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "foo");
    m_server->setComponentServerNotification(entityId2, "ComponentName2", "bar");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();
    QJsonObject storedValues = m_dataCollector->getLatestJsonObject();
    QString timeStamp = storedValues.keys().first();
    QCOMPARE(timeStamp, msAfterEpoch(0));
    QCOMPARE(getComponentValue(storedValues, entityId1, "ComponentName1"), "foo");
    QCOMPARE(getComponentValue(storedValues, entityId2, "ComponentName2"), "bar");

    TimeMachineForTest::getInstance()->processTimers(500);

    m_server->setComponentServerNotification(entityId1, "ComponentName1", "abc");
    m_server->setComponentServerNotification(entityId2, "ComponentName2", "pqs");
    triggerSIGMeasuring();
    TimeMachineObject::feedEventLoop();
    storedValues = m_dataCollector->getLatestJsonObject();
    timeStamp = storedValues.keys().first();
    QCOMPARE(timeStamp, msAfterEpoch(500));
    QCOMPARE(getComponentValue(storedValues, entityId1, "ComponentName1"), "abc");
    QCOMPARE(getComponentValue(storedValues, entityId2, "ComponentName2"), "pqs");
}

void test_vein_data_collector::setupServer()
{
    m_server = std::make_unique<TestVeinServer>();
    m_server->addEntity(sigMeasuringEntityId, "DFT");
    m_server->addComponent(sigMeasuringEntityId, "SIG_Measuring", QVariant(1), false);
    m_server->addTestEntities(3, 3);
    TimeMachineObject::feedEventLoop();
    m_server->simulAllModulesLoaded("test-session1.json", QStringList() << "test-session1.json" << "test-session2.json");
}

void test_vein_data_collector::triggerSIGMeasuring()
{
    m_server->setComponentServerNotification(sigMeasuringEntityId, "SIG_Measuring", QVariant(0));
    m_server->setComponentServerNotification(sigMeasuringEntityId, "SIG_Measuring", QVariant(1));
}

QString test_vein_data_collector::getComponentValue(QJsonObject storedJson, int entity, QString componentName)
{
    QString entityStr = QString::number(entity);
    QJsonObject entityComponentInfo = storedJson.value(storedJson.keys().first()).toObject();
    return entityComponentInfo.value(entityStr).toObject().value(componentName).toString();
}

QString test_vein_data_collector::msAfterEpoch(qint64 msecs)
{
    QDateTime dateTime;
    dateTime.setMSecsSinceEpoch(msecs);
    return dateTime.toUTC().toString("dd-MM-yyyy hh:mm:ss.zzz");
}
