#include "actualvaluemodel.h"

ActualValueModel::ActualValueModel(int t_rows, int t_columns, QObject *t_parent) :
    ZeraGlueLogicItemModelBase(t_rows, t_columns, t_parent)
{
}

ActualValueModel::~ActualValueModel()
{
}

void ActualValueModel::setupTable()
{
    using namespace CommonTable;
    //column names
    QModelIndex mIndex = index(0, 0);
    setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
    setData(mIndex, m_translation->TrValue("AUX"), RoleIndexes::AUX);
    setData(mIndex, "Σ", RoleIndexes::SUM);
    setData(mIndex, "[ ]", RoleIndexes::UNIT);

    //row names
    //mIndex = index(0, 0); //none
    mIndex = index(1, 0);
    setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
    mIndex = index(2, 0);
    setData(mIndex, m_translation->TrValue("UPP"), RoleIndexes::NAME);
    mIndex = index(3, 0);
    setData(mIndex, m_translation->TrValue("∠U"), RoleIndexes::NAME);
    mIndex = index(4, 0);
    setData(mIndex, m_translation->TrValue("kU"), RoleIndexes::NAME);
    mIndex = index(5, 0);
    setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
    mIndex = index(6, 0);
    setData(mIndex, m_translation->TrValue("∠I"), RoleIndexes::NAME);
    mIndex = index(7, 0);
    setData(mIndex, m_translation->TrValue("kI"), RoleIndexes::NAME);
    mIndex = index(8, 0);
    setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
    mIndex = index(9, 0);
    setData(mIndex, m_translation->TrValue("λ"), RoleIndexes::NAME);
    mIndex = index(10, 0);
    setData(mIndex, m_translation->TrValue("P"), RoleIndexes::NAME);
    mIndex = index(11, 0);
    setData(mIndex, m_translation->TrValue("Q"), RoleIndexes::NAME);
    mIndex = index(12, 0);
    setData(mIndex, m_translation->TrValue("S"), RoleIndexes::NAME);
    mIndex = index(13, 0);
    setData(mIndex, m_translation->TrValue("F"), RoleIndexes::NAME);

    //unit names
    mIndex = index(1, 0);
    setData(mIndex, "V", RoleIndexes::UNIT);
    mIndex = index(2, 0);
    setData(mIndex, "V", RoleIndexes::UNIT);
    mIndex = index(3, 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    mIndex = index(4, 0);
    setData(mIndex, "%", RoleIndexes::UNIT);
    mIndex = index(5, 0);
    setData(mIndex, "A", RoleIndexes::UNIT);
    mIndex = index(6, 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    mIndex = index(7, 0);
    setData(mIndex, "%", RoleIndexes::UNIT);
    mIndex = index(8, 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    //mIndex = index(9, 0); //none
    mIndex = index(10, 0);
    setData(mIndex, "W", RoleIndexes::UNIT);
    mIndex = index(11, 0);
    setData(mIndex, "VAR", RoleIndexes::UNIT);
    mIndex = index(12, 0);
    setData(mIndex, "VA", RoleIndexes::UNIT);
    mIndex = index(13, 0);
    setData(mIndex, "Hz", RoleIndexes::UNIT);
}

QHash<int, QByteArray> ActualValueModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::L1, "L1");
    roles.insert(RoleIndexes::L2, "L2");
    roles.insert(RoleIndexes::L3, "L3");
    roles.insert(RoleIndexes::AUX, "AUX");
    roles.insert(RoleIndexes::SUM, "Sum");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}
