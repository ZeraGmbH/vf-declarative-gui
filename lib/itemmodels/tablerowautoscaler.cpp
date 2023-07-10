#include "tablerowautoscaler.h"

TableRowAutoScaler::TableRowAutoScaler(QStandardItemModel *itemModel) :
    m_itemModel(itemModel)
{
}

void TableRowAutoScaler::addAutoScaleRow(int row, int roleIndexUnit, QList<int> roleIdxSingleValues, int roleIndexSum)
{
    m_rowsToAutoScale[row].roleIndexUnit = roleIndexUnit;
    m_rowsToAutoScale[row].roleIdxSingleValues = roleIdxSingleValues;
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
        if(scaleEntry.roleIdxSingleValues.contains(columnRole) || scaleEntry.roleIndexSum == columnRole) {
            QVariant newValue = cData->newValue();
            m_rowScalers[row].setUnscaledValue(columnRole, newValue);
            scaleRow(row);
            return true;
        }
    }
    return false;
}

void TableRowAutoScaler::scaleRow(int row)
{
    RowAutoScaler::TRowScaleResult res;
    res = m_rowScalers[row].scaleRow(m_rowsToAutoScale[row].baseUnit, m_rowsToAutoScale[row].roleIdxSingleValues);

    QModelIndex mIndex = m_itemModel->index(row, 0);
    int unitColumn = m_rowsToAutoScale[row].roleIndexUnit;
    m_itemModel->setData(mIndex, res.scaledUnit, unitColumn);

    for(auto iter = res.scaledColumnValues.constBegin(); iter != res.scaledColumnValues.constEnd(); ++iter) {
        QVariant val = iter.value();
        int columnRole = iter.key();
        m_itemModel->setData(mIndex, val, columnRole);
    }
}
