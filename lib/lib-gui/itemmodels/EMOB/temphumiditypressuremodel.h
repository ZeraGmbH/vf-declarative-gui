#ifndef TEMPHUMIDITYPRESSUREMODEL_H
#define TEMPHUMIDITYPRESSUREMODEL_H

#include "tableeventitemmodelbase.h"

class TempHumidityPressureModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    TempHumidityPressureModel();
    ~TempHumidityPressureModel() override;

    void setLabelsAndUnits() override;
    void setupMapping() override;
    QHash<int, QByteArray> roleNames() const override;

private:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;

    enum RoleIndexes
    {
        Temperature=Qt::UserRole+1,
        Humidity,
        Pressure
    };

};

#endif // TEMPHUMIDITYPRESSUREMODEL_H
