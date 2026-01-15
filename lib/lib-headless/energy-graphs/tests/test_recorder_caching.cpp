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
    if(!RecorderFetchAndCache::getInstance())
        RecorderFetchAndCache *cache = new RecorderFetchAndCache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
}

void test_recorder_caching::cleanup()
{
    m_clientStack = nullptr;
    TimeMachineObject::feedEventLoop();
    delete m_clientStorage;
    TimeMachineObject::feedEventLoop();
    m_testRunner = nullptr;
    RecorderFetchAndCache::deleteInstance();
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
    QVERIFY(RecorderFetchAndCache::getInstance()->getData().isEmpty());
}

void test_recorder_caching::oneValueRecorded()
{
    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();

    QCOMPARE(m_clientStorage->getDb()->getStoredValue(recorderEntityId, "ACT_Points"), 1);
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);
}

void test_recorder_caching::twoValuesRecorded()
{
    QSignalSpy cacheAddSpy(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigNewValuesAdded);
    QSignalSpy cacheClearSpy(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigClearedValues);

    startStopRecording(true);
    constexpr int delayBetween = 1000;
    for (int i=0; i<2; ++i) {
        fireActualValues();
        triggerDftModuleSigMeasuring();
        TimeMachineForTest::getInstance()->processTimers(delayBetween);
    }

    QList<RecorderFetchAndCache::TimestampData> values = RecorderFetchAndCache::getInstance()->getData();
    QCOMPARE(values.size(), 2);
    QCOMPARE(values[0].msSinceStart, 0);
    QCOMPARE(values[1].msSinceStart, delayBetween);
    QCOMPARE(cacheAddSpy.count(), 2);
    QCOMPARE(cacheAddSpy[0][0], 0);
    QCOMPARE(cacheAddSpy[0][1], 1);
    QCOMPARE(cacheAddSpy[1][0], 1);
    QCOMPARE(cacheAddSpy[1][1], 2);
    QCOMPARE(cacheClearSpy.count(), 0);
}

void test_recorder_caching::OneValueRecordedOnSessionChange()
{
    m_testRunner->start(":/mt310s2-emob-session-dc.json");
    QVERIFY(subscribeClient());

    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);

    // No recorder module in this session
    // We don't need to subscribe to other modules, they are created once for all
    m_testRunner->start(":/mt310s2-meas-session.json");
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 0);

    m_testRunner->start(":/mt310s2-emob-session-ac.json");
    QVERIFY(subscribeClient());

    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);
}

void test_recorder_caching::cacheRemainsOnStop()
{
    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);

    startStopRecording(false);
    TimeMachineObject::feedEventLoop();

    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);
}

void test_recorder_caching::cacheClearedOnRestart()
{
    QSignalSpy cacheAddSpy(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigNewValuesAdded);
    QSignalSpy cacheClearSpy(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigClearedValues);

    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);

    startStopRecording(false);
    TimeMachineObject::feedEventLoop();
    startStopRecording(true);
    TimeMachineObject::feedEventLoop();

    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 0);
    QCOMPARE(cacheAddSpy.count(), 1);
    QCOMPARE(cacheAddSpy[0][0], 0);
    QCOMPARE(cacheAddSpy[0][1], 1);
    QCOMPARE(cacheClearSpy.count(), 1);
}

void test_recorder_caching::cacheClearedOnVeinSessionChange()
{
    QSignalSpy cacheAddSpy(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigNewValuesAdded);
    QSignalSpy cacheClearSpy(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigClearedValues);

    startStopRecording(true);
    fireActualValues();
    triggerDftModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 1);

    m_testRunner->start(":/mt310s2-emob-session-dc.json");
    QCOMPARE(RecorderFetchAndCache::getInstance()->getData().size(), 0);
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

