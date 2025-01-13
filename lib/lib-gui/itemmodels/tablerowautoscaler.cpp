#include "tablerowautoscaler.h"

TableRowAutoScaler::TableRowAutoScaler(QStandardItemModel *itemModel) :
    m_itemModel(itemModel)
{
}

TableRowAutoScaler::~TableRowAutoScaler()
{
    for(int i = 0; i <  m_rowScalers.size(); i++)
        delete m_rowScalers[i];
    m_rowScalers.clear();
}

void TableRowAutoScaler::setUnitInfo(int row, QString baseUnit, int roleIndexUnit)
{
    m_rowsToAutoScale[row].roleIndexUnit = roleIndexUnit;
    m_rowsToAutoScale[row].baseUnit = baseUnit;
    m_rowScalers[row] = new RowAutoScaler();
    scaleRow(row);
}

void TableRowAutoScaler::mapValueColumns(int row, QList<int> roleIdxSingleValues, int roleIndexSum)
{
    m_rowsToAutoScale[row].roleIdxSingleValues = roleIdxSingleValues;
    m_rowsToAutoScale[row].roleIndexSum = roleIndexSum;
}

void TableRowAutoScaler::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    int row = valueCoordiates.y();
    int columnRole = valueCoordiates.x();
    QVariant newValue = cData->newValue();
    if(m_rowsToAutoScale.contains(row)) {
        const TLineScaleEntry &scaleEntry = m_rowsToAutoScale[row];
        if(scaleEntry.roleIdxSingleValues.contains(columnRole) || scaleEntry.roleIndexSum == columnRole) {
            m_rowScalers[row]->setUnscaledValue(columnRole, newValue);
            scaleRow(row);
        }
    }
    else { //
        QModelIndex mIndex = m_itemModel->index(row, 0);
        m_itemModel->setData(mIndex, newValue, columnRole);
    }
}

void TableRowAutoScaler::scaleRow(int row)
{
    RowAutoScaler::TRowScaleResult res;
    res = m_rowScalers[row]->scaleRow(m_rowsToAutoScale[row].baseUnit, m_rowsToAutoScale[row].roleIdxSingleValues);

    QModelIndex mIndex = m_itemModel->index(row, 0);
    int unitColumn = m_rowsToAutoScale[row].roleIndexUnit;
    m_itemModel->setData(mIndex, res.scaledUnit, unitColumn);

    for(auto iter = res.scaledColumnValues.constBegin(); iter != res.scaledColumnValues.constEnd(); ++iter) {
        QVariant val = iter.value();
        int columnRole = iter.key();
        m_itemModel->setData(mIndex, val, columnRole);
    }
}
