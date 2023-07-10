#ifndef OSCIMODEL_H
#define OSCIMODEL_H

#include "tableeventitemmodelbase.h"

class OsciModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    OsciModel(QStringList componentNames);
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    void handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates) override;
private:
    QStringList m_componentNames;
};

#endif // OSCIMODEL_H
