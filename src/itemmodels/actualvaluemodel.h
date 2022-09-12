#ifndef ACTUALVALUEMODEL_H
#define ACTUALVALUEMODEL_H

#include "vfeventdispatcher.h"
#include "tableeventitemmodelbase.h"

class ActualValueModel : public TableEventItemModelBase
{
public:
    ActualValueModel(QObject *t_parent);
    virtual ~ActualValueModel() override;

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

#endif // ACTUALVALUEMODEL_H
