#ifndef BURDENVALUEMODEL_H
#define BURDENVALUEMODEL_H

#include "tableeventdistributor.h"
#include "zeragluelogicitemmodelbase.h"

class BurdenValueModel : public ZeraGlueLogicItemModelBase
{
public:
    BurdenValueModel(Modules modulVeinId, QObject *t_parent);
    virtual ~BurdenValueModel() override;

    void setupTable() override;
    void setupMapping() override;
    void updateTranslation() override;

    QHash<int, QByteArray> roleNames() const override;
private:
    Modules m_modulVeinId;
};

#endif // BURDENVALUEMODEL_H
