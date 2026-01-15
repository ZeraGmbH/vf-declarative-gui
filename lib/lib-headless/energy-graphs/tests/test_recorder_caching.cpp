#include "test_recorder_caching.h"
#include "recorderfetchandcache.h"
#include <timerfactoryqtfortest.h>
#include <timemachineobject.h>
#include <timemachinefortest.h>
#include <vf-cpp-entity.h>
#include <vf_client_rpc_invoker.h>
#include <vf_rpc_invoker.h>
#include <vs_clientstorageeventsystem.h>
#include <QSignalSpy>
#include <QTest>

QTEST_MAIN(test_recorder_caching)

static int constexpr serverPort = 4711;
constexpr int systemEntityId = 0;
constexpr int rmsEntityId = 1040;
constexpr int powerEntityId = 1070;
constexpr int recorderEntityId = 1800;
constexpr int sigMeasuringEntityId = 1050; //DftModule

void test_recorder_caching::initTestCase()
{
    TimerFactoryQtForTest::enableTest();
    TimeMachineForTest::reset();
}

void test_recorder_caching::init()
{
    setupServer();
    QVERIFY(setupClient());
    subscribeClient();
}

void test_recorder_caching::cleanup()
{
    m_clientStack = nullptr;
    TimeMachineObject::feedEventLoop();
    delete m_clientStorage;
    TimeMachineObject::feedEventLoop();
    m_testRunner = nullptr;
}

void test_recorder_caching::isServerUp()
{
    QList<int> entityList = m_testRunner->getVeinStorageSystem()->getDb()->getEntityList();
    QCOMPARE(entityList.count(), 5);
}

void test_recorder_caching::isClientUp()
{
    QVERIFY(subscribeClient());
}

void test_recorder_caching::initialIsEmpty()
{
    RecorderFetchAndCache cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
    QVERIFY(cache.getData().isEmpty());
}

void test_recorder_caching::oneValueRecorded()
{
    RecorderFetchAndCache cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();

    QCOMPARE(m_clientStorage->getDb()->getStoredValue(recorderEntityId, "ACT_Points"), 1);
    QCOMPARE(cache.getData().size(), 1);
}

void test_recorder_caching::twoValuesRecorded()
{
    RecorderFetchAndCache cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
    QSignalSpy cacheAddSpy(&cache, &RecorderFetchAndCache::sigNewValuesAdded);
    QSignalSpy cacheClearSpy(&cache, &RecorderFetchAndCache::sigClearedValues);

    startStopRecording(true);
    constexpr int delayBetween = 1000;
    for (int i=0; i<2; ++i) {
        fireActualValues();
        triggerDftModuleSigMeasuring();
        TimeMachineForTest::getInstance()->processTimers(delayBetween);
    }

    QList<RecorderFetchAndCache::TimestampData> values = cache.getData();
    QCOMPARE(values.size(), 2);
    QCOMPARE(localizedMsSinceEpoch(values[0].timeStamp), 0);
    QCOMPARE(localizedMsSinceEpoch(values[1].timeStamp), delayBetween);
    QCOMPARE(cacheAddSpy.count(), 2);
    QCOMPARE(cacheAddSpy[0][0], 0);
    QCOMPARE(cacheAddSpy[0][1], 1);
    QCOMPARE(cacheAddSpy[1][0], 1);
    QCOMPARE(cacheAddSpy[1][1], 2);
    QCOMPARE(cacheClearSpy.count(), 0);
}

void test_recorder_caching::cacheRemainsOnStop()
{
    RecorderFetchAndCache cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(cache.getData().size(), 1);

    startStopRecording(false);
    TimeMachineObject::feedEventLoop();

    QCOMPARE(cache.getData().size(), 1);
}

void test_recorder_caching::cacheClearedOnRestart()
{
    RecorderFetchAndCache cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());

    QSignalSpy cacheAddSpy(&cache, &RecorderFetchAndCache::sigNewValuesAdded);
    QSignalSpy cacheClearSpy(&cache, &RecorderFetchAndCache::sigClearedValues);

    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(cache.getData().size(), 1);

    startStopRecording(false);
    TimeMachineObject::feedEventLoop();
    startStopRecording(true);
    TimeMachineObject::feedEventLoop();

    QCOMPARE(cache.getData().size(), 0);
    QCOMPARE(cacheAddSpy.count(), 1);
    QCOMPARE(cacheAddSpy[0][0], 0);
    QCOMPARE(cacheAddSpy[0][1], 1);
    QCOMPARE(cacheClearSpy.count(), 1);
}

void test_recorder_caching::cacheClearedOnVeinSessionChange()
{
    RecorderFetchAndCache cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
    QSignalSpy cacheAddSpy(&cache, &RecorderFetchAndCache::sigNewValuesAdded);
    QSignalSpy cacheClearSpy(&cache, &RecorderFetchAndCache::sigClearedValues);

    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(cache.getData().size(), 1);

    m_testRunner->start(":/mt310s2-emob-session-dc.json");
    QCOMPARE(cache.getData().size(), 0);
}

