#include "lineseriesfiller.h"
#include "recorderfetchandcache.h"

LineSeriesFiller::LineSeriesFiller(QObject *parent)
    : QObject{parent}
{
    connect(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigNewValuesAdded,
            this, &LineSeriesFiller::onNewValuesAdded);
    connect(RecorderFetchAndCache::getInstance(), &RecorderFetchAndCache::sigClearedValues,
            this, &LineSeriesFiller::onClearedValues);
}

void LineSeriesFiller::setLineSeries(QObject *lineSeries)
{
    m_lineSeries = qobject_cast<QtCharts::QLineSeries*>(lineSeries);
}

void LineSeriesFiller::setEntityId(int entityId)
{
    m_entityId = entityId;
}

void LineSeriesFiller::setComponentName(QString componentName)
{
    m_componentName = componentName;
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
