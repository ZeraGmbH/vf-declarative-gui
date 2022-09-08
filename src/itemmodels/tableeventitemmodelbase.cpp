#include "tableeventitemmodelbase.h"

QSet<TableEventItemModelBase*> TableEventItemModelBase::m_setAllBaseModels;

TableEventItemModelBase::TableEventItemModelBase(int t_rows, int t_columns, QObject *t_parent) :
    QStandardItemModel(t_rows, t_columns, t_parent),
    m_translation(ZeraTranslation::getInstance())
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
    QModelIndex mIndex = index(valueCoordiates.y(), 0);
    setData(mIndex, cData->newValue(), valueCoordiates.x());
}

QList<TableEventItemModelBase *> TableEventItemModelBase::getAllBaseModels()
{
    return m_setAllBaseModels.values();
}

QHash<int, QHash<QString, QPoint> *> TableEventItemModelBase::getValueMapping()
{
    return m_valueMapping;
}