#include "test_vf_recorder.h"
#include "vf-cpp-entity.h"
#include "vf_client_component_setter.h"
#include <timemachineobject.h>
#include <timemachinefortest.h>
#include <timerfactoryqtfortest.h>
#include <QTest>
#include <QJsonDocument>

QTEST_MAIN(test_vf_recorder)

static constexpr int rmsEntityId = 1040;
static constexpr int powerEntityId = 1070;
static constexpr int maximumStorage = 5;
static constexpr int storageNum = 0;

void test_vf_recorder::initTestCase()
{
    TimerFactoryQtForTest::enableTest();
}

void test_vf_recorder::init()
{
    m_eventHandler = std::make_unique<VeinEvent::EventHandler>();
    m_storageEventSystem = std::make_shared<VeinStorage::StorageEventSystem>();
    Vf_Recorder::setStorageSystem(m_storageEventSystem.get());
    m_recorder = std::make_unique<Vf_Recorder>();

    m_eventHandler->addSubsystem(m_storageEventSystem.get());
    TimeMachineObject::feedEventLoop();
    TimeMachineForTest::reset();
}

void test_vf_recorder::cleanup()
{
    m_eventHandler = nullptr;
    m_recorder = nullptr;
    m_storageEventSystem = nullptr;
    TimeMachineObject::feedEventLoop();
}

void test_vf_recorder::storeValuesBasedOnNoEntitiesInJson()
{
    for(int i = 0; i < maximumStorage; i++) {
        m_recorder->startLogging(i, QJsonObject());
        TimeMachineForTest::getInstance()->processTimers(100);
        QVERIFY(m_recorder->getLatestStoredValues(i).isEmpty());
    }
}

void test_vf_recorder::storeValuesBasedOnNonexistingEntitiesInJson()
{
    QVariantMap components = {{"SIG_Measuring", QVariant(1)}};
    createModule(sigMeasuringEntityId, components);
    startLoggingFromJson(":/incorrect-entities.json", storageNum);
    TimeMachineForTest::getInstance()->processTimers(100);
    QVERIFY(m_recorder->getLatestStoredValues(storageNum).isEmpty());
}

void test_vf_recorder::storeValuesEmptyComponentsInJson()
{
    QVariantMap components = {{"ACT_RMSPN1", QVariant()}, {"ACT_RMSPN2", QVariant()}, {"PAR_Interval", QVariant()}};
    createModule(rmsEntityId, components);
    components = {{"SIG_Measuring", QVariant(1)}};
    createModule(sigMeasuringEntityId, components);
    QList<int> entities = m_storageEventSystem->getDb()->getEntityList();
    QVERIFY(entities.contains(rmsEntityId));
    QVERIFY(entities.contains(sigMeasuringEntityId));

    startLoggingFromJson(":/empty-components.json", storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 1);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 2);
    changeComponentValue(rmsEntityId, "PAR_Interval", 5);
    triggerRangeModuleSigMeasuring();

    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));

    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QString value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "1");
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "2");
    value = getValuesStoredOfComponent(componentsHash, "PAR_Interval");
    QCOMPARE(value, "5");
}

void test_vf_recorder::doNotStoreSigMeasuringNotAvailable()
{
    QVariantMap components = {{"ACT_RMSPN1", QVariant()}, {"ACT_RMSPN2", QVariant()}};
    createModule(rmsEntityId, components);
    startLoggingFromJson(":/empty-components.json", storageNum);

    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 1);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 2);
    TimeMachineForTest::getInstance()->processTimers(100);

    QVERIFY(getStoredValueWithoutTimeStamp(storageNum).isEmpty());
}

void test_vf_recorder::loggingOnOffSequence0()
{
    createMinimalRangeRmsModules();

    startLoggingFromJson(":/correct-entities.json", storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    triggerRangeModuleSigMeasuring();
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));

    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QString value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "3");
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "4");

    stopLogging(storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 7);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 8);
    triggerRangeModuleSigMeasuring();
    TimeMachineForTest::getInstance()->processTimers(100);

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);

    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "3");  // !=7
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "4");  // !=8
}

void test_vf_recorder::loggingOnOffSequence1()
{
    constexpr int storageNum = 1;
    createMinimalRangeRmsModules();

    startLoggingFromJson(":/correct-entities.json", storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    triggerRangeModuleSigMeasuring();
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));

    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QString value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "3");
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "4");

    stopLogging(storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 7);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 8);
    triggerRangeModuleSigMeasuring();
    TimeMachineForTest::getInstance()->processTimers(100);

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);

    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "3");  // !=7
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "4");  // !=8
}

void test_vf_recorder::stopLoggingHasNoSideEffectOnOtherConnections()
{
    createMinimalRangeRmsModules();
    startLoggingFromJson(":/correct-entities.json", storageNum);

    int changesDetected = 0;
    VeinStorage::AbstractDatabase *storageDb = m_storageEventSystem->getDb();
    VeinStorage::AbstractComponentPtr component = storageDb->findComponent(rmsEntityId, "ACT_RMSPN1");
    connect(component.get(), &VeinStorage::AbstractComponent::sigValueChange, [&]() {
        changesDetected++;
    });
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 39);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 42);
    QCOMPARE(changesDetected, 1);

    stopLogging(storageNum);

    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 42);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 39);
    QCOMPARE(changesDetected, 2);
}

void test_vf_recorder::fireActualValuesAfterDelayWhileLogging()
{
    createMinimalRangeRmsModules();
    startLoggingFromJson(":/correct-entities.json", 0);

    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    triggerRangeModuleSigMeasuring();
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValues = m_recorder->getLatestStoredValues(storageNum);
    QDateTime firstTimeStamp = QDateTime::fromString(storedValues.keys().first() , "dd-MM-yyyy hh:mm:ss.zzz");
    QCOMPARE (storedValues.size(), 1);

    TimeMachineForTest::getInstance()->processTimers(5000);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 5);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 6);
    triggerRangeModuleSigMeasuring();
    TimeMachineForTest::getInstance()->processTimers(100);

    storedValues = m_recorder->getLatestStoredValues(storageNum);
    QDateTime lastTimeStamp = QDateTime::fromString(storedValues.keys().first() , "dd-MM-yyyy hh:mm:ss.zzz");
    QCOMPARE (storedValues.size(), 1);

    QVERIFY(firstTimeStamp < lastTimeStamp);
}

void test_vf_recorder::fireRmsPowerValuesAfterDifferentDelaysWhileLogging()
{
    createMinimalRangeRmsModules();
    QVariantMap components = {{"ACT_PQS1", QVariant()}, {"ACT_PQS2", QVariant()}};
    createModule(powerEntityId, components);
    startLoggingFromJson(":/rms-power1-components.json", 0);

    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 1);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 2);
    changeComponentValue(powerEntityId, "ACT_PQS1", 1);
    changeComponentValue(powerEntityId, "ACT_PQS2", 2);
    triggerRangeModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();

    QJsonObject storedValues = m_recorder->getLatestStoredValues(storageNum);
    QString firstTimeStamp = storedValues.keys().first();
    QCOMPARE(firstTimeStamp, msAfterEpoch(0)); //0ms elapsed before triggerRangeModuleSigMeasuring

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(powerEntityId)));
    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1"), "1");
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2"), "2");
    componentsHash = getComponentsStoredOfEntity(powerEntityId, storedValuesWithoutTimeStamp);
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_PQS1"), "1");
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_PQS2"), "2");

    TimeMachineForTest::getInstance()->processTimers(500);

    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    triggerRangeModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();

    storedValues = m_recorder->getLatestStoredValues(storageNum);
    QString secondTimeStamp = storedValues.keys().first();
    QCOMPARE(secondTimeStamp, msAfterEpoch(500)); //500ms elapsed before triggerRangeModuleSigMeasuring

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(powerEntityId)));
    componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1"), "3");
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2"), "4");
    componentsHash = getComponentsStoredOfEntity(powerEntityId, storedValuesWithoutTimeStamp);
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_PQS1"), "1");
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_PQS2"), "2");

    TimeMachineForTest::getInstance()->processTimers(500);

    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 5);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 6);
    changeComponentValue(powerEntityId, "ACT_PQS1", 5);
    triggerRangeModuleSigMeasuring();
    TimeMachineObject::feedEventLoop();
    TimeMachineForTest::getInstance()->processTimers(10);
    changeComponentValue(powerEntityId, "ACT_PQS2", 6);

    TimeMachineForTest::getInstance()->processTimers(100);

    storedValues = m_recorder->getLatestStoredValues(storageNum);
    QString thirdTimeStamp = storedValues.keys().first();
    QCOMPARE(thirdTimeStamp, msAfterEpoch(500 + 500)); //500ms + 500ms elapsed before triggerRangeModuleSigMeasuring

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(powerEntityId)));
    componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1"), "5");
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2"), "6");
    componentsHash = getComponentsStoredOfEntity(powerEntityId, storedValuesWithoutTimeStamp);
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_PQS1"), "5");
    QCOMPARE(getValuesStoredOfComponent(componentsHash, "ACT_PQS2"), "2");
}

