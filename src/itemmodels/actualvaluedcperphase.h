#ifndef ACTUALVALUEDCPERPHASE_H
#define ACTUALVALUEDCPERPHASE_H

#include "tableeventitemmodelbase.h"

class ActualValueDCPerPhase : public TableEventItemModelBase
{
public:
    ActualValueDCPerPhase();
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

#endif // ACTUALVALUEDCPERPHASE_H
