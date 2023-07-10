#include "tablerowautoscaler.h"

TableRowAutoScaler::TableRowAutoScaler(QStandardItemModel *itemModel) :
    m_itemModel(itemModel)
{
}

void TableRowAutoScaler::addAutoScaleRow(int row, int roleIndexUnit, QList<int> roleIndicesValues, int roleIndexSum)
{
    m_rowsToAutoScale[row].roleIndexUnit = roleIndexUnit;
    m_rowsToAutoScale[row].roleIndicesValues = roleIndicesValues;
    m_rowsToAutoScale[row].roleIndexSum = roleIndexSum;
}

void TableRowAutoScaler::setBaseUnit(int row, QString baseUnit)
{
    if(m_rowsToAutoScale.contains(row)) {
        m_rowsToAutoScale[row].baseUnit = baseUnit;
        scaleRow(row);
    }
}

bool TableRowAutoScaler::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    int row = valueCoordiates.y();
    if(m_rowsToAutoScale.contains(row)) {
        const TLineScaleEntry &scaleEntry = m_rowsToAutoScale[row];
        int columnRole = valueCoordiates.x();
        if(scaleEntry.roleIndicesValues.contains(columnRole) || scaleEntry.roleIndexSum == columnRole) {
            QVariant newValue = cData->newValue();
            m_unscaledOrigValues[row][columnRole] = newValue;
            scaleRow(row);
            return true;
        }
    }
    return false;
}

void TableRowAutoScaler::scaleRow(int row)
{
    QModelIndex mIndex = m_itemModel->index(row, 0);

    // No scale yet
    int unitColumn = m_rowsToAutoScale[row].roleIndexUnit;
    QString unit = m_rowsToAutoScale[row].baseUnit;
    m_itemModel->setData(mIndex, unit, unitColumn);

    QHash<int, QVariant> unscaledOrigValues = m_unscaledOrigValues[row];
    for(auto iter = unscaledOrigValues.constBegin(); iter != unscaledOrigValues.constEnd(); ++iter) {
        QVariant val = iter.value();
        int columnRole = iter.key();
        m_itemModel->setData(mIndex, val, columnRole);
    }
}
