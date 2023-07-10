#include "tableeventitemmodelbase.h"

QSet<TableEventItemModelBase*> TableEventItemModelBase::m_setAllBaseModels;

TableEventItemModelBase::TableEventItemModelBase(int t_rows, int t_columns) :
    QStandardItemModel(t_rows, t_columns),
    m_translation(ZeraTranslation::getInstance()),
    m_autoScaleRows(this)
{
    m_setAllBaseModels.insert(this);
}

TableEventItemModelBase::~TableEventItemModelBase()
{
    for(auto point : qAsConst(m_valueMapping)) {
        delete point;
    }
    m_setAllBaseModels.remove(this);
}

void TableEventItemModelBase::handleComponentChange(const VeinComponent::ComponentData *cData)
{
    const auto mapping = m_valueMapping.value(cData->entityId(), nullptr);
    if(mapping) {
        auto iter = mapping->constFind(cData->componentName());
        if(iter != mapping->constEnd()) {
            const QPoint valueCoordiates = iter.value();
            handleComponentChangeCoord(cData, valueCoordiates);
        }
    }
}

void TableEventItemModelBase::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    if(!m_autoScaleRows.handleComponentChangeCoord(cData, valueCoordiates)) {
        int row = valueCoordiates.y();
        int columnRole = valueCoordiates.x();
        QVariant newValue = cData->newValue();
        QModelIndex mIndex = index(row, 0);
        setData(mIndex, newValue, columnRole);
    }
}

QList<TableEventItemModelBase *> TableEventItemModelBase::getAllBaseModels()
{
    return m_setAllBaseModels.values();
}

QHash<int, QHash<QString, QPoint> *> TableEventItemModelBase::getValueMapping()
{
    return m_valueMapping;
}
