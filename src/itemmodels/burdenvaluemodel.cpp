#include "burdenvaluemodel.h"

BurdenValueModel::BurdenValueModel(int t_rows, int t_columns, QObject *t_parent) :
    ZeraGlueLogicItemModelBase(t_rows, t_columns, t_parent)
{
}

BurdenValueModel::~BurdenValueModel()
{
}

void BurdenValueModel::setupTable()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(0, 0);
    setData(mIndex, m_translation->TrValue("BRD1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("BRD2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("BRD3"), RoleIndexes::L3);
    setData(mIndex, "[ ]", RoleIndexes::UNIT);

    mIndex = index(1, 0);
    setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
    mIndex = index(2, 0);
    setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
    mIndex = index(3, 0);
    setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
    mIndex = index(4, 0);
    setData(mIndex, m_translation->TrValue("Sb"), RoleIndexes::NAME);
    mIndex = index(5, 0);
    setData(mIndex, m_translation->TrValue("cos(β)"), RoleIndexes::NAME);
    mIndex = index(6, 0);
    setData(mIndex, m_translation->TrValue("Sn"), RoleIndexes::NAME);

    //unit names
    mIndex = index(1, 0);
    setData(mIndex, "V", RoleIndexes::UNIT);
    mIndex = index(2, 0);
    setData(mIndex, "A", RoleIndexes::UNIT);
    mIndex = index(3, 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    //mIndex = m_burdenData->index(4, 0);
    //m_burdenData->setData(mIndex, "", RoleIndexes::UNIT);
    mIndex = index(4, 0);
    setData(mIndex, "VA", RoleIndexes::UNIT);
    mIndex = index(6, 0);
    setData(mIndex, "%", RoleIndexes::UNIT);
}

void BurdenValueModel::updateTranslation()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(0, 0);
    setData(mIndex, m_translation->TrValue("BRD1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("BRD2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("BRD3"), RoleIndexes::L3);
    setData(mIndex, "[ ]", RoleIndexes::UNIT);

    mIndex = index(1, 0);
    setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
    mIndex = index(2, 0);
    setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
    mIndex = index(3, 0);
    setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
    mIndex = index(4, 0);
    setData(mIndex, m_translation->TrValue("Sb"), RoleIndexes::NAME);
    mIndex = index(5, 0);
    setData(mIndex, m_translation->TrValue("cos(β)"), RoleIndexes::NAME);
    mIndex = index(6, 0);
    setData(mIndex, m_translation->TrValue("Sn"), RoleIndexes::NAME);
}

QHash<int, QByteArray> BurdenValueModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::L1, "L1");
    roles.insert(RoleIndexes::L2, "L2");
    roles.insert(RoleIndexes::L3, "L3");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}
