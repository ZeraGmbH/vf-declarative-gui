#ifndef VEINDATACOLLECTOR_H
#define VEINDATACOLLECTOR_H

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
    QJsonObject getStoredValues();
signals:
    // Ideas:
    // * replace internal data QJsoonObject by
    //   typedef QHash<int/*entityId*/, QHash<QString/*componentName*/, QVariant/*value*/>> RecordedGroups;
    //   typedef QMap<qint64 /* msSinceEpochTimestamp */, RecordedGroups> TimeStampedGroups;
    // * split up filter / datacollection / periodic vein update into smaller pieces
    void newStoredValue();

private slots:
    void appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp);
private:
    RecordedEntityComponents appendToExistingRecord(RecordedEntityComponents existingRecord, int entityId, QString componentName, QVariant value);
    RecordedEntityComponents prepareNewRecord(int entityId, QString componentName, QVariant value);
    QJsonObject convertRecordedEntityComponentsToJson(RecordedEntityComponents recordedEntityComponents);
    bool isRecordComplete(RecordedEntityComponents record);

    VeinStorage::StorageFilter m_storageFilter;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    QHash<int, QStringList> m_targetEntityComponents;
    QJsonObject m_jsonObject;
    TimeStampedRecords m_currentTimestampRecord;
};

#endif // VEINDATACOLLECTOR_H
