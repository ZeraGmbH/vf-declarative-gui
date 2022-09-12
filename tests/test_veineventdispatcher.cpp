#include "test_veineventdispatcher.h"
#include "veinconsumermock.h"
#include "vfeventdispatcher.h"

static constexpr int entityId = 2;
static const char *componentName = "fooComponentName";

void test_veineventdispatcher::init()
{
    _init();
    addEntityComponent(entityId, componentName);
}

void test_veineventdispatcher::cleanup()
{
    _cleanup();
}

void test_veineventdispatcher::zeroEvents()
{
    std::shared_ptr<VeinConsumerMock> mock = std::make_shared<VeinConsumerMock>();
    VfEventDispatcher dispatcher(mock);
    m_vfEventHandler->addSubsystem(&dispatcher);

    QCoreApplication::processEvents();
    QCOMPARE(mock->getComponentChangeList().count(), 0);
}

void test_veineventdispatcher::oneEvent()
{
    std::shared_ptr<VeinConsumerMock> mock = std::make_shared<VeinConsumerMock>();
    VfEventDispatcher dispatcher(mock);
    m_vfEventHandler->addSubsystem(&dispatcher);

    m_vfComponentData->setValue(entityId, componentName, QVariant(1));
    QCoreApplication::processEvents();
    QCOMPARE(mock->getComponentChangeList().count(), 1);
}

void test_veineventdispatcher::twoEvents()
{
    std::shared_ptr<VeinConsumerMock> mock = std::make_shared<VeinConsumerMock>();
    VfEventDispatcher dispatcher(mock);
    m_vfEventHandler->addSubsystem(&dispatcher);

    m_vfComponentData->setValue(entityId, componentName, QVariant(1));
    m_vfComponentData->setValue(entityId, componentName, QVariant(2));
    QCoreApplication::processEvents();
    QCOMPARE(mock->getComponentChangeList().count(), 2);
}

void test_veineventdispatcher::twoEventsTwoEntities()
{
    addEntityComponent(entityId+1, componentName);
    QCoreApplication::processEvents();

    std::shared_ptr<VeinConsumerMock> mock = std::make_shared<VeinConsumerMock>();
    VfEventDispatcher dispatcher(mock);
    m_vfEventHandler->addSubsystem(&dispatcher);

    m_vfComponentData->setValue(entityId, componentName, QVariant(1));
    m_vfComponentData->setValue(entityId+1, componentName, QVariant(1));
    QCoreApplication::processEvents();
    QCOMPARE(mock->getComponentChangeList().count(), 2);
}

void test_veineventdispatcher::twoEventsTwoComponents()
{
    addEntityComponent(entityId, "bar");
    QCoreApplication::processEvents();

    std::shared_ptr<VeinConsumerMock> mock = std::make_shared<VeinConsumerMock>();
    VfEventDispatcher dispatcher(mock);
    m_vfEventHandler->addSubsystem(&dispatcher);

    m_vfComponentData->setValue(entityId, componentName, QVariant(1));
    m_vfComponentData->setValue(entityId, "bar", QVariant(1));
    QCoreApplication::processEvents();
    QCOMPARE(mock->getComponentChangeList().count(), 2);
}

QTEST_MAIN(test_veineventdispatcher)

