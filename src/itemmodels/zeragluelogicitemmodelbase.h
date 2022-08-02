#ifndef ZERAGLUELOGICITEMMODELBASE_H
#define ZERAGLUELOGICITEMMODELBASE_H

#include <zeratranslation.h>
#include <QStandardItemModel>

class ZeraGlueLogicItemModelBase : public QStandardItemModel
{
public:
    ZeraGlueLogicItemModelBase(int t_rows, int t_columns, QObject *t_parent);
    virtual ~ZeraGlueLogicItemModelBase();
    virtual void setupTable() = 0;
    virtual void setupMapping() = 0;
    virtual void updateTranslation() = 0;
    QHash<int, QHash<QString, QPoint>*> getValueMapping();
protected:
    QHash<int, QHash<QString, QPoint>*> m_valueMapping;
    ZeraTranslation *m_translation = nullptr;
};

#endif // ZERAGLUELOGICITEMMODELBASE_H
