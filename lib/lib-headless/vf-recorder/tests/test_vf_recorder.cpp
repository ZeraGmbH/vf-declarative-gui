#include "test_vf_recorder.h"
#include "vf_client_component_setter.h"
#include <timemachineobject.h>
#include <timemachinefortest.h>
#include <timerfactoryqtfortest.h>
#include <QTest>

QTEST_MAIN(test_vf_recorder)

static constexpr int storageEntityId = 1;
static constexpr int rangeEntityId = 1020;
static constexpr int rmsEntityId = 1040;
static constexpr int powerEntityId = 1070;
static constexpr int maximumStorage = 5;
static constexpr int storageNum = 0;

void test_vf_recorder::init()
{
    TimerFactoryQtForTest::enableTest();
    m_eventHandler = std::make_unique<VeinEvent::EventHandler>();
    m_storageEventSystem = std::make_shared<VeinStorage::StorageEventSystem>();
    m_recorder = std::make_unique<Vf_Recorder>(m_storageEventSystem.get());

    m_eventHandler->addSubsystem(m_storageEventSystem.get());
    m_eventHandler->addSubsystem(m_recorder->getVeinEntity());
    m_recorder->initOnce();
    TimeMachineObject::feedEventLoop();
}

void test_vf_recorder::cleanup()
{
    m_eventHandler = nullptr;
    m_recorder = nullptr;
    m_storageEventSystem = nullptr;
    TimeMachineObject::feedEventLoop();
}

void test_vf_recorder::componentsFound()
{
    QList<QString> storageComponents = m_storageEventSystem->getDb()->getComponentList(storageEntityId);

    QCOMPARE(storageComponents.count(), 17);
    QVERIFY(storageComponents.contains("EntityName"));
    for(int i = 0; i < maximumStorage; i++) {
        QVERIFY(storageComponents.contains(QString("StoredValues%1").arg(i)));
        QVERIFY(storageComponents.contains(QString("PAR_JsonWithEntities%1").arg(i)));
        QVERIFY(storageComponents.contains(QString("PAR_StartStopLogging%1").arg(i)));
    }
}

void test_vf_recorder::storeValuesBasedOnNoEntitiesInJson()
{
    for(int i = 0; i < maximumStorage; i++) {
        changeComponentValue(storageEntityId, QString("PAR_JsonWithEntities%1").arg(i), "");
        changeComponentValue(storageEntityId, QString("PAR_StartStopLogging%1").arg(i), "");

        QJsonObject storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, QString("StoredValues%1").arg(i)).toJsonObject();
        QVERIFY(storedValues.isEmpty());
    }
}

void test_vf_recorder::storeValuesBasedOnIncorrectEntitiesInJson()
{
    startLoggingFromJson(":/incorrect-entities.json", 0);
    QJsonObject storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();

    QVERIFY(storedValues.isEmpty());
}

void test_vf_recorder::storeValuesEmptyComponentsInJson()
{
    QVariantMap components = {{"ACT_RMSPN1", QVariant()}, {"ACT_RMSPN2", QVariant()}, {"PAR_Interval", QVariant()}};
    createModule(rmsEntityId, components);
    components = {{"SIG_Measuring", QVariant(1)}};
    createModule(rangeEntityId, components);
    QList<int> entities = m_storageEventSystem->getDb()->getEntityList();
    QVERIFY(entities.contains(rmsEntityId));
    QVERIFY(entities.contains(rangeEntityId));

    startLoggingFromJson(":/empty-components.json", storageNum);
    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 1);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 2);
    changeComponentValue(rmsEntityId, "PAR_Interval", 5);

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

void test_vf_recorder::storeValuesCorrectEntitiesStartStopLoggingDisabled()
{
    createMinimalRangeRmsModules();
    QCOMPARE(m_storageEventSystem->getDb()->getEntityList().count(), 3);

    QString fileContent = readEntitiesAndCompoFromJsonFile(":/correct-entities.json");
    changeComponentValue(storageEntityId, "PAR_JsonWithEntities0", fileContent);
    stopLogging(0);

    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 1);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 2);
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();
    QVERIFY(storedValues.isEmpty());
}

void test_vf_recorder::loggingOnOffSequence0()
{
    createMinimalRangeRmsModules();

    startLoggingFromJson(":/correct-entities.json", storageNum);
    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));

    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QString value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "3");
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "4");

    stopLogging(storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
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
    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(storageNum);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));

    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QString value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "3");
    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "4");

    stopLogging(storageNum);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
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

void test_vf_recorder::changeJsonFileWhileLogging()
{
    createMinimalRangeRmsModules();
    startLoggingFromJson(":/correct-entities.json", 0);

    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 10);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 11);
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QHash<QString, QVariant> componentsHash = getComponentsStoredOfEntity(rmsEntityId, storedValuesWithoutTimeStamp);
    QString value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN1");
    QCOMPARE(value, "10");

    value = getValuesStoredOfComponent(componentsHash, "ACT_RMSPN2");
    QCOMPARE(value, "11");

    QString fileContent = readEntitiesAndCompoFromJsonFile(":/more-rms-components.json");
    changeComponentValue(storageEntityId, "PAR_JsonWithEntities0", fileContent);
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 5);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 6);
    TimeMachineForTest::getInstance()->processTimers(100);

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QString inputJsonFile = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "PAR_JsonWithEntities0").toString();
    QVERIFY(!inputJsonFile.contains("ACT_RMSPN3"));
    QVERIFY(!inputJsonFile.contains("ACT_RMSPN4"));
}

