#ifndef ACTUALVALUEDCSINGLEPHASEIMODEL_H
#define ACTUALVALUEDCSINGLEPHASEIMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueDCSinglePhaseIModel : public TableEventItemModelBase
{
public:
    ActualValueDCSinglePhaseIModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
};

#endif // ACTUALVALUEDCSINGLEPHASEIMODEL_H
