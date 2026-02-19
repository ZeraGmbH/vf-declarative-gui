#include "lineseriesfiller.h"
#include "recorderfetchandcache.h"

LineSeriesFiller::LineSeriesFiller(QObject *parent)
    : QObject{parent}
{
    connect(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigNewValuesAdded,
            this, &LineSeriesFiller::onNewValuesAdded);
    connect(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigClearedValues,
            this, &LineSeriesFiller::onClearedValues);
    connect(this, &LineSeriesFiller::sigTimeLastValue,
            RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigTimeLastValue);
}

void LineSeriesFiller::setLineSeries(QLineSeries *lineSeries)
{
    m_lineSeries = lineSeries;
}

QLineSeries *LineSeriesFiller::getLineSeries() const
{
    return m_lineSeries;
}

void LineSeriesFiller::setEntityId(int entityId)
{
    m_entityId = entityId;
}

int LineSeriesFiller::getEntityId() const
{
    return m_entityId;
}

void LineSeriesFiller::setComponentName(QString componentName)
{
    m_componentName = componentName;
}

QString LineSeriesFiller::getComponentName() const
{
    return m_componentName;
}

void LineSeriesFiller::onNewValuesAdded(int startIdx, int postEndIdx)
{
    QList<RecorderFetchAndCache::TimestampData> cache = RecorderFetchAndCache::getInstance()->getData();
    for(int i = startIdx; i<postEndIdx; i++) {
        RecorderFetchAndCache::TimestampData &cacheEntry = cache[i];
        float value = cacheEntry.entitiesData[m_entityId][m_componentName];
        m_lineSeries->append(float(cacheEntry.msSinceStart)/1000, value);
    }
}

void LineSeriesFiller::onClearedValues()
{
    m_lineSeries->clear();
}

void LineSeriesFiller::appendPoints()
{
    QList<RecorderFetchAndCache::TimestampData> reducedCache = RecorderFetchAndCache::getInstance()->getReducedData();
    if(!reducedCache.isEmpty()) {
        int msSinceStart = 0;
        for(int i = 0; i<reducedCache.size(); i++) {
            RecorderFetchAndCache::TimestampData &cacheEntry = reducedCache[i];
            float value = cacheEntry.entitiesData[m_entityId][m_componentName];
            m_lineSeries->append(float(cacheEntry.msSinceStart)/1000, value);
            msSinceStart = cacheEntry.msSinceStart;
        }
        emit sigTimeLastValue(msSinceStart);
    }
}

