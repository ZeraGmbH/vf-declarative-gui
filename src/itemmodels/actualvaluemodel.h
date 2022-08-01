#ifndef ACTUALVALUEMODEL_H
#define ACTUALVALUEMODEL_H

#include "zeragluelogic.h"
#include <QStandardItemModel>

class ActualValueModel : public ZeraGlueLogicItemModelBase
{
public:
    ActualValueModel(int t_rows, int t_columns, QObject *t_parent);
    virtual ~ActualValueModel() override;
    void setupTable() override;
    void updateTranslation() override;
    void updateMModeTranslations();
    QHash<int, QByteArray> roleNames() const override;

    // All was mixed up in ZeraGlueLogicPrivate. As long as this mess is
    // still tightly coupled, give insert access to m_dynamicMeasuringModeDescriptor
    void insertMeasMode(int yCoordinate, QString measMode);
private:
    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};
};

#endif // ACTUALVALUEMODEL_H
