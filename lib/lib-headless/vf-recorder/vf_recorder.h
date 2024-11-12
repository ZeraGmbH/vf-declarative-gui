#ifndef VF_RECORDER_H
#define VF_RECORDER_H

#include "veindatacollector.h"
#include <QObject>

class Vf_Recorder : public QObject
{
    Q_OBJECT
public:
    explicit Vf_Recorder(VeinStorage::AbstractEventSystem* storageSystem, QObject *parent = nullptr);
    void startLogging(int storageNum, QJsonObject inputJson);
    void stopLogging(int storageNum);
    QJsonObject getStoredValues(int storageNum);

signals:
    void newStoredValues(int storageNumber, QJsonObject value);

private:
    void readJson(QJsonObject jsonValue, int storageNum);
    QHash<int, QStringList> extractEntitiesAndComponents(QJsonObject jsonObject);
    void ignoreComponents(QStringList *componentList);
    bool prepareTimeRecording();
    VeinStorage::AbstractEventSystem* m_storageSystem;

    QList<VeinDataCollector*> m_dataCollect;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
};

#endif // VF_RECORDER_H
