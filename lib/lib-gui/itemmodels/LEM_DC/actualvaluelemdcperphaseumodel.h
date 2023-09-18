#ifndef ACTUALVALUEDCPERPHASEUMODEL_H
#define ACTUALVALUEDCPERPHASEUMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueLemDCPerPhaseUModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueLemDCPerPhaseUModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUEDCPERPHASEUMODEL_H
