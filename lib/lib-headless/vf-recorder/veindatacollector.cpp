#include "veindatacollector.h"
#include <vs_abstractcomponent.h>
#include <timerfactoryqt.h>
#include <QDateTime>

// Note:
// StorageFilter::Settings are going to change - current settings are set
// to make tests happy

static constexpr int dftEntityId = 1050;

 VeinDataCollector::VeinDataCollector(VeinStorage::AbstractEventSystem *storage, VeinStorage::TimeStamperSettablePtr timeSetter) :
    m_storageFilter(storage, VeinStorage::StorageFilter::Settings(false, true)),
    m_timeStamper(timeSetter),
    m_storage(storage)
{
    connect(&m_storageFilter, &VeinStorage::StorageFilter::sigComponentValue, this, &VeinDataCollector::appendValue);
    m_periodicTimer = TimerFactoryQt::createPeriodic(500);
    connect(m_periodicTimer.get(), &TimerTemplateQt::sigExpired, this, &VeinDataCollector::TimerExpired);
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_jsonObject = QJsonObject();
    m_lastJsonObject = QJsonObject();
    m_completeJson = QJsonObject();
    m_recentJsonObject = QJsonObject();
    m_currentTimestampRecord.clear();
    for(auto iter=entitesAndComponents.cbegin(); iter!=entitesAndComponents.cend(); ++iter) {
        const QStringList components = iter.value();
        int entityId = iter.key();
        for(const QString& componentName : components)
            m_storageFilter.add(entityId, componentName);
    }
    m_targetEntityComponents = entitesAndComponents;
    prepareTimeRecording();
    qInfo("VeinDataCollector started logging.");
}

void VeinDataCollector::stopLogging()
{
    m_periodicTimer->stop();
    m_storageFilter.clear();
    disconnect(m_sigMeasuringCompo.get(), 0, this, 0);
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

QJsonObject VeinDataCollector::getCompleteJson()
{
    return m_completeJson;
}

QJsonObject VeinDataCollector::getRecentJsonObject()
{
    return m_recentJsonObject;
}

void VeinDataCollector::clearJson()
{
    m_jsonObject = QJsonObject();
    m_completeJson = QJsonObject();
}

void VeinDataCollector::collectValues(QDateTime timeStamp)
{
    RecordedEntityComponents newRecord;
    for(auto entity: m_targetEntityComponents.keys()) {
        ComponentInfo componentValues;
        for(auto componentName: m_targetEntityComponents.value(entity))
            componentValues.insert(componentName, m_storage->getDb()->getStoredValue(entity, componentName));
        newRecord.insert(entity, componentValues);
    }

    QString timeString = timeStamp.toUTC().toString("dd-MM-yyyy hh:mm:ss.zzz");
    m_recentJsonObject = QJsonObject{{timeString, convertRecordedEntityComponentsToJson(newRecord)}};
    m_completeJson.insert(timeString, m_recentJsonObject.value(timeString));
    emit newValueCollected();
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

    m_periodicTimer->start();
    m_currentTimestampRecord.insert(timeString, newRecord);
    m_jsonObject.insert(timeString, convertRecordedEntityComponentsToJson(newRecord));

    if(isRecordComplete(m_currentTimestampRecord.value(timeString))) {
        m_periodicTimer->stop();
        m_lastJsonObject = QJsonObject{{timeString, m_jsonObject.value(timeString)}};
        m_currentTimestampRecord.clear();
        emit newStoredValue();
    }
}

void VeinDataCollector::TimerExpired()
{
    m_periodicTimer->stop();
    if(!m_currentTimestampRecord.isEmpty()) {
        for(const auto key : m_currentTimestampRecord.keys()) {
            RecordedEntityComponents newRecord = m_currentTimestampRecord.value(key);
            m_lastJsonObject = QJsonObject{{key, convertRecordedEntityComponentsToJson(newRecord)}};
            emit newStoredValue();
        }
        m_currentTimestampRecord.clear();
    }
}

void VeinDataCollector::prepareTimeRecording()
{
    m_sigMeasuringCompo = m_storage->getDb()->findComponent(dftEntityId, "SIG_Measuring");
    if(m_sigMeasuringCompo) {
        connect(m_sigMeasuringCompo.get(), &VeinStorage::AbstractComponent::sigValueChange, this, [&](QVariant newValue){
            if(newValue.toInt() == 1) {// 1 indicates RangeModule received new actual values
                m_timeStamper->setTimestampToNow();
                collectValues(m_timeStamper->getTimestamp());
            }
        });
    }
    else
        qInfo("Graphs recording can't work. RangeModule/SIG_Measuring component is missing.");
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
