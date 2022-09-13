#ifndef BURDENVALUEMODEL_H
#define BURDENVALUEMODEL_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"

class BurdenValueModel : public TableEventItemModelBase
{
public:
    BurdenValueModel(Modules modulVeinId, QObject *t_parent);
    virtual ~BurdenValueModel() override;

    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
private:
    Modules m_modulVeinId;
};

#endif // BURDENVALUEMODEL_H
