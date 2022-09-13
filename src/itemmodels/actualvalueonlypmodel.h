#ifndef ACTUALVALUEONLYPMODEL_H
#define ACTUALVALUEONLYPMODEL_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"

class ActualValueOnlyPModel : public TableEventItemModelBase
{
public:
    ActualValueOnlyPModel();
    virtual ~ActualValueOnlyPModel() override;

    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;

private:
    void insertMeasMode(int yCoordinate, QString measMode);
    void updateMModeTranslations();
    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};
};

#endif // ACTUALVALUEONLYPMODEL_H
