#include "vf_recorder.h"
#include <QJsonArray>

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

void Vf_Recorder::deleteInstance()
{
    delete instance;
    instance = nullptr;
}

Vf_Recorder::Vf_Recorder(QObject *parent): QObject(parent)
{
    if(!m_storageSystem)
        qCritical("Vf_Recorder: storage system not set.");
    for(int i = 0; i < maximumStorages; i++) {
        VeinDataCollector* dataCollector = new VeinDataCollector(m_storageSystem);
        m_dataCollect.append(dataCollector);
        connect(dataCollector, &VeinDataCollector::newValueCollected, this, [&](){
            emit newStoredValues(i);
        });
    }
}

void Vf_Recorder::startLogging(int storageNum, QJsonObject inputJson)
{
    readJson(inputJson, storageNum);
    qInfo("Vf_Recorder started logging.");
}

void Vf_Recorder::stopLogging(int storageNum)
{
    m_dataCollect[storageNum]->stopLogging();
    qInfo("Vf_Recorder stopped logging.");
}

void Vf_Recorder::clearJson(int storageNum)
{
    m_dataCollect.at(0)->clearJson();
    emit newStoredValues(storageNum);
}

QJsonObject Vf_Recorder::getLatestStoredValues0()
{
    return m_dataCollect.at(0)->getLatestJsonObject();
}

QJsonObject Vf_Recorder::getLatestStoredValues(int storageNum)
{
    return m_dataCollect.at(storageNum)->getLatestJsonObject();
}

QString Vf_Recorder::getFirstTimestamp0()
{
    return m_dataCollect.at(0)->getFirstTimeStamp();
}

void Vf_Recorder::readJson(QJsonObject jsonValue, int storageNum)
{
    if(!jsonValue.isEmpty()) {
        QHash<int, QStringList> entitesAndComponents = extractEntitiesAndComponents(jsonValue);
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
