#include "tableeventitemmodelbase.h"

QSet<TableEventItemModelBase*> TableEventItemModelBase::m_setAllBaseModels;

TableEventItemModelBase::TableEventItemModelBase(int t_rows, int t_columns) :
    QStandardItemModel(t_rows, t_columns),
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
    int row = valueCoordiates.y();
    int column = valueCoordiates.x(); // (role)
    QVariant newValue = cData->newValue();
    QModelIndex mIndex = index(row, 0);
    if(m_rowsToAutoScale.contains(valueCoordiates.y())) {
        const TLineScaleEntry &scaleEntry = m_rowsToAutoScale[row];
        if(scaleEntry.roleIndicesValues.contains(column) ||
           scaleEntry.roleIndexSum == column) {
            m_unscaledOrigValues[row][column] = newValue;
            scaleRow(row);
            return;
        }
    }
    setData(mIndex, newValue, column);
}

void TableEventItemModelBase::addAutoScaleRow(int row, int roleIndexUnit, QList<int> roleIndicesValues, int roleIndexSum)
{
    m_rowsToAutoScale[row].roleIndexUnit = roleIndexUnit;
    m_rowsToAutoScale[row].roleIndicesValues = roleIndicesValues;
    m_rowsToAutoScale[row].roleIndexSum = roleIndexSum;
}

void TableEventItemModelBase::setBaseUnit(int row, QString baseUnit)
{
    if(m_rowsToAutoScale.contains(row)) {
        m_rowsToAutoScale[row].baseUnit = baseUnit;
        scaleRow(row);
    }
}

void TableEventItemModelBase::scaleRow(int row)
{
    QModelIndex mIndex = index(row, 0);

    // No scale yet
    int unitColumn = m_rowsToAutoScale[row].roleIndexUnit;
    QString unit = m_rowsToAutoScale[row].baseUnit;
    setData(mIndex, unit, unitColumn);

    QHash<int, QVariant> unscaledOrigValues = m_unscaledOrigValues[row];
    for(auto iter = unscaledOrigValues.constBegin(); iter != unscaledOrigValues.constEnd(); ++iter) {
        QVariant val = iter.value();
        int column = iter.key();
        setData(mIndex, val, column);
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
