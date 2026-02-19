#include "recorderfetchandcache.h"
#include <taskcontainerqueue.h>
#include <task_client_rpc_invoker.h>
#include <QJsonObject>

static RecorderFetchAndCache* m_instance = nullptr;
constexpr int systemEntityId = 0;
constexpr int recorderEntityId = 1800;

RecorderFetchAndCache::RecorderFetchAndCache(VeinStorage::AbstractEventSystem *clientStorage,
                                             VfCmdEventHandlerSystemPtr cmdEventHandlerSystem) :
    m_clientStorage(clientStorage),
    m_cmdEventHandlerSystem(cmdEventHandlerSystem),
    m_entryVeinSessionNameComponent(m_clientStorage->getDb()->getFutureComponent(systemEntityId, "Session")),
    m_taskQueue(TaskContainerQueue::create()),
    m_rpcSuccessful(std::make_shared<bool>()),
    m_result(std::make_shared<QVariant>()),
    m_errorMsg(std::make_shared<QString>()),
    m_interpolatedRpcSuccessful(std::make_shared<bool>()),
    m_interpolatedRpcResult(std::make_shared<QVariant>()),
    m_interpolatedRpcErrorMsg(std::make_shared<QString>())
{
    Q_ASSERT(m_instance == nullptr);
    m_instance = this;

    init();
    connect(m_entryVeinSessionNameComponent.get(), &VeinStorage::AbstractComponent::sigValueChange, [&](QVariant sessionName) {
        if(!sessionName.toString().isEmpty()) {
            init();
        }
        clearCache();
    });
}

RecorderFetchAndCache *RecorderFetchAndCache::getInstance()
{
    return m_instance;
}

void RecorderFetchAndCache::deleteInstance()
{
    delete m_instance;
    m_instance = nullptr;
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

    TaskTemplatePtr taskInterpolatedRpc = TaskClientRPCInvoker::create(recorderEntityId,
                                                              "RPC_GetRecordedDataSampler", QVariantMap(),
                                                               m_interpolatedRpcSuccessful, m_interpolatedRpcResult, m_interpolatedRpcErrorMsg,
                                                               m_cmdEventHandlerSystem, 2000);
    connect(task.get(), &TaskTemplate::sigFinish,
            this, &RecorderFetchAndCache::onInterpolatedRpcFinish);

    m_taskQueue->addSub(std::move(task));
    m_taskQueue->addSub(std::move(taskInterpolatedRpc));
}

void RecorderFetchAndCache::onStartStopChange(QVariant value)
{
    if(value == true)
        clearCache();
}

void RecorderFetchAndCache::onRpcFinish(bool ok)
{
    if(ok && *m_rpcSuccessful == true)
        appendRecordedValuesFromRpc(m_result->toJsonObject());
}

void RecorderFetchAndCache::onInterpolatedRpcFinish(bool ok)
{
    if(ok && *m_interpolatedRpcSuccessful == true)
        appendInterpolatedData(m_interpolatedRpcResult->toJsonObject());
}

const QList<RecorderFetchAndCache::TimestampData> &RecorderFetchAndCache::getData() const
{
    return m_cache;
}

void RecorderFetchAndCache::appendRecordedValuesFromRpc(const QJsonObject &values)
{
    if (values.size() > 0) {
        int start = m_cache.size();
        int lastTimestamp = 0;
        for (auto iterTimestamp=values.constBegin(); iterTimestamp!=values.constEnd(); ++iterTimestamp) {
            const QString timeStampStr = iterTimestamp.key();
            lastTimestamp = timeStampStr.toInt();
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
            m_cache.append({lastTimestamp, entitiesData});
        }
        emit sigNewValuesAdded(start, m_cache.size());
        emit sigTimeLastValue(lastTimestamp);
    }
}

const QList<RecorderFetchAndCache::TimestampData> &RecorderFetchAndCache::getReducedData() const
{
    return m_reducedCache;
}

void RecorderFetchAndCache::appendInterpolatedData(const QJsonObject &values)
{
    if (values.size() > 0) {
        m_reducedCache.clear();
        int lastTimestamp = 0;
        for (auto iterTimestamp=values.constBegin(); iterTimestamp!=values.constEnd(); ++iterTimestamp) {
            const QString timeStampStr = iterTimestamp.key();
            lastTimestamp = timeStampStr.toInt();
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
            m_reducedCache.append({lastTimestamp, entitiesData});
        }
    }
}

void RecorderFetchAndCache::clearCache()
{
    if(!m_reducedCache.isEmpty())
        m_reducedCache.clear();
    if(!m_cache.isEmpty()) {
        m_cache.clear();
        emit sigClearedValues();
    }
}

void RecorderFetchAndCache::init()
{
    m_entryCountComponent = m_clientStorage->getDb()->getFutureComponent(recorderEntityId, "ACT_Points");
    m_entryStartStopComponent = m_clientStorage->getDb()->getFutureComponent(recorderEntityId, "PAR_StartStopRecording");
    connect(m_entryCountComponent.get(), &VeinStorage::AbstractComponent::sigValueChange,
            this, &RecorderFetchAndCache::onRecorderEntryCountChange, Qt::UniqueConnection);
    connect(m_entryStartStopComponent.get(), &VeinStorage::AbstractComponent::sigValueChange,
            this, &RecorderFetchAndCache::onStartStopChange, Qt::UniqueConnection);
}
