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
    void setUnitInfo(int row, QString baseUnit, int roleIndexUnit);
    void mapValueColumns(int row, QList<int> roleIdxSingleValues, int roleIndexSum = 0);
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates);
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