void test_vf_recorder::fireActualValuesAfterDelayWhileLogging()
{
    createMinimalRangeRmsModules();
    startLoggingFromJson(":/correct-entities.json", 0);

    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();
    QStringList timestampKeys = storedValues.keys();
    QCOMPARE (timestampKeys.size(), 1);

    TimeMachineForTest::getInstance()->processTimers(5000);
    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 5);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 6);
    TimeMachineForTest::getInstance()->processTimers(100);

    storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();
    timestampKeys = storedValues.keys();
    QCOMPARE (timestampKeys.size(), 2);

    QDateTime firstTimeStamp = QDateTime::fromString(timestampKeys.first() , "dd-MM-yyyy hh:mm:ss.zzz");
    QDateTime lastTimeStamp = QDateTime::fromString(timestampKeys.last() , "dd-MM-yyyy hh:mm:ss.zzz");
    QVERIFY(firstTimeStamp < lastTimeStamp);
}

void test_vf_recorder::fireRmsPowerValuesAfterDifferentDelaysWhileLogging()
{
    createMinimalRangeRmsModules();
    QVariantMap components = {{"ACT_PQS1", QVariant()}, {"ACT_PQS2", QVariant()}};
    createModule(powerEntityId, components);
    startLoggingFromJson(":/rms-power1-components.json", 0);

    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 1);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 2);
    changeComponentValue(powerEntityId, "ACT_PQS1", 1);
    changeComponentValue(powerEntityId, "ACT_PQS1", 2);
    TimeMachineObject::feedEventLoop();
    TimeMachineForTest::getInstance()->processTimers(100);

    QJsonObject storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();
    QStringList timestampKeys = storedValues.keys();
    QCOMPARE (timestampKeys.size(), 1);

    QJsonObject storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(powerEntityId)));

    TimeMachineForTest::getInstance()->processTimers(500);

    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 3);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 4);
    TimeMachineForTest::getInstance()->processTimers(100);

    storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();
    timestampKeys = storedValues.keys();
    QCOMPARE (timestampKeys.size(), 2);

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));
    QVERIFY(!storedValuesWithoutTimeStamp.contains(QString::number(powerEntityId)));

    TimeMachineForTest::getInstance()->processTimers(500);
    triggerRangeModuleSigMeasuring();
    changeComponentValue(rmsEntityId, "ACT_RMSPN1", 5);
    changeComponentValue(rmsEntityId, "ACT_RMSPN2", 6);
    changeComponentValue(powerEntityId, "ACT_PQS1", 5);
    TimeMachineObject::feedEventLoop();
    TimeMachineForTest::getInstance()->processTimers(10);
    changeComponentValue(powerEntityId, "ACT_PQS2", 6);

    TimeMachineForTest::getInstance()->processTimers(100);

    storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, "StoredValues0").toJsonObject();
    timestampKeys = storedValues.keys();
    QCOMPARE (timestampKeys.size(), 3);

    storedValuesWithoutTimeStamp = getStoredValueWithoutTimeStamp(0);
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(rmsEntityId)));
    QVERIFY(storedValuesWithoutTimeStamp.contains(QString::number(powerEntityId)));
}

void test_vf_recorder::createMinimalRangeRmsModules()
{
    QVariantMap components = {{"ACT_RMSPN1", QVariant()}, {"ACT_RMSPN2", QVariant()}};
    createModule(rmsEntityId, components);
    components = {{"SIG_Measuring", QVariant(1)}};
    createModule(rangeEntityId, components);
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
    TimeMachineObject::feedEventLoop();
    for(auto compoName : components.keys())
        entity->createComponent(compoName, components[compoName]);
}

void test_vf_recorder::triggerRangeModuleSigMeasuring()
{
    //"SIG_Measuring" changes from 0 to 1 when new actual values are available
    changeComponentValue(rangeEntityId, "SIG_Measuring", QVariant(0));
    changeComponentValue(rangeEntityId, "SIG_Measuring", QVariant(1));
}

QString test_vf_recorder::readEntitiesAndCompoFromJsonFile(QString filePath)
{
    QFile file(filePath);
    file.open(QIODevice::ReadOnly);
    return file.readAll();
}

void test_vf_recorder::startLoggingFromJson(QString fileName, int storageNum)
{
    QString fileContent = readEntitiesAndCompoFromJsonFile(fileName);
    changeComponentValue(storageEntityId, QString("PAR_JsonWithEntities%1").arg(storageNum), fileContent);
    changeComponentValue(storageEntityId, QString("PAR_StartStopLogging%1").arg(storageNum), true);
}

void test_vf_recorder::stopLogging(int storageNum)
{
    changeComponentValue(storageEntityId, QString("PAR_StartStopLogging%1").arg(storageNum), false);
}

QJsonObject test_vf_recorder::getStoredValueWithoutTimeStamp(int storageNum)
{
    QJsonObject storedValuesWithoutTimeStamp;
    QJsonObject storedValues = m_storageEventSystem->getDb()->getStoredValue(storageEntityId, QString("StoredValues%1").arg(storageNum)).toJsonObject();
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

