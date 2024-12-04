#ifndef VEINDATACOLLECTOR_H
#define VEINDATACOLLECTOR_H

#include <vs_abstracteventsystem.h>
#include <vs_timestampersettable.h>
#include <QJsonObject>

typedef QHash<QString/*componentName*/, QVariant/*value*/> ComponentInfo;
typedef QHash<int/*entityId*/, ComponentInfo> RecordedEntityComponents;
typedef QMap<QString /*QDateTime in QString*/, RecordedEntityComponents> TimeStampedRecords;

static constexpr int sigMeasuringEntityId = 1050; //DftModule

class VeinDataCollector : public QObject
{
    Q_OBJECT
public:
    explicit VeinDataCollector(VeinStorage::AbstractEventSystem* storage);
    void startLogging(QHash<int, QStringList> entitesAndComponents);
    void stopLogging();
    QJsonObject getAllStoredValues();
    QJsonObject getLatestJsonObject();
    void clearJson();
signals:
    // Ideas:
    // * replace internal data QJsoonObject by
    //   typedef QHash<int/*entityId*/, QHash<QString/*componentName*/, QVariant/*value*/>> RecordedGroups;
    //   typedef QMap<qint64 /* msSinceEpochTimestamp */, RecordedGroups> TimeStampedGroups;
    // * split up filter / datacollection / periodic vein update into smaller pieces
    void newValueCollected();

private:
    void prepareTimeRecording();
    void collectValues(QDateTime timeStamp);
    QJsonObject convertRecordedEntityComponentsToJson(RecordedEntityComponents recordedEntityComponents);

    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    QHash<int, QStringList> m_targetEntityComponents;

    VeinStorage::AbstractEventSystem* m_storage;
    QJsonObject m_latestJsonObject;
    QJsonObject m_completeJson;
    VeinStorage::AbstractComponentPtr m_sigMeasuringCompo;
};

#endif // VEINDATACOLLECTOR_H
