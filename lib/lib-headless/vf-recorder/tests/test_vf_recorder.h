#ifndef TEST_VF_RECORDER_H
#define TEST_VF_RECORDER_H

#include "vf_recorder.h"
#include "ve_eventhandler.h"
#include "vs_storageeventsystem.h"
#include <memory>
#include <QObject>

class test_vf_recorder : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void init();
    void cleanup();

    void storeValuesBasedOnNoEntitiesInJson();
    void storeValuesBasedOnNonexistingEntitiesInJson();
    void storeValuesEmptyComponentsInJson();
    void doNotStoreSigMeasuringNotAvailable();
    void loggingOnOffSequence0();
    void loggingOnOffSequence1();
    void stopLoggingHasNoSideEffectOnOtherConnections();
    void fireActualValuesAfterDelayWhileLogging();
    void fireRmsPowerValuesAfterDifferentDelaysWhileLogging();
private:
    void createMinimalRangeRmsModules();
    void changeComponentValue(int entityId, QString componentName, QVariant newValue);
    void createModule(int entityId, QMap<QString, QVariant> components);
    void triggerRangeModuleSigMeasuring();

    QJsonObject readEntitiesAndCompoFromJsonFile(QString filePath);
    void startLoggingFromJson(QString fileName, int storageNum);
    void stopLogging(int storageNum);
    QJsonObject getStoredValueWithoutTimeStamp(int storageNum);
    QHash<QString, QVariant> getComponentsStoredOfEntity(int entityId, QJsonObject storedValueWithoutTimeStamp);
    QString getValuesStoredOfComponent(QHash<QString, QVariant> componentHash, QString componentName);

    QString msAfterEpoch(qint64 msecs);

    std::unique_ptr<VeinEvent::EventHandler> m_eventHandler;
    std::unique_ptr<Vf_Recorder> m_recorder;
    std::shared_ptr<VeinStorage::StorageEventSystem> m_storageEventSystem;
};

#endif // TEST_VF_RECORDER_H
