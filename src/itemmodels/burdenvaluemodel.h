#ifndef BURDENVALUEMODEL_H
#define BURDENVALUEMODEL_H

#include "zeragluelogic.h"

class BurdenValueModel : public ZeraGlueLogicItemModelBase
{
public:
    BurdenValueModel(int t_rows, int t_columns, QObject *t_parent);
    virtual ~BurdenValueModel() override;

    void setupTable() override;
    void updateTranslation() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // BURDENVALUEMODEL_H
