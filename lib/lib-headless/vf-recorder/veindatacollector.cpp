#include "veindatacollector.h"
#include <vs_abstractcomponent.h>

// Note:
// StorageFilter::Settings are going to change - current settings are set
// to make tests happy

 VeinDataCollector::VeinDataCollector(VeinStorage::AbstractEventSystem *storage) :
    m_storage(storage)
{
     m_timeStamper = VeinStorage::TimeStamperSettable::create();
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_completeJson = QJsonObject();
    m_latestJsonObject = QJsonObject();
    m_targetEntityComponents = entitesAndComponents;
    m_firstTimeStamp = QString();
    prepareTimeRecording();
    qInfo("VeinDataCollector started logging.");
}

void VeinDataCollector::stopLogging()
{
    disconnect(m_sigMeasuringCompo.get(), 0, this, 0);
    qInfo("VeinDataCollector stopped logging.");
}

QJsonObject VeinDataCollector::getLatestJsonObject()
{
    return m_latestJsonObject;
}

QString VeinDataCollector::getFirstTimeStamp()
{
    return m_firstTimeStamp;
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
    m_latestJsonObject = QJsonObject{{timeString, convertRecordedEntityComponentsToJson(newRecord)}};
    m_completeJson.insert(timeString, m_latestJsonObject.value(timeString));
    emit newValueCollected();
}

void VeinDataCollector::prepareTimeRecording()
{
    m_sigMeasuringCompo = m_storage->getDb()->findComponent(sigMeasuringEntityId, "SIG_Measuring");
    if(m_sigMeasuringCompo) {
        connect(m_sigMeasuringCompo.get(), &VeinStorage::AbstractComponent::sigValueChange, this, [&](QVariant newValue){
            if(newValue.toInt() == 1) {// 1 indicates DftModule received new actual values
                m_timeStamper->setTimestampToNow();
                if(m_firstTimeStamp.isEmpty())
                    m_firstTimeStamp = m_timeStamper->getTimestamp().toUTC().toString("dd-MM-yyyy hh:mm:ss.zzz");
                collectValues(m_timeStamper->getTimestamp());
            }
        });
    }
    else
        qInfo("Graphs recording can't work. RangeModule/SIG_Measuring component is missing.");
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
