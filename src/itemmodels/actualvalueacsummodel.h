#ifndef ACTUALVALUEACSUMMODEL_H
#define ACTUALVALUEACSUMMODEL_H

#include "zeragluelogic.h"
#include "zeragluelogicitemmodelbase.h"

class ActualValueAcSumModel : public ZeraGlueLogicItemModelBase
{
public:
    ActualValueAcSumModel(QObject *t_parent);
    virtual ~ActualValueAcSumModel() override;

    void setupTable() override;
    void setupMapping() override;
    void updateTranslation() override;

    QHash<int, QByteArray> roleNames() const override;

private:
    enum RoleIndexes
    {
        NAME=Qt::UserRole+1,
        SUM_P,
        SUM_LAMDA,
        FREQ
    };
};

#endif // ACTUALVALUEACSUMMODEL_H
