#ifndef ACTUALVALUEACSUMMODEL_H
#define ACTUALVALUEACSUMMODEL_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"

class ActualValueEmobAcSumModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueEmobAcSumModel();
    virtual ~ActualValueEmobAcSumModel() override;

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
        FREQ
    };
    RowAutoScaler m_autoScalerP;
};

#endif // ACTUALVALUEACSUMMODEL_H
