#ifndef ACTUALVALUEACSUMMODEL_H
#define ACTUALVALUEACSUMMODEL_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"

class ActualValueAcSumModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueAcSumModel();
    virtual ~ActualValueAcSumModel() override;

    void setLabelsAndUnits() override;
    void setupMapping() override;

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
