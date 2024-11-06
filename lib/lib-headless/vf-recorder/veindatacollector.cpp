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
        emit newStoredValue(m_jsonObject);
    });
}

void VeinDataCollector::startLogging(QHash<int, QStringList> entitesAndComponents)
{
    m_jsonObject = QJsonObject();
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

void VeinDataCollector::appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp)
{
    Q_UNUSED(timeStamp)
    QHash<int , QHash<QString, QVariant> > infosHash;
    infosHash[entityId][componentName] = value;
    QString timeString = m_timeStamper->getTimestamp().toString("dd-MM-yyyy hh:mm:ss.zzz");
    m_jsonObject.insert(timeString, convertToJson(timeString, infosHash));
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

QJsonObject VeinDataCollector::getJsonForTimestamp(QString timestamp)
{
    QJsonObject jsonWithoutTimestamp;
    for(const QString &key : m_jsonObject.keys()) {
        if(key == timestamp)
            jsonWithoutTimestamp = m_jsonObject.value(key).toObject();
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

QJsonObject VeinDataCollector::convertHashToJsonObject(QHash<QString, QVariant> hash)
{
    QJsonObject jsonObject;
    for (auto it = hash.constBegin(); it != hash.constEnd(); ++it) {
        jsonObject.insert(it.key(), it.value().toString());
    }
    return jsonObject;
}
