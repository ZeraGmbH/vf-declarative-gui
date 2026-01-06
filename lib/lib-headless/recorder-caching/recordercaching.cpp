#include "recordercaching.h"
#include <QDateTime>

RecorderCaching *RecorderCaching::instance = nullptr;

RecorderCaching::RecorderCaching(QObject *parent)
    : QObject{parent}
{}

RecorderCaching *RecorderCaching::getInstance()
{
    if(!instance)
        instance = new RecorderCaching();
    return instance;
}

void RecorderCaching::appendRecordedValues(const QJsonObject &newRecordedValues)
{
    if (newRecordedValues.size() > 0) {
        int start = m_cache.size();

        for (auto iterTimestamp=newRecordedValues.constBegin(); iterTimestamp!=newRecordedValues.constEnd(); ++iterTimestamp) {
            const QString timeStampStr = iterTimestamp.key();
            const QDateTime timeStamp = getDateTime(timeStampStr);
            const QJsonObject entitiesDataJson = iterTimestamp.value().toObject();

            EntitiesData entitiesData;
            for (auto iterEntities = entitiesDataJson.constBegin(); iterEntities!=entitiesDataJson.constEnd(); ++iterEntities) {
                const QString entityIdStr = iterEntities.key();
                bool convOk = false;
                int entityId = entityIdStr.toInt(&convOk);
                if (!convOk) {
                    qWarning("Entity ID %s is not a number!", qPrintable(entityIdStr));
                    continue;
                }
                const QJsonObject entityDataJson = iterEntities.value().toObject();
                SingleEntityData entityData;
                for (auto iterComponents = entityDataJson.constBegin(); iterComponents!=entityDataJson.constEnd(); ++iterComponents) {
                    const QString componentName = iterComponents.key();
                    entityData[componentName] = iterComponents.value().toDouble();
                }
                entitiesData[entityId] = entityData;
            }
            m_cache.append({timeStamp, entitiesData});
        }
        emit newValuesRecorded();
        int end = m_cache.size()-1;
        emit sigNewValuesAdded(start, end);
    }
}

QJsonObject RecorderCaching::getValues(int startIdx, int endIdx)
{
    QJsonObject cache;
    for (int idx=startIdx; idx<=endIdx; ++idx) {
        const QDateTime &timestamp = m_cache[idx].timeStamp;
        const EntitiesData &entitiesData = m_cache[idx].entitiesData;
        QJsonObject timeStampDataJson;
        for (auto iterEntity=entitiesData.constBegin(); iterEntity!=entitiesData.constEnd(); ++iterEntity) {
            int entityId = iterEntity.key();
            const SingleEntityData &entityData = iterEntity.value();
            QJsonObject entityDataJson;
            for (auto iterComponent=entityData.constBegin(); iterComponent!=entityData.constEnd(); ++iterComponent) {
                const QString &componentName = iterComponent.key();
                const double value = iterComponent.value();
                entityDataJson.insert(componentName, value);
            }
            timeStampDataJson.insert(QString("%1").arg(entityId), entityDataJson);
        }
        cache.insert(timestamp.toString(getDateTimeConvertStr()), timeStampDataJson);
    }
    return cache;
}

QJsonObject RecorderCaching::getRecordedValues()
{
    return getValues(0, m_cache.size()-1);
}

qint64 RecorderCaching::getFirstTimestamp()
{
    if (m_cache.isEmpty())
        return 0;
    return m_cache[0].timeStamp.toMSecsSinceEpoch();
}

QString RecorderCaching::getDateTimeConvertStr()
{
    return "dd-MM-yyyy hh:mm:ss.zzz";
}

QDateTime RecorderCaching::getDateTime(const QString &timeStamp)
{
    return QDateTime::fromString(timeStamp, getDateTimeConvertStr());
}

void RecorderCaching::clearCashe()
{
    m_cache.clear();
    emit newValuesRecorded();
}