void test_recorder_caching::setupServer()
{
    m_testRunner = std::make_unique<ModuleManagerTestRunner>(":/mt310s2-emob-session-ac.json");
    m_netSystem = std::make_unique<VeinNet::NetworkSystem>();
    m_netSystem->setOperationMode(VeinNet::NetworkSystem::VNOM_SUBSCRIPTION);
    m_tcpSystem = std::make_unique<VeinNet::TcpSystem>(VeinTcp::MockTcpNetworkFactory::create());
    ModuleManagerSetupFacade* modManFacade = m_testRunner->getModManFacade();
    modManFacade->addSubsystem(m_netSystem.get());
    modManFacade->addSubsystem(m_tcpSystem.get());

    QVariantMap components = {{"ACT_RMSPN1", QVariant()}, {"ACT_RMSPN2", QVariant()}};
    createModule(rmsEntityId, components);
    components = {{"SIG_Measuring", QVariant(1)}};
    createModule(sigMeasuringEntityId, components);
    components = {{"ACT_PQS1", QVariant()}, {"ACT_PQS2", QVariant()}};
    createModule(powerEntityId, components);

    m_tcpSystem->startServer(serverPort);
}

bool test_recorder_caching::setupClient()
{
    m_clientStack = std::make_unique<VfCoreStackClient>(VeinTcp::MockTcpNetworkFactory::create());
    m_clientStorage = new VeinStorage::ClientStorageEventSystem;
    m_clientStack->appendEventSystem(m_clientStorage);

    QSignalSpy spyConnect(m_clientStack.get(), &VfCoreStackClient::sigConnnectionEstablished);
    m_clientStack->connectToServer("127.0.0.1", serverPort);
    TimeMachineObject::feedEventLoop();
    return spyConnect.size() == 1;
}

bool test_recorder_caching::subscribeClient()
{
    QSignalSpy spySubscribe(m_clientStack.get(), &VfCoreStackClient::sigSubscribed);
    m_clientStack->subscribeEntity(systemEntityId);
    m_clientStack->subscribeEntity(rmsEntityId);
    m_clientStack->subscribeEntity(powerEntityId);
    m_clientStack->subscribeEntity(recorderEntityId);
    m_clientStack->subscribeEntity(sigMeasuringEntityId);
    TimeMachineObject::feedEventLoop();

    bool ok = spySubscribe.size() == 5 &&
              m_clientStorage->getDb()->hasEntity(systemEntityId) &&
              m_clientStorage->getDb()->hasEntity(rmsEntityId) &&
              m_clientStorage->getDb()->hasEntity(powerEntityId) &&
              m_clientStorage->getDb()->hasEntity(recorderEntityId) &&
              m_clientStorage->getDb()->hasEntity(sigMeasuringEntityId);
    return ok;
}

void test_recorder_caching::createModule(int entityId, QMap<QString, QVariant> components)
{
    VfCpp::VfCppEntity * entity =new VfCpp::VfCppEntity(entityId);
    m_testRunner->getModManFacade()->addSubsystem(entity);
    entity->initModule();
    for(const auto &compoName : components.keys())
        entity->createComponent(compoName, components[compoName]);
    TimeMachineObject::feedEventLoop();
}

void test_recorder_caching::startStopRecording(bool start)
{
    m_testRunner->setVfComponent(recorderEntityId, "PAR_StartStopRecording", start);
}

void test_recorder_caching::fireActualValues()
{
    m_testRunner->setVfComponent(rmsEntityId, "ACT_RMSPN1", 1);
    m_testRunner->setVfComponent(rmsEntityId, "ACT_RMSPN2", 2);
    m_testRunner->setVfComponent(rmsEntityId, "PAR_Interval", 5);
    m_testRunner->setVfComponent(powerEntityId, "ACT_PQS1", 1);
    m_testRunner->setVfComponent(powerEntityId, "ACT_PQS2", 2);
}

void test_recorder_caching::triggerDftModuleSigMeasuring()
{
    //"SIG_Measuring" changes from 0 to 1 when new actual values are available
    m_testRunner->setVfComponent(sigMeasuringEntityId, "SIG_Measuring", QVariant(0));
    m_testRunner->setVfComponent(sigMeasuringEntityId, "SIG_Measuring", QVariant(1));
}

qint64 test_recorder_caching::localizedMsSinceEpoch(const QDateTime &dt)
{
    // This needs to go!!!
    // see https://forum.qt.io/topic/111190/qdatetime-tomsecssinceepoch-always-treats-my-time-as-local-can-t-get-totimespec-to-work/3
    QDateTime adjusted = dt;
    adjusted.setTimeSpec(Qt::UTC);
    return adjusted.toMSecsSinceEpoch();
}
