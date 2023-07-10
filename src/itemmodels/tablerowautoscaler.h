#ifndef TABLEROWAUTOSCALER_H
#define TABLEROWAUTOSCALER_H

#include "rowautoscaler.h"
#include <vcmp_componentdata.h>
#include <QList>
#include <QHash>
#include <QVariant>
#include <QStandardItemModel>

class TableRowAutoScaler
{
public:
    TableRowAutoScaler(QStandardItemModel* itemModel);
    void addAutoScaleRow(int row, int roleIndexUnit, QList<int> roleIdxSingleValues, int roleIndexSum = 0);
    void setBaseUnit(int row, QString baseUnit);
    bool handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates);
private:
    void scaleRow(int row);
    QStandardItemModel *m_itemModel;
    struct TLineScaleEntry
    {
        int roleIndexUnit;
        QList<int> roleIdxSingleValues;
        int roleIndexSum;
        QString baseUnit;
    };
    QHash<int, TLineScaleEntry> m_rowsToAutoScale;
    QHash<int, RowAutoScaler> m_rowScalers;
};

#endif // TABLEROWAUTOSCALER_H
