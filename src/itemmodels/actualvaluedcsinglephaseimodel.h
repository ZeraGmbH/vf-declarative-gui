#ifndef ACTUALVALUEDCSINGLEPHASEIMODEL_H
#define ACTUALVALUEDCSINGLEPHASEIMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueDCSinglePhaseIModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueDCSinglePhaseIModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUEDCSINGLEPHASEIMODEL_H
