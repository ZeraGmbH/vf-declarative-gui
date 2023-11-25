#ifndef ACTUALVALUEONLYPMODEL_H
#define ACTUALVALUEONLYPMODEL_H

#include "tableeventitemmodelbase.h"

class ActualValueEmobAcModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    ActualValueEmobAcModel();
    virtual ~ActualValueEmobAcModel() override;

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
