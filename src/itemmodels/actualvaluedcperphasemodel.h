#ifndef ACTUALVALUEDCPERPHASEMODEL_H
#define ACTUALVALUEDCPERPHASEMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueDCPerPhaseModel : public TableEventItemModelBase
{
public:
    ActualValueDCPerPhaseModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
private:
    enum RoleIndexes
    {
        NAME=Qt::UserRole+1,
        DC_U,
        DC_I,
        DC_P
    };
};

#endif // ACTUALVALUEDCPERPHASEMODEL_H
