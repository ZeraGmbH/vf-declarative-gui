#ifndef ACTUALVALUEDCPERPHASEPMODEL_H
#define ACTUALVALUEDCPERPHASEPMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueLemDcPerPhasePModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueLemDcPerPhasePModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUEDCPERPHASEPMODEL_H
