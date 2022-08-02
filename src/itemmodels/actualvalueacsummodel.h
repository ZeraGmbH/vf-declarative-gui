#ifndef ACTUALVALUEACSUMMODEL_H
#define ACTUALVALUEACSUMMODEL_H

#include "zeragluelogic.h"
#include <QStandardItemModel>

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
        Name=Qt::UserRole+1,
        DC_U,
        DC_I,
        DC_P
    };
};

#endif // ACTUALVALUEACSUMMODEL_H
