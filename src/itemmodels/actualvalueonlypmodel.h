#ifndef ACTUALVALUEONLYPMODEL_H
#define ACTUALVALUEONLYPMODEL_H

#include "tableeventdistributor.h"
#include "zeragluelogicitemmodelbase.h"

class ActualValueOnlyPModel : public ZeraGlueLogicItemModelBase
{
public:
    ActualValueOnlyPModel(QObject *t_parent);
    virtual ~ActualValueOnlyPModel() override;

    void setupTable() override;
    void setupMapping() override;
    void updateTranslation() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;

private:
    void insertMeasMode(int yCoordinate, QString measMode);
    void updateMModeTranslations();
    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};
};

#endif // ACTUALVALUEONLYPMODEL_H
