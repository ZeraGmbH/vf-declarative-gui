#ifndef RECORDERFETCHANDCACHE_H
#define RECORDERFETCHANDCACHE_H

#include <taskcontainerinterface.h>
#include <vf_cmd_event_handler_system.h>
#include <vs_abstracteventsystem.h>
#include <QDateTime>
#include <QList>

class RecorderFetchAndCache : public QObject
{
    Q_OBJECT
public:
    typedef QMap<QString /*componentname*/, float /*value*/> SingleEntityData;
    typedef QMap<int /*entityId*/, SingleEntityData> EntitiesData;
    struct TimestampData {
        QDateTime timeStamp;
        EntitiesData entitiesData;
    };

    explicit RecorderFetchAndCache(VeinStorage::AbstractEventSystem* clientStorage, VfCmdEventHandlerSystemPtr cmdEventHandlerSystem);
    static RecorderFetchAndCache* getInstance();
    static void deleteInstance();
    const QList<TimestampData> &getData() const;
signals:
    void sigNewValuesAdded(int startIdx, int postEndIdx);
    void sigClearedValues();

private slots:
    void onRecorderEntryCountChange(QVariant value);
    void onStartStopChange(QVariant value);
    void onRpcFinish(bool ok);
private:
    void appendRecordedValuesFromRpc(const QJsonObject &values);
    void clearCache();
    void init();
    static QString getDateTimeConvertStr();
    static QDateTime getDateTime(const QString &timeStamp);

    VeinStorage::AbstractEventSystem* m_clientStorage;
    VfCmdEventHandlerSystemPtr m_cmdEventHandlerSystem;

    QList<TimestampData> m_cache;
    VeinStorage::StorageComponentPtr m_entryCountComponent;
    VeinStorage::StorageComponentPtr m_entryStartStopComponent;
    VeinStorage::StorageComponentPtr m_entryVeinSessionNameComponent;
    TaskContainerInterfacePtr m_taskQueue;
    std::shared_ptr<bool> m_rpcSuccessful;
    std::shared_ptr<QVariant> m_result;
    std::shared_ptr<QString> m_errorMsg;
};

#endif // RECORDERFETCHANDCACHE_H
