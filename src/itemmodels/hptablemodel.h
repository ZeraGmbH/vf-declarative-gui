#ifndef HPTABLEMODEL_H
#define HPTABLEMODEL_H

#include "zeragluelogic.h"
#include <QStandardItemModel>
#include <QTimer>

class HPTableModel : public QStandardItemModel
{
public:
    HPTableModel(int t_rows, int t_columns, QObject *t_parent);
    virtual ~HPTableModel() override;
    // QAbstractItemModel interface
public:
    QHash<int, QByteArray> roleNames() const override;
    enum RoleIndexes
    {
        POWER_S1_P=Qt::UserRole+1,
        POWER_S2_P,
        POWER_S3_P,
        POWER_S1_Q=POWER_S1_P+100,
        POWER_S2_Q,
        POWER_S3_Q,
        POWER_S1_S=POWER_S1_Q+100,
        POWER_S2_S,
        POWER_S3_S,
    };
private:
    QTimer m_dataChangeTimer;
    void setupTimer();
};



#endif // HPTABLEMODEL_H
