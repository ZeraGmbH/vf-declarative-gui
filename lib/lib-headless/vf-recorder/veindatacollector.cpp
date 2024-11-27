#include "veindatacollector.h"
#include <vs_abstractcomponent.h>
#include <timerfactoryqt.h>
#include <QDateTime>

// Note:
// StorageFilter::Settings are going to change - current settings are set
// to make tests happy

 VeinDataCollector::VeinDataCollector(VeinStorage::AbstractEventSystem *storage, VeinStorage::TimeStamperSettablePtr timeSetter) :
    m_storageFilter(storage, VeinStorage::StorageFilter::Settings(false, true)),
    m_timeStamper(timeSetter)
{
    connect(&m_storageFilter, &VeinStorage::StorageFilter::sigComponentValue, this, &VeinDataCollector::appendValue);
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_jsonObject = QJsonObject();
    m_lastJsonObject = QJsonObject();
    m_currentTimestampRecord.clear();
    for(auto iter=entitesAndComponents.cbegin(); iter!=entitesAndComponents.cend(); ++iter) {
        const QStringList components = iter.value();
        int entityId = iter.key();
        for(const QString& componentName : components)
            m_storageFilter.add(entityId, componentName);
    }
    m_targetEntityComponents = entitesAndComponents;
    qInfo("VeinDataCollector started logging.");
}

void VeinDataCollector::stopLogging()
{
    m_storageFilter.clear();
    qInfo("VeinDataCollector stopped logging.");
}

QJsonObject VeinDataCollector::getAllStoredValues()
{
    return m_jsonObject;
}

QJsonObject VeinDataCollector::getLastStoredValues()
{
    return m_lastJsonObject;
}

void VeinDataCollector::clearJson()
{
    m_jsonObject = QJsonObject();
}

void VeinDataCollector::appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp)
{
    Q_UNUSED(timeStamp)
    QString timeString = m_timeStamper->getTimestamp().toUTC().toString("dd-MM-yyyy hh:mm:ss.zzz");

    RecordedEntityComponents newRecord;
    if(m_currentTimestampRecord.contains(timeString)) {
        RecordedEntityComponents existingRecord = m_currentTimestampRecord.value(timeString);
        newRecord = appendToExistingRecord(existingRecord, entityId, componentName, value);
    }
    else
        newRecord = prepareNewRecord(entityId, componentName, value);

    m_currentTimestampRecord.insert(timeString, newRecord);
    m_jsonObject.insert(timeString, convertRecordedEntityComponentsToJson(newRecord));
    if(isRecordComplete(m_currentTimestampRecord.value(timeString))) {
        m_lastJsonObject = QJsonObject{{timeString, m_jsonObject.value(timeString)}};
        m_currentTimestampRecord.clear();
        emit newStoredValue();
    }
}

RecordedEntityComponents VeinDataCollector::appendToExistingRecord(RecordedEntityComponents existingRecord, int entityId, QString componentName, QVariant value)
{
    if(existingRecord.contains(entityId)) { //new component
        ComponentInfo existingComponents = existingRecord.value(entityId);
        existingComponents.insert(componentName, value);
        existingRecord.insert(entityId, existingComponents);
    }
    else {//new entity
        ComponentInfo newComponents {{componentName, value}};
        existingRecord.insert(entityId, newComponents);
    }

    return existingRecord;
}

RecordedEntityComponents VeinDataCollector::prepareNewRecord(int entityId, QString componentName, QVariant value)
{
    ComponentInfo newComponents {{componentName, value}};
    RecordedEntityComponents newRecord {{entityId, newComponents}};
    return newRecord;
}

QJsonObject VeinDataCollector::convertRecordedEntityComponentsToJson(RecordedEntityComponents record)
{
    QJsonObject json;
    for(auto entityID: record.keys()) {
        QJsonObject componentJson = QJsonObject::fromVariantHash(record[entityID]);
        QString entityIDToString = QString::number(entityID);
        json.insert(entityIDToString, componentJson);
    }
    return json;
}

bool VeinDataCollector::isRecordComplete(RecordedEntityComponents record)
{
    bool recordComplete = true;
    for(auto entity: m_targetEntityComponents.keys()) {
        if(!record.contains(entity))
            recordComplete = false;
        else {
            for(auto componentName: m_targetEntityComponents[entity]) {
                ComponentInfo recordedComponents = record[entity];
                if(!recordedComponents.contains(componentName)) {
                    recordComplete = false;
                    break;
                }
            }
        }
        if(!recordComplete)
            break;
    }
    return recordComplete;
}
