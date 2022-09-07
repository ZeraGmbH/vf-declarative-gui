#ifndef ACTUALVALUEACSUMMODEL_H
#define ACTUALVALUEACSUMMODEL_H

#include "tableeventdistributor.h"
#include "tableeventitemmodelbase.h"

class ActualValueAcSumModel : public TableEventItemModelBase
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
