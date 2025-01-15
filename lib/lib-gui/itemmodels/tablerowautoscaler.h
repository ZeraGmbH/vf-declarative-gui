#ifndef TABLEROWAUTOSCALER_H
#define TABLEROWAUTOSCALER_H

#include "rowautoscaler.h"
#include <vcmp_componentdata.h>
#include <QList>
#include <QHash>
#include <QVariant>
#include <QStandardItemModel>
#include <memory>
#include <unordered_map>

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
    std::unordered_map<int, std::unique_ptr<RowAutoScaler>> m_rowScalers;
};

#endif // TABLEROWAUTOSCALER_H
