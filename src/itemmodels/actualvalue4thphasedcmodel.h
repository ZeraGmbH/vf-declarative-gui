#ifndef ACTUALVALUE4THPHASEDCMODEL_H
#define ACTUALVALUE4THPHASEDCMODEL_H

#include "zeragluelogic.h"
#include <QStandardItemModel>

class ActualValue4thPhaseDcModel : public ZeraGlueLogicItemModelBase
{
public:
    ActualValue4thPhaseDcModel(QObject *t_parent);
    virtual ~ActualValue4thPhaseDcModel() override;

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

#endif // ACTUALVALUE4THPHASEDCMODEL_H
