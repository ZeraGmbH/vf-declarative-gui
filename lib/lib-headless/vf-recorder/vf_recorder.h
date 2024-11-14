#ifndef VF_RECORDER_H
#define VF_RECORDER_H

#include "veindatacollector.h"
#include <QObject>

class Vf_Recorder : public QObject
{
    Q_OBJECT
public:
    explicit Vf_Recorder(QObject *parent = nullptr);
    static void setStorageSystem(VeinStorage::AbstractEventSystem *storageSystem);
    static Vf_Recorder *getInstance();

    Q_INVOKABLE void startLogging(int storageNum, QJsonObject inputJson);
    Q_INVOKABLE void stopLogging(int storageNum);
    Q_PROPERTY(QJsonObject storedValues0 READ getStoredValues0 NOTIFY newStoredValues)
    Q_PROPERTY(QJsonObject lastStoredValues0 READ getLastStoredValues0 NOTIFY newStoredValues)
    Q_PROPERTY(QString firstTimestamp0 READ getFirstTimestamp0)

    QJsonObject getStoredValues0();
    QJsonObject getLastStoredValues0();
    QJsonObject getStoredValues(int storageNum);
    QString getFirstTimestamp0();

signals:
    void newStoredValues(int storageNumber);

private:
    void readJson(QJsonObject jsonValue, int storageNum);
    QHash<int, QStringList> extractEntitiesAndComponents(QJsonObject jsonObject);
    void ignoreComponents(QStringList *componentList);
    bool prepareTimeRecording();

    QList<VeinDataCollector*> m_dataCollect;
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
    static Vf_Recorder *instance;
    static VeinStorage::AbstractEventSystem* m_storageSystem;
};

#endif // VF_RECORDER_H
