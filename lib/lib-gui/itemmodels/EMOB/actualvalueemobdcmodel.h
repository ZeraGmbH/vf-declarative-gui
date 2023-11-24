#ifndef ACTUALVALUEDCMODEL_H
#define ACTUALVALUEDCMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueEmobDcModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueEmobDcModel();

    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
private:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
    enum RoleIndexes
    {
        NAME=Qt::UserRole+1,
        DC_U,
        DC_I,
        DC_P
    };
    RowAutoScaler m_autoScalerU;
    RowAutoScaler m_autoScalerI;
    RowAutoScaler m_autoScalerP;
};

#endif // ACTUALVALUEDCMODEL_H
