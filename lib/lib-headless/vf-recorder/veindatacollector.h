#ifndef VEINDATACOLLECTOR_H
#define VEINDATACOLLECTOR_H

#include <vs_abstracteventsystem.h>
#include <vs_storagefilter.h>
#include <vs_timestampersettable.h>
#include <timerperiodicqt.h>
#include <QJsonObject>
#include <QDateTime>

typedef QHash<int, QStringList> entitiesComponents;

class VeinDataCollector : public QObject
{
    Q_OBJECT
public:
    explicit VeinDataCollector(VeinStorage::AbstractEventSystem* storage, VeinStorage::TimeStamperSettablePtr timeSetter);
    void startLogging(QHash<int, QStringList> entitesAndComponents);
    void stopLogging();
    QJsonObject getCompleteJson();
    QJsonObject getLastJson();
signals:
    // Ideas:
    // * replace internal data QJsoonObject by
    //   typedef QHash<int/*entityId*/, QHash<QString/*componentName*/, QVariant/*value*/>> RecordedGroups;
    //   typedef QMap<qint64 /* msSinceEpochTimestamp */, RecordedGroups> TimeStampedGroups;
    // * split up filter / datacollection / periodic vein update into smaller pieces
    void newStoredValue();

private slots:
    void appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp);
    void prepareLastJson();
private:
    QJsonObject convertToJson(QString timestamp, QHash<int, QHash<QString, QVariant> > infosHash);
    QJsonObject convertLastToJson(QHash<int, QHash<QString, QVariant> > infosHash);

    QJsonObject convertHashToJsonObject(QHash<QString, QVariant> hash);
    QJsonObject getJsonForTimestamp(QString timestamp);
    QHash<QString, QVariant> appendNewValueToExistingValues(QJsonValue existingValue, QHash<QString, QVariant> compoValuesHash);
    void checkLastJsonObjectReady();
    bool allEntitiesComponentsRecorded(entitiesComponents lastRecordHash);

    VeinStorage::StorageFilter m_storageFilter;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    QJsonObject m_completeJsonObject;
    QJsonObject m_lastRecordObject, m_lastRecordKeeper;
    entitiesComponents m_recordedEntitiesComponents;
    TimerTemplateQtPtr m_lastRecordTimeout;
};

#endif // VEINDATACOLLECTOR_H