void test_vf_recorder::createMinimalRangeRmsModules()
{
    QVariantMap components = {{"ACT_RMSPN1", QVariant()}, {"ACT_RMSPN2", QVariant()}};
    createModule(rmsEntityId, components);
    components = {{"SIG_Measuring", QVariant(1)}};
    createModule(sigMeasuringEntityId, components);
}

void test_vf_recorder::changeComponentValue(int entityId, QString componentName, QVariant newValue)
{
    QVariant oldValue = m_storageEventSystem->getDb()->getStoredValue(entityId, componentName);
    QEvent* event = VfClientComponentSetter::generateEvent(entityId, componentName, oldValue, newValue);
    emit m_storageEventSystem->sigSendEvent(event); // could be any event system
    TimeMachineObject::feedEventLoop();
}

void test_vf_recorder::createModule(int entityId, QMap<QString, QVariant> components)
{
    VfCpp::VfCppEntity * entity =new VfCpp::VfCppEntity(entityId);
    m_eventHandler->addSubsystem(entity);
    entity->initModule();
    for(auto compoName : components.keys())
        entity->createComponent(compoName, components[compoName]);
    TimeMachineObject::feedEventLoop();
}

void test_vf_recorder::triggerRangeModuleSigMeasuring()
{
    //"SIG_Measuring" changes from 0 to 1 when new actual values are available
    changeComponentValue(sigMeasuringEntityId, "SIG_Measuring", QVariant(0));
    changeComponentValue(sigMeasuringEntityId, "SIG_Measuring", QVariant(1));
}

QJsonObject test_vf_recorder::readEntitiesAndCompoFromJsonFile(QString filePath)
{
    QFile file(filePath);
    file.open(QIODevice::ReadOnly);
    return QJsonDocument::fromJson(file.readAll()).object();
}

void test_vf_recorder::startLoggingFromJson(QString fileName, int storageNum)
{
    QJsonObject fileContent = readEntitiesAndCompoFromJsonFile(fileName);
    m_recorder->startLogging(storageNum, fileContent);
}

void test_vf_recorder::stopLogging(int storageNum)
{
    m_recorder->stopLogging(storageNum);
}

QJsonObject test_vf_recorder::getStoredValueWithoutTimeStamp(int storageNum)
{
    QJsonObject storedValuesWithoutTimeStamp;
    QJsonObject storedValues = m_recorder->getLatestStoredValues(storageNum);
    for(const QString &key : storedValues.keys()) {
        QJsonValue entityFound = storedValues.value(key);
        storedValuesWithoutTimeStamp = entityFound.toObject();
    }
    return storedValuesWithoutTimeStamp;
}

QHash<QString, QVariant> test_vf_recorder::getComponentsStoredOfEntity(int entityId, QJsonObject storedValueWithoutTimeStamp)
{
    QVariant componentStored = storedValueWithoutTimeStamp.value(QString::number(entityId)).toVariant();
    return componentStored.toHash();
}

QString test_vf_recorder::getValuesStoredOfComponent(QHash<QString, QVariant> componentHash, QString componentName)
{
    QVariant value = componentHash.value(componentName);
    return value.toString();
}

QString test_vf_recorder::msAfterEpoch(qint64 msecs)
{
    QDateTime dateTime;
    dateTime.setMSecsSinceEpoch(msecs);
    return dateTime.toUTC().toString("dd-MM-yyyy hh:mm:ss.zzz");
}

