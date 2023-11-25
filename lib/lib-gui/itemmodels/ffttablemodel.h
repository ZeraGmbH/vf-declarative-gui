#ifndef FFTTABLEMODEL_H
#define FFTTABLEMODEL_H

#include "vfcomponenteventdispatcher.h"
#include <QStandardItemModel>

class FftTableModel : public QStandardItemModel
{
    Q_OBJECT
public:
    FftTableModel(int t_rows, int t_columns, QObject *t_parent);
    virtual ~FftTableModel() override;
    static constexpr int ampAngleOffset = 100;
public:
    QHash<int, QByteArray> roleNames() const override;
    enum RoleIndexes
    {
        AMP_L1=Qt::UserRole+1,
        AMP_L2,
        AMP_L3,
        AMP_L4,
        AMP_L5,
        AMP_L6,
        AMP_L7,
        AMP_L8,
        VECTOR_L1 = AMP_L1 + ampAngleOffset,
        VECTOR_L2,
        VECTOR_L3,
        VECTOR_L4,
        VECTOR_L5,
        VECTOR_L6,
        VECTOR_L7,
        VECTOR_L8,
    };
};

#endif // FFTTABLEMODEL_H
