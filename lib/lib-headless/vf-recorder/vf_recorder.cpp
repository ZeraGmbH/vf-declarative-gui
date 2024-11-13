#include "vf_recorder.h"
#include <QJsonDocument>
#include <QJsonArray>

static constexpr int rangeEntityId = 1020;
static constexpr int maximumStorages = 5;

Vf_Recorder *Vf_Recorder::instance = nullptr;
VeinStorage::AbstractEventSystem *Vf_Recorder::m_storageSystem = nullptr;

void Vf_Recorder::setStorageSystem(VeinStorage::AbstractEventSystem *storageSystem)
{
    m_storageSystem = storageSystem;
}

Vf_Recorder *Vf_Recorder::getInstance()
{
    if(!instance)
        instance = new Vf_Recorder();
    return instance;
}

Vf_Recorder::Vf_Recorder(QObject *parent): QObject(parent)
{
    if(!m_storageSystem)
        qCritical("Vf_Recorder: storage system not set.");
    m_timeStamper = VeinStorage::TimeStamperSettable::create();
    for(int i = 0; i < maximumStorages; i++) {
        VeinDataCollector* dataCollector = new VeinDataCollector(m_storageSystem, m_timeStamper);
        m_dataCollect.append(dataCollector);
        connect(dataCollector, &VeinDataCollector::newStoredValue, this, [=](QJsonObject value){
            emit newStoredValues(i, value);
        });
    }
}

void Vf_Recorder::startLogging(int storageNum, QJsonObject inputJson)
{
    readJson(inputJson, storageNum);
}

void Vf_Recorder::stopLogging(int storageNum)
{
    m_dataCollect[storageNum]->stopLogging();
}

QJsonObject Vf_Recorder::getStoredValues0()
{
    return getStoredValues(0);
}

QJsonObject Vf_Recorder::getStoredValues(int storageNum)
{
    return m_dataCollect.at(storageNum)->getStoredValues();
}

void Vf_Recorder::readJson(QJsonObject jsonValue, int storageNum)
{
    if(!jsonValue.isEmpty()) {
        if(prepareTimeRecording()){
            QHash<int, QStringList> entitesAndComponents = extractEntitiesAndComponents(jsonValue);
            m_dataCollect[storageNum]->startLogging(entitesAndComponents);
        }
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

bool Vf_Recorder::prepareTimeRecording()
{
    bool timeTracerAvailable = false;
    VeinStorage::AbstractComponentPtr storageCompo = m_storageSystem->getDb()->findComponent(rangeEntityId, "SIG_Measuring");
    if(storageCompo) {
        connect(storageCompo.get(), &VeinStorage::AbstractComponent::sigValueChange, this, [&](QVariant newValue){
            if(newValue.toInt() == 1) // 1 indicates RangeModule received new actual values
                m_timeStamper->setTimestampToNow();
        });
        timeTracerAvailable = true;
    }
    else
        qInfo("Graphs recording can't work. RangeModule/SIG_Measuring component is missing.");
    return timeTracerAvailable;
}

