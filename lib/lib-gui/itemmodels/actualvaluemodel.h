#ifndef ACTUALVALUEMODEL_H
#define ACTUALVALUEMODEL_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"

class ActualValueModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueModel();
    virtual ~ActualValueModel() override;

    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;

private:
    void insertMeasMode(int yCoordinate, QString measMode);
    void insertPowerName(int yCoordinate, QString measMode);
    void insertPowerUnit(int yCoordinate, QString measUnit);
    void updateMModeTranslations();
    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};
    QHash<int, QString> m_dynamicPowerName = {{10, ""}, {11, ""}, {12, ""}};
    QHash<int, QString> m_dynamicPowerUnit = {{10, ""}, {11, ""}, {12, ""}};
};

#endif // ACTUALVALUEMODEL_H
