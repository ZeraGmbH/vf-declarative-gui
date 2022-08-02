#include "zeragluelogicitemmodelbase.h"

ZeraGlueLogicItemModelBase::ZeraGlueLogicItemModelBase(int t_rows, int t_columns, QObject *t_parent) :
    QStandardItemModel(t_rows, t_columns, t_parent),
    m_translation(ZeraTranslation::getInstance())
{
}

ZeraGlueLogicItemModelBase::~ZeraGlueLogicItemModelBase()
{
    for(auto point : qAsConst(m_valueMapping)) {
        delete point;
    }
}

QHash<int, QHash<QString, QPoint> *> ZeraGlueLogicItemModelBase::getValueMapping()
{
    return m_valueMapping;
}
