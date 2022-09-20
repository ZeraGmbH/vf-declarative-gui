#ifndef ACTUALVALUEDCPERPHASEUMODEL_H
#define ACTUALVALUEDCPERPHASEUMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueDCPerPhaseUModel : public TableEventItemModelBase
{
public:
    ActualValueDCPerPhaseUModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
private:
};

#endif // ACTUALVALUEDCPERPHASEUMODEL_H
