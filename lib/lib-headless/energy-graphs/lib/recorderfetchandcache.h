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
        int msSinceStart;
        EntitiesData entitiesData;
    };

    explicit RecorderFetchAndCache(VeinStorage::AbstractEventSystem* clientStorage, VfCmdEventHandlerSystemPtr cmdEventHandlerSystem);
    static RecorderFetchAndCache* getInstance();
    static void deleteInstance();
    const QList<TimestampData> &getData() const;
    const QList<TimestampData> &getReducedData() const;
signals:
    void sigNewValuesAdded(int startIdx, int postEndIdx);
    void sigClearedValues();
    void sigTimeLastValue(int msSinceStart);

private slots:
    void onRecorderEntryCountChange(QVariant value);
    void onStartStopChange(QVariant value);
    void onRpcFinish(bool ok);
    void onInterpolatedRpcFinish(bool ok);
private:
    void appendRecordedValuesFromRpc(const QJsonObject &values);
    void appendInterpolatedData(const QJsonObject &values);
    void clearCache();
    void init();

    VeinStorage::AbstractEventSystem* m_clientStorage;
    VfCmdEventHandlerSystemPtr m_cmdEventHandlerSystem;

    QList<TimestampData> m_cache;
    QList<TimestampData> m_reducedCache;

    VeinStorage::AbstractComponentPtr m_entryCountComponent;
    VeinStorage::AbstractComponentPtr m_entryStartStopComponent;
    VeinStorage::AbstractComponentPtr m_entryVeinSessionNameComponent;
    TaskContainerInterfacePtr m_taskQueue;
    std::shared_ptr<bool> m_rpcSuccessful;
    std::shared_ptr<QVariant> m_result;
    std::shared_ptr<QString> m_errorMsg;
    std::shared_ptr<bool> m_interpolatedRpcSuccessful;
    std::shared_ptr<QVariant> m_interpolatedRpcResult;
    std::shared_ptr<QString> m_interpolatedRpcErrorMsg;
};

#endif // RECORDERFETCHANDCACHE_H
