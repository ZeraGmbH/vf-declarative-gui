#ifndef ACTUALVALUEONLYPMODEL_H
#define ACTUALVALUEONLYPMODEL_H

#include "zeragluelogic.h"
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

    // All was mixed up in ZeraGlueLogicPrivate. As long as this mess is
    // still tightly coupled, give insert access to m_dynamicMeasuringModeDescriptor
    void insertMeasMode(int yCoordinate, QString measMode);
private:
    void updateMModeTranslations();
    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};
};

#endif // ACTUALVALUEONLYPMODEL_H
