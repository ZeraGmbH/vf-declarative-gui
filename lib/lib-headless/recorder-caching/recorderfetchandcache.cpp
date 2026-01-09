#include "recorderfetchandcache.h"
#include <taskcontainerqueue.h>
#include <task_client_rpc_invoker.h>
#include <QJsonObject>

constexpr int systemEntityId = 0;
constexpr int recorderEntityId = 1800;

RecorderFetchAndCache::RecorderFetchAndCache(VeinStorage::AbstractEventSystem *clientStorage,
                                             VfCmdEventHandlerSystemPtr cmdEventHandlerSystem) :
    m_clientStorage(clientStorage),
    m_cmdEventHandlerSystem(cmdEventHandlerSystem),
    m_entryCountComponent(m_clientStorage->getDb()->getFutureComponent(recorderEntityId, "ACT_Points")),
    m_entryStartStopComponent(m_clientStorage->getDb()->getFutureComponent(recorderEntityId, "PAR_StartStopRecording")),
    m_entryVeinSessionNameComponent(m_clientStorage->getDb()->getFutureComponent(systemEntityId, "Session")),
    m_taskQueue(TaskContainerQueue::create()),
    m_rpcSuccessful(std::make_shared<bool>()),
    m_result(std::make_shared<QVariant>()),
    m_errorMsg(std::make_shared<QString>())
{
    connect(m_entryCountComponent.get(), &VeinStorage::AbstractComponent::sigValueChange,
            this, &RecorderFetchAndCache::onRecorderEntryCountChange);
    connect(m_entryStartStopComponent.get(), &VeinStorage::AbstractComponent::sigValueChange, [&](QVariant value) {
        if(value == true)
            clearCache();
    });
    connect(m_entryVeinSessionNameComponent.get(), &VeinStorage::AbstractComponent::sigValueChange, [&]() {
        clearCache();
    });
}

void RecorderFetchAndCache::onRecorderEntryCountChange(QVariant value)
{
    bool ok;
    int newCount = value.toInt(&ok);
    if (!ok) {
        qWarning("RecorderFetchAndCache::onRecorderEntryCountChange: cannot convert value");
        return;
    }
    QVariantMap parameters;
    parameters.insert("p_startingPoint", int(m_cache.size()));
    parameters.insert("p_endingPoint", newCount);
    TaskTemplatePtr task = TaskClientRPCInvoker::create(recorderEntityId,
                                                        "RPC_ReadRecordedValues", parameters,
                                                        m_rpcSuccessful, m_result, m_errorMsg,
                                                        m_cmdEventHandlerSystem, 2000);
    connect(task.get(), &TaskTemplate::sigFinish,
            this, &RecorderFetchAndCache::onRpcFinish);
    m_taskQueue->addSub(std::move(task));
}

void RecorderFetchAndCache::onRpcFinish(bool ok)
{
    if(ok && *m_rpcSuccessful == true)
        appendRecordedValuesFromRpc(m_result->toJsonObject());
}

const QList<RecorderFetchAndCache::TimestampData> &RecorderFetchAndCache::getData() const
{
    return m_cache;
}

void RecorderFetchAndCache::appendRecordedValuesFromRpc(const QJsonObject &values)
{
    if (values.size() > 0) {
        int start = m_cache.size();
        for (auto iterTimestamp=values.constBegin(); iterTimestamp!=values.constEnd(); ++iterTimestamp) {
            const QString timeStampStr = iterTimestamp.key();
            const QDateTime timeStamp = getDateTime(timeStampStr);
            const QJsonObject entitiesDataJson = iterTimestamp.value().toObject();

            EntitiesData entitiesData;
            for (auto iterEntities = entitiesDataJson.constBegin(); iterEntities!=entitiesDataJson.constEnd(); ++iterEntities) {
                const QString entityIdStr = iterEntities.key();
                bool convOk = false;
                int entityId = entityIdStr.toInt(&convOk);
                if (!convOk) {
                    qWarning("Entity ID %s is not a number!", qPrintable(entityIdStr));
                    continue;
                }
                const QJsonObject entityDataJson = iterEntities.value().toObject();
                SingleEntityData entityData;
                for (auto iterComponents = entityDataJson.constBegin(); iterComponents!=entityDataJson.constEnd(); ++iterComponents) {
                    const QString componentName = iterComponents.key();
                    entityData[componentName] = iterComponents.value().toDouble();
                }
                entitiesData[entityId] = entityData;
            }
            m_cache.append({timeStamp, entitiesData});
        }
        emit sigNewValuesAdded(start, m_cache.size());
    }
}

void RecorderFetchAndCache::clearCache()
{
    if(!m_cache.isEmpty()) {
        m_cache.clear();
        emit sigClearedValues();
    }
}

QString RecorderFetchAndCache::getDateTimeConvertStr()
{
    return "dd-MM-yyyy hh:mm:ss.zzz";
}

QDateTime RecorderFetchAndCache::getDateTime(const QString &timeStamp)
{
    return QDateTime::fromString(timeStamp, getDateTimeConvertStr());
}
