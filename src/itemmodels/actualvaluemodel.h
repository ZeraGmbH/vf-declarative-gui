#ifndef ACTUALVALUEMODEL_H
#define ACTUALVALUEMODEL_H

#include "zeragluelogic.h"
#include <QStandardItemModel>

class ActualValueModel : public ZeraGlueLogicItemModelBase
{
public:
    ActualValueModel(int t_rows, int t_columns, QObject *t_parent);
    virtual ~ActualValueModel() override;
    void setupTable() override;
    // QAbstractItemModel interface
public:
    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUEMODEL_H
