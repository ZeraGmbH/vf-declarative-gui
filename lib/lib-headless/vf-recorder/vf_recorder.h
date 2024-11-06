#ifndef VF_RECORDER_H
#define VF_RECORDER_H

#include "veindatacollector.h"
#include <vf-cpp-entity.h>
#include <vf-cpp-compproxy.h>
#include <QObject>

class Vf_Recorder : public QObject
{
    Q_OBJECT
public:
    explicit Vf_Recorder(VeinStorage::AbstractEventSystem* storageSystem, QObject *parent = nullptr, int entityId = 1);
    bool initOnce();
    VfCpp::VfCppEntity *getVeinEntity() const;

private:
    void startStopLogging(QVariant value, int storageNum);
    void readJson(QVariant value, int storageNum);
    QHash<int, QStringList> extractEntitiesAndComponents(QJsonObject jsonObject);
    void ignoreComponents(QStringList *componentList);
    void prepareTimeRecording();
    VeinStorage::AbstractEventSystem* m_storageSystem;
    VfCpp::VfCppEntity *m_entity;
    bool m_isInitalized;
    VfCpp::VfCppComponent::Ptr m_maximumLoggingComponents;
    QList<VfCpp::VfCppComponent::Ptr> m_storedValues;
    QList<VfCpp::VfCppComponent::Ptr> m_JsonWithEntities;
    QList<VfCpp::VfCppComponent::Ptr> m_startStopLogging;

    QList<VeinDataCollector*> m_dataCollect; //unique ptr ?
    VeinStorage::TimeStamperSettablePtr m_timeStamper;
};

#endif // VF_RECORDER_H
