#ifndef POWERVALUEMODEL_H
#define POWERVALUEMODEL_H

#include "tableeventitemmodelbase.h"

class PowerValueModel : public TableEventItemModelBase
{
public:
    PowerValueModel();

    void setLabelsAndUnits() override;
    void setupMapping() override;
    QHash<int, QByteArray> roleNames() const;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
private:
    void insertPowerName(int yCoordinate, QString measName);
    void insertPowerUnit(int yCoordinate, QString measUnit);
    void updateMModeTranslations();
    QHash<int, QString> m_dynamicPowerName = {{1, ""}, {2, ""}, {3, ""}};
    QHash<int, QString> m_dynamicPowerUnit = {{1, ""}, {2, ""}, {3, ""}};
};

#endif // POWERVALUEMODEL_H
