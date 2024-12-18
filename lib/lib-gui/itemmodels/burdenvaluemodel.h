#ifndef BURDENVALUEMODEL_H
#define BURDENVALUEMODEL_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"

class BurdenValueModel : public TableEventItemModelBase
{
    Q_OBJECT
public:
    void setLabelsAndUnits() override;
    void setupMapping() override;

    QHash<int, QByteArray> roleNames() const override;
protected:
    BurdenValueModel(Modules modulVeinId);
private:
    Modules m_modulVeinId;
};

#endif // BURDENVALUEMODEL_H
