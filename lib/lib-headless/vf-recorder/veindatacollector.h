#ifndef VEINDATACOLLECTOR_H
#define VEINDATACOLLECTOR_H

#include "timerperiodicqt.h"
#include <vs_abstracteventsystem.h>
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
    QJsonObject getCompleteJson();
    QJsonObject getRecentJsonObject();
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
    QJsonObject m_recentJsonObject;
    QJsonObject m_completeJson;
    VeinStorage::AbstractComponentPtr m_sigMeasuringCompo;
};

#endif // VEINDATACOLLECTOR_H
