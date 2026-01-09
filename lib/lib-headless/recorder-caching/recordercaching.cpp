#include "recordercaching.h"
#include <QDateTime>

RecorderCaching::RecorderCaching(VeinStorage::AbstractEventSystem *clientStorage, VfCmdEventHandlerSystemPtr cmdEventHandlerSystem) :
    m_clientStorage(clientStorage),
    m_cmdEventHandlerSystem(cmdEventHandlerSystem)
{
}

void RecorderCaching::setRecordedValues(QJsonObject newRecordedValues)
{
    for (auto it = newRecordedValues.begin(); it != newRecordedValues.end(); ++it)
        m_recordedObject.insert(it.key(), it.value());
    emit newValuesRecorded();
}

QJsonObject RecorderCaching::getRecordedValues()
{
    return m_recordedObject;
}

qint64 RecorderCaching::getFirstTimestamp()
{
    QString dateTime = m_recordedObject.keys().isEmpty() ? QString() : m_recordedObject.keys().at(0);
    return QDateTime::fromString(dateTime, "dd-MM-yyyy hh:mm:ss.zzz").toMSecsSinceEpoch();
}

void RecorderCaching::clearCashe()
{
    m_recordedObject = QJsonObject();
    emit newValuesRecorded();
}
