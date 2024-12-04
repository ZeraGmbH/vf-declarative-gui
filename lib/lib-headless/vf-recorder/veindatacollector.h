#ifndef VEINDATACOLLECTOR_H
#define VEINDATACOLLECTOR_H

#include "timerperiodicqt.h"
#include <vs_abstracteventsystem.h>
#include <vs_storagefilter.h>
#include <vs_timestampersettable.h>
#include <QJsonObject>
#include <QDateTime>

typedef QHash<QString/*componentName*/, QVariant/*value*/> ComponentInfo;
typedef QHash<int/*entityId*/, ComponentInfo> RecordedEntityComponents;
typedef QMap<QString /*QDateTime in QString*/, RecordedEntityComponents> TimeStampedRecords;

class VeinDataCollector : public QObject
{
    Q_OBJECT
public:
    explicit VeinDataCollector(VeinStorage::AbstractEventSystem* storage, VeinStorage::TimeStamperSettablePtr timeSetter);
    void startLogging(QHash<int, QStringList> entitesAndComponents);
    void stopLogging();
    QJsonObject getAllStoredValues();
    QJsonObject getLastStoredValues();
    QJsonObject getCompleteJson();
    QJsonObject getRecentJsonObject();
    void clearJson();
signals:
    // Ideas:
    // * replace internal data QJsoonObject by
    //   typedef QHash<int/*entityId*/, QHash<QString/*componentName*/, QVariant/*value*/>> RecordedGroups;
    //   typedef QMap<qint64 /* msSinceEpochTimestamp */, RecordedGroups> TimeStampedGroups;
    // * split up filter / datacollection / periodic vein update into smaller pieces
    void newStoredValue();
    void newValueCollected();

private slots:
    void appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp);
    void TimerExpired();
private:
    void prepareTimeRecording();
    void collectValues(QDateTime timeStamp);
    RecordedEntityComponents appendToExistingRecord(RecordedEntityComponents existingRecord, int entityId, QString componentName, QVariant value);
    RecordedEntityComponents prepareNewRecord(int entityId, QString componentName, QVariant value);
    QJsonObject convertRecordedEntityComponentsToJson(RecordedEntityComponents recordedEntityComponents);
    bool isRecordComplete(RecordedEntityComponents record);

    VeinStorage::StorageFilter m_storageFilter;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    QHash<int, QStringList> m_targetEntityComponents;
    QJsonObject m_jsonObject;
    QJsonObject m_lastJsonObject;
    TimeStampedRecords m_currentTimestampRecord;
    TimerTemplateQtPtr m_periodicTimer;

    VeinStorage::AbstractEventSystem* m_storage;
    QJsonObject m_recentJsonObject;
    QJsonObject m_completeJson;
    VeinStorage::AbstractComponentPtr m_sigMeasuringCompo;
};

#endif // VEINDATACOLLECTOR_H
