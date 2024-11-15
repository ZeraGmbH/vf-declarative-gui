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

    m_lastRecordTimeout = TimerFactoryQt::createSingleShot(500);
    connect(m_lastRecordTimeout.get(), &TimerTemplateQt::sigExpired,this, &VeinDataCollector::prepareLastJson);
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_completeJsonObject = QJsonObject();
    m_lastRecordObject = QJsonObject();
    m_lastRecordKeeper = QJsonObject();
    for(auto iter=entitesAndComponents.cbegin(); iter!=entitesAndComponents.cend(); ++iter) {
        const QStringList components = iter.value();
        int entityId = iter.key();
        for(const QString& componentName : components)
            m_storageFilter.add(entityId, componentName);
    }
    m_recordedEntitiesComponents = entitesAndComponents;
}

void VeinDataCollector::stopLogging()
{
    m_lastRecordTimeout->stop();
    m_storageFilter.clear();
}

QJsonObject VeinDataCollector::getCompleteJson()
{
    return m_completeJsonObject;
}

QJsonObject VeinDataCollector::getLastJson()
{
    return m_lastRecordKeeper;
}

void VeinDataCollector::appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp)
{
    Q_UNUSED(timeStamp)
    QHash<int , QHash<QString, QVariant> > infosHash;
    infosHash[entityId][componentName] = value;
    QString timeString = m_timeStamper->getTimestamp().toString("dd-MM-yyyy hh:mm:ss.zzz");
    m_completeJsonObject.insert(timeString, convertToJson(timeString, infosHash));
    m_lastRecordObject.insert(timeString, convertLastToJson(infosHash));
    checkLastJsonObjectReady();
}

void VeinDataCollector::prepareLastJson()
{
    m_lastRecordKeeper = m_lastRecordObject;
    m_lastRecordObject = QJsonObject();
    emit newStoredValue();
}

QJsonObject VeinDataCollector::convertToJson(QString timestamp, QHash<int , QHash<QString, QVariant>> infosHash)
{
    QJsonObject jsonObject = getJsonForTimestamp(timestamp);
    for(auto it = infosHash.constBegin(); it != infosHash.constEnd(); ++it) {
        QString entityIdToString = QString::number(it.key());
        if(jsonObject.contains(entityIdToString)) {
            QJsonValue existingValue = jsonObject.value(entityIdToString);
            QHash<QString, QVariant> hash = appendNewValueToExistingValues(existingValue, it.value()) ;
            jsonObject.insert(entityIdToString, convertHashToJsonObject(hash));
        }
        else
            jsonObject.insert(entityIdToString, convertHashToJsonObject(it.value()));
    }
    return jsonObject;
}

QJsonObject VeinDataCollector::convertLastToJson(QHash<int, QHash<QString, QVariant> > infosHash)
{
    QJsonObject jsonObject;
    if(!m_lastRecordObject.isEmpty()) {
        jsonObject = m_lastRecordObject.value(m_lastRecordObject.keys().at(0)).toObject();
        for(auto it = infosHash.constBegin(); it != infosHash.constEnd(); ++it) {
            QString entityIdToString = QString::number(it.key());
            if(jsonObject.contains(entityIdToString)) {
                QJsonValue existingValue = jsonObject.value(entityIdToString);
                QHash<QString, QVariant> hash = appendNewValueToExistingValues(existingValue, it.value()) ;
                jsonObject.insert(entityIdToString, convertHashToJsonObject(hash));
            }
            else
                jsonObject.insert(entityIdToString, convertHashToJsonObject(it.value()));
        }
    }
    else {
        for(auto it = infosHash.constBegin(); it != infosHash.constEnd(); ++it) {
            QString entityIdToString = QString::number(it.key());
            jsonObject.insert(entityIdToString, convertHashToJsonObject(it.value()));
        }
    }
    return jsonObject;
}

QJsonObject VeinDataCollector::getJsonForTimestamp(QString timestamp)
{
    QJsonObject jsonWithoutTimestamp;
    for(const QString &key : m_completeJsonObject.keys()) {
        if(key == timestamp)
            jsonWithoutTimestamp = m_completeJsonObject.value(key).toObject();
    }
    return jsonWithoutTimestamp;
}

QHash<QString, QVariant> VeinDataCollector::appendNewValueToExistingValues(QJsonValue existingValue, QHash<QString, QVariant> compoValuesHash)
{
    QHash<QString, QVariant> hash= existingValue.toObject().toVariantHash();
    for (auto hashIt = compoValuesHash.constBegin(); hashIt != compoValuesHash.constEnd(); ++hashIt)
        hash.insert(hashIt.key(), hashIt.value());
    return hash;
}

void VeinDataCollector::checkLastJsonObjectReady()
{
    if(m_lastRecordObject.count() != 1) {
        qInfo() << "VeinDataCollector::Inconsistent last record.";
    }
    else {
        entitiesComponents lastRecordHash;
        QJsonObject lastJsonWithoutTime = m_lastRecordObject.value(m_lastRecordObject.keys().at(0)).toObject();
        for(auto entity: lastJsonWithoutTime.keys())
            lastRecordHash.insert(entity.toInt(), lastJsonWithoutTime.value(entity).toObject().keys());
        if(allEntitiesComponentsRecorded(lastRecordHash)) {
            m_lastRecordTimeout->stop();
            prepareLastJson();
        }
        else
            m_lastRecordTimeout->start();
    }
}

bool VeinDataCollector::allEntitiesComponentsRecorded(entitiesComponents lastRecordHash)
{
    for(auto entity : m_recordedEntitiesComponents.keys()) {
        if(lastRecordHash.contains(entity)) {
            QStringList components = m_recordedEntitiesComponents[entity];
            for(int i = 0; i<components.size(); i++) {
                if(!lastRecordHash[entity].contains(components[i]))
                    return false;
            }
        }
        else
            return false;
    }
    return true;
}

QJsonObject VeinDataCollector::convertHashToJsonObject(QHash<QString, QVariant> hash)
{
    QJsonObject jsonObject;
    for (auto it = hash.constBegin(); it != hash.constEnd(); ++it) {
        jsonObject.insert(it.key(), it.value().toString());
    }
    return jsonObject;
}
