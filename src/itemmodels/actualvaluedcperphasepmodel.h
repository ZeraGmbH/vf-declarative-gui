#ifndef ACTUALVALUEDCPERPHASEPMODEL_H
#define ACTUALVALUEDCPERPHASEPMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueDCPerPhasePModel : public TableEventItemModelBase
{
public:
    ActualValueDCPerPhasePModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUEDCPERPHASEPMODEL_H
