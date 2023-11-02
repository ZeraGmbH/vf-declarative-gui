#ifndef ACTUALVALUEMODELBASE_H
#define ACTUALVALUEMODELBASE_H

#include "tableeventitemmodelbase.h"

class ActualValueModelBase : public TableEventItemModelBase
{
    Q_OBJECT
public:
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    ActualValueModelBase(bool withAuxColumsInAutoScale);
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;

private:
    void insertMeasMode(int yCoordinate, QString measMode);
    void insertPowerName(int yCoordinate, QString measMode);
    void insertPowerUnit(int yCoordinate, QString measUnit);
    void updateMModeTranslations();
    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};
    QHash<int, QString> m_dynamicPowerName = {{10, ""}, {11, ""}, {12, ""}};
    QHash<int, QString> m_dynamicPowerUnit = {{10, ""}, {11, ""}, {12, ""}};
    bool m_withAuxColumsInAutoScale;
};

#endif // ACTUALVALUEMODELBASE_H
