#ifndef RECORDERCACHING_H
#define RECORDERCACHING_H

#include <vs_abstracteventsystem.h>
#include <vf_cmd_event_handler_system.h>
#include <QJsonObject>
#include <QObject>

class RecorderCaching : public QObject
{
    Q_OBJECT
public:
    explicit RecorderCaching(VeinStorage::AbstractEventSystem* clientStorage, VfCmdEventHandlerSystemPtr cmdEventHandlerSystem);

    Q_PROPERTY(QJsonObject recordedValues READ getRecordedValues NOTIFY newValuesRecorded)
    Q_PROPERTY(qint64 firstTimestamp READ getFirstTimestamp)

    Q_INVOKABLE void setRecordedValues(QJsonObject newRecordedValues);
    Q_INVOKABLE void clearCashe();

    QJsonObject getRecordedValues();
    qint64 getFirstTimestamp();

signals:
    void newValuesRecorded();

private:
    VeinStorage::AbstractEventSystem* m_clientStorage;
    VfCmdEventHandlerSystemPtr m_cmdEventHandlerSystem;
    QJsonObject m_recordedObject;

};

#endif // RECORDERCACHING_H
