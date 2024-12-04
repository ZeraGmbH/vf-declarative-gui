#include "veindatacollector.h"
#include <vs_abstractcomponent.h>
#include <timerfactoryqt.h>
#include <QDateTime>

// Note:
// StorageFilter::Settings are going to change - current settings are set
// to make tests happy

static constexpr int dftEntityId = 1050;

 VeinDataCollector::VeinDataCollector(VeinStorage::AbstractEventSystem *storage, VeinStorage::TimeStamperSettablePtr timeSetter) :
    m_timeStamper(timeSetter),
    m_storage(storage)
{
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_completeJson = QJsonObject();
    m_recentJsonObject = QJsonObject();
    m_targetEntityComponents = entitesAndComponents;
    prepareTimeRecording();
    qInfo("VeinDataCollector started logging.");
}

void VeinDataCollector::stopLogging()
{
    disconnect(m_sigMeasuringCompo.get(), 0, this, 0);
    qInfo("VeinDataCollector stopped logging.");
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
