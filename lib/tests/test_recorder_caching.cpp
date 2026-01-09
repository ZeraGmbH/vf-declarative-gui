#include "test_recorder_caching.h"
#include "recordercaching.h"
#include <timerfactoryqtfortest.h>
#include <timemachineobject.h>
#include <vf-cpp-entity.h>
#include <vf_client_rpc_invoker.h>
#include <vf_rpc_invoker.h>
#include <vs_clientstorageeventsystem.h>
#include <QSignalSpy>
#include <QTest>

QTEST_MAIN(test_recorder_caching)

static int constexpr serverPort = 4711;
constexpr int rmsEntityId = 1040;
constexpr int powerEntityId = 1070;
constexpr int recorderEntityId = 1800;
constexpr int sigMeasuringEntityId = 1050; //DftModule

void test_recorder_caching::initTestCase()
{
    TimerFactoryQtForTest::enableTest();
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
    RecorderCaching cache(m_clientStorage, m_clientStack->getCmdEventHandlerSystem());
    QVERIFY(cache.getRecordedValues().isEmpty());
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
    m_clientStack->subscribeEntity(rmsEntityId);
    m_clientStack->subscribeEntity(powerEntityId);
    m_clientStack->subscribeEntity(recorderEntityId);
    m_clientStack->subscribeEntity(sigMeasuringEntityId);
    TimeMachineObject::feedEventLoop();

    bool ok = spySubscribe.size() == 4 &&
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
