#ifndef VEINDATACOLLECTOR_H
#define VEINDATACOLLECTOR_H

#include <vs_abstracteventsystem.h>
#include <vs_storagefilter.h>
#include <vs_timestampersettable.h>
#include <timerperiodicqt.h>
#include <QJsonObject>
#include <QDateTime>

class VeinDataCollector : public QObject
{
    Q_OBJECT
public:
    explicit VeinDataCollector(VeinStorage::AbstractEventSystem* storage, VeinStorage::TimeStamperSettablePtr timeSetter);
    void startLogging(QHash<int, QStringList> entitesAndComponents);
    void stopLogging();
signals:
    // Ideas:
    // * replace internal data QJsoonObject by
    //   typedef QHash<int/*entityId*/, QHash<QString/*componentName*/, QVariant/*value*/>> RecordedGroups;
    //   typedef QMap<qint64 /* msSinceEpochTimestamp */, RecordedGroups> TimeStampedGroups;
    // * split up filter / datacollection / periodic vein update into smaller pieces
    void newStoredValue(QJsonObject jsonObject);

private slots:
    void appendValue(int entityId, QString componentName, QVariant value, QDateTime timeStamp);
private:
    QJsonObject convertToJson(QString timestamp, QHash<int, QHash<QString, QVariant> > infosHash);
    QJsonObject convertHashToJsonObject(QHash<QString, QVariant> hash);
    QJsonObject getJsonForTimestamp(QString timestamp);
    QHash<QString, QVariant> appendNewValueToExistingValues(QJsonValue existingValue, QHash<QString, QVariant> compoValuesHash);

    VeinStorage::StorageFilter m_storageFilter;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    QJsonObject m_jsonObject;
    TimerTemplateQtPtr m_periodicTimer;
};

#endif // VEINDATACOLLECTOR_H
