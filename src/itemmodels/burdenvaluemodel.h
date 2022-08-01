#ifndef BURDENVALUEMODEL_H
#define BURDENVALUEMODEL_H

#include "zeragluelogic.h"
#include <QStandardItemModel>

class BurdenValueModel : public QStandardItemModel
{
public:
    BurdenValueModel(int t_rows, int t_columns, QObject *t_parent);
    virtual ~BurdenValueModel() override;
    // QAbstractItemModel interface
public:
    QHash<int, QByteArray> roleNames() const override;
};

#endif // BURDENVALUEMODEL_H
