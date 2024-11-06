#include "QJsonDocument"
#include "vf_recorder.h"

static constexpr int maximumStorages = 5;

Vf_Recorder::Vf_Recorder(VeinStorage::AbstractEventSystem *storageSystem, QObject *parent, int entityId):
    QObject(parent),
    m_storageSystem(storageSystem),
    m_isInitalized(false)
{
    m_timeStamper = VeinStorage::TimeStamperSettable::create();
    m_entity=new VfCpp::VfCppEntity(entityId);
    for(int i = 0; i < maximumStorages; i++) {
        VeinDataCollector* dataCollector = new VeinDataCollector(storageSystem, m_timeStamper);
        m_dataCollect.append(dataCollector);
        connect(dataCollector, &VeinDataCollector::newStoredValue, this, [=](QJsonObject value){
            m_storedValues[i]->setValue(value);
        });
    }
}

bool Vf_Recorder::initOnce()
{
    if(!m_isInitalized) {
        m_isInitalized=true;
        m_entity->initModule();
        m_entity->createComponent("EntityName", "Storage", true);
        m_maximumLoggingComponents = m_entity->createComponent("ACT_MaximumLoggingComponents", maximumStorages, true);
        for(int i = 0; i < maximumStorages; i++) {
            m_storedValues.append(m_entity->createComponent(QString("StoredValues%1").arg(i), QJsonObject(), true));
            m_JsonWithEntities.append(m_entity->createComponent(QString("PAR_JsonWithEntities%1").arg(i), "", false));
            m_startStopLogging.append(m_entity->createComponent(QString("PAR_StartStopLogging%1").arg(i), false, false));
            connect(m_startStopLogging.at(i).get(), &VfCpp::VfCppComponent::sigValueChanged, this, [=](QVariant value){
                startStopLogging(value, i);
            });
        }
    }
    return true;
}

VfCpp::VfCppEntity *Vf_Recorder::getVeinEntity() const
{
    return m_entity;
}

void Vf_Recorder::startStopLogging(QVariant value, int storageNum)
{
    bool onOff = value.toBool();

    if(onOff) {
        prepareTimeRecording();
        m_JsonWithEntities[storageNum]->changeComponentReadWriteType(true);
        QString jsonString = m_JsonWithEntities[storageNum]->getValue().toString();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
        QJsonObject jsonObject = jsonDoc.object();
        readJson(jsonObject, storageNum);
    }
    else {
        m_JsonWithEntities[storageNum]->changeComponentReadWriteType(false);
        m_dataCollect[storageNum]->stopLogging();
    }
}

void Vf_Recorder::readJson(QVariant value, int storageNum)
{
    QJsonObject jsonObject = value.toJsonObject();

    if(!jsonObject.isEmpty()) {
        QHash<int, QStringList> entitesAndComponents = extractEntitiesAndComponents(jsonObject);
        m_dataCollect[storageNum]->startLogging(entitesAndComponents);
    }
    else {
        qInfo("Empty Json !");
    }
}

QHash<int, QStringList> Vf_Recorder::extractEntitiesAndComponents(QJsonObject jsonObject)
{
    QHash<int, QStringList> entitesAndComponents;
    QString firstKey = jsonObject.keys().at(0);
    const QJsonArray values = jsonObject.value(firstKey).toArray();
    for (const QJsonValue& value : values) {
        QJsonObject itemObject = value.toObject();
        int entityId = itemObject["EntityId"].toInt();
        QJsonValue componentValue = itemObject["Component"];

        QStringList componentList;
        if (componentValue.isArray()) {
            const QJsonArray componentArray = componentValue.toArray();
            if(componentArray.isEmpty()) {
                componentList = m_storageSystem->getDb()->getComponentList(entityId);
                ignoreComponents(&componentList);
            }
            else {
                for (const QJsonValue& compValue : componentArray) {
                    componentList.append(compValue.toString());
                }
            }
        }
        else if (componentValue.isString()) {
            componentList.append(componentValue.toString());
        }
        entitesAndComponents.insert(entityId, componentList);
    }
    return entitesAndComponents;
}

void Vf_Recorder::ignoreComponents(QStringList *componentList)
{
    QString componentToBeIgnored = "SIG_Measuring";
    componentList->removeAll(componentToBeIgnored);
}

void Vf_Recorder::prepareTimeRecording()
{
    int rangeModuleEntity = 1020;
    VeinStorage::AbstractComponentPtr storageCompo = m_storageSystem->getDb()->findComponent(rangeModuleEntity, "SIG_Measuring");
    connect(storageCompo.get(), &VeinStorage::AbstractComponent::sigValueChange, this, [&](QVariant newValue){
        if(newValue.toInt() == 1) { // 1 indicates RangeModule received new actual values
            m_timeStamper->setTimestampToNow();
        }
    });
}

