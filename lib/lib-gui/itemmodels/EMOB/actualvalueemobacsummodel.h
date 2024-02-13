#ifndef ACTUALVALUEACSUMMODEL_H
#define ACTUALVALUEACSUMMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueEmobAcSumModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueEmobAcSumModel();

    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;

private:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
    enum RoleIndexes
    {
        NAME=Qt::UserRole+1,
        SUM_P,
        SUM_LAMDA,
        SUM_LAMDA_LOAD_TYPE,
        FREQ
    };
    RowAutoScaler m_autoScalerP;
};

#endif // ACTUALVALUEACSUMMODEL_H
