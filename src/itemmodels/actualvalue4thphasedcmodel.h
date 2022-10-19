#ifndef ACTUALVALUE4THPHASEDCMODEL_H
#define ACTUALVALUE4THPHASEDCMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValue4thPhaseDcModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValue4thPhaseDcModel();

    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
private:
    enum RoleIndexes
    {
        NAME=Qt::UserRole+1,
        DC_U,
        DC_I,
        DC_P
    };
};

#endif // ACTUALVALUE4THPHASEDCMODEL_H
