#ifndef ACTUALVALUE4THPHASEDCMODEL_H
#define ACTUALVALUE4THPHASEDCMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueEmob4thPhaseDcModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueEmob4thPhaseDcModel();

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

#endif // ACTUALVALUE4THPHASEDCMODEL_H
