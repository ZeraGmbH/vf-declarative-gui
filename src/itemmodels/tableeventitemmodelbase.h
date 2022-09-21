#ifndef TABLEEVNTITEMMODELBASE_H
#define TABLEEVNTITEMMODELBASE_H

#include <zeratranslation.h>
#include <vcmp_componentdata.h>
#include <QStandardItemModel>

class TableEventItemModelBase : public QStandardItemModel
{
    Q_OBJECT
public:
    TableEventItemModelBase(int t_rows, int t_columns);
    virtual ~TableEventItemModelBase();
    virtual void setLabelsAndUnits() = 0;
    virtual void setupMapping() = 0;
    void handleComponentChange(const VeinComponent::ComponentData *cData);

    static QList<TableEventItemModelBase*> getAllBaseModels();
    QHash<int, QHash<QString, QPoint>*> getValueMapping();
protected:
    virtual void handleComponentChangeCoord(const VeinComponent::ComponentData *, const QPoint);

    QHash<int, QHash<QString, QPoint>*> m_valueMapping;
    ZeraTranslation *m_translation = nullptr;
private:
    static QSet<TableEventItemModelBase*> m_setAllBaseModels;
};

#endif // TABLEEVNTITEMMODELBASE_H
