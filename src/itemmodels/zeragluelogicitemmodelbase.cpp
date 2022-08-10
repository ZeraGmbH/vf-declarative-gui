#include "zeragluelogicitemmodelbase.h"

QSet<ZeraGlueLogicItemModelBase*> ZeraGlueLogicItemModelBase::m_setAllBaseModels;

ZeraGlueLogicItemModelBase::ZeraGlueLogicItemModelBase(int t_rows, int t_columns, QObject *t_parent) :
    QStandardItemModel(t_rows, t_columns, t_parent),
    m_translation(ZeraTranslation::getInstance())
{
    m_setAllBaseModels.insert(this);
}

ZeraGlueLogicItemModelBase::~ZeraGlueLogicItemModelBase()
{
    for(auto point : qAsConst(m_valueMapping)) {
        delete point;
    }
    m_setAllBaseModels.remove(this);
}

QList<ZeraGlueLogicItemModelBase *> ZeraGlueLogicItemModelBase::getAllBaseModels()
{
    return m_setAllBaseModels.values();
}

QHash<int, QHash<QString, QPoint> *> ZeraGlueLogicItemModelBase::getValueMapping()
{
    return m_valueMapping;
}
