#ifndef ACTUALVALUEDCPERPHASEUMODEL_H
#define ACTUALVALUEDCPERPHASEUMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueDCPerPhaseUModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueDCPerPhaseUModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUEDCPERPHASEUMODEL_H
