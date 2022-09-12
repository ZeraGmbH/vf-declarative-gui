#ifndef ACTUALVALUE4THPHASEDCMODEL_H
#define ACTUALVALUE4THPHASEDCMODEL_H

#include "vfeventdispatcher.h"
#include "tableeventitemmodelbase.h"

class ActualValue4thPhaseDcModel : public TableEventItemModelBase
{
public:
    ActualValue4thPhaseDcModel(QObject *t_parent);
    virtual ~ActualValue4thPhaseDcModel() override;

    void setupTable() override;
    void setupMapping() override;
    void updateTranslation() override;

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

#endif // ACTUALVALUE4THPHASEDCMODEL_H
