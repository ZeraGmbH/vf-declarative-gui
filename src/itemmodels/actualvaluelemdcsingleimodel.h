#ifndef ACTUALVALUELEMDCSINGLEIMODEL_H
#define ACTUALVALUELEMDCSINGLEIMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueLemDcSingleIModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueLemDcSingleIModel();
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // ACTUALVALUELEMDCSINGLEIMODEL_H
