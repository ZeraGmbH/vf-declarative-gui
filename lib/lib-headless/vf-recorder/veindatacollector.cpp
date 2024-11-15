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
    connect(&m_storageFilter, &VeinStorage::StorageFilter::sigComponentValue,
            this, &VeinDataCollector::appendValue);

    m_periodicTimer = TimerFactoryQt::createPeriodic(100);
    connect(m_periodicTimer.get(), &TimerTemplateQt::sigExpired,this, [&] {
        emit newStoredValue();
    });
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_jsonObject = QJsonObject();
    m_allRecords.clear();
    m_periodicTimer->start();
    for(auto iter=entitesAndComponents.cbegin(); iter!=entitesAndComponents.cend(); ++iter) {
        const QStringList components = iter.value();
        int entityId = iter.key();
        for(const QString& componentName : components)
            m_storageFilter.add(entityId, componentName);
    }
}

void VeinDataCollector::stopLogging()
{
    m_periodicTimer->stop();
    m_storageFilter.clear();
}

QJsonObject VeinDataCollector::getStoredValues()
{
    return m_jsonObject;
}

void VeinDataCollector::appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp)
{
    Q_UNUSED(timeStamp)
    QString timeString = m_timeStamper->getTimestamp().toString("dd-MM-yyyy hh:mm:ss.zzz");

    RecordedEntityComponents newRecord;
    if(m_allRecords.contains(timeString)) {
        RecordedEntityComponents existingRecord = m_allRecords.value(timeString);
        newRecord = appendToExistingRecord(existingRecord, entityId, componentName, value);
    }
    else
        newRecord = prepareNewRecord(entityId, componentName, value);

    m_allRecords.insert(timeString, newRecord);
    m_jsonObject.insert(timeString, convertRecordedEntityComponentsToJson(newRecord));
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
