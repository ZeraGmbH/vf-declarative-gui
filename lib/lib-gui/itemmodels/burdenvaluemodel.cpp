#include "burdenvaluemodel.h"

BurdenValueModel::BurdenValueModel(Modules modulVeinId) :
    TableEventItemModelBase(7, 1),
    m_modulVeinId(modulVeinId)
{
}

void BurdenValueModel::setLabelsAndUnits()
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

    // unit names
    mIndex = index(1, 0);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "V", RoleIndexes::UNIT);
    mIndex = index(2, 0);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "A", RoleIndexes::UNIT);
    mIndex = index(3, 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    mIndex = index(4, 0);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "VA", RoleIndexes::UNIT);
    mIndex = index(6, 0);
    setData(mIndex, "%", RoleIndexes::UNIT);
}

void BurdenValueModel::setupMapping()
{
    using namespace CommonTable;

    QHash<QString, QPoint> *rmsMap = new QHash<QString, QPoint>();
    rmsMap->insert("ACT_RMSPN1", QPoint(RoleIndexes::L1, 1));
    rmsMap->insert("ACT_RMSPN2", QPoint(RoleIndexes::L2, 1));
    rmsMap->insert("ACT_RMSPN3", QPoint(RoleIndexes::L3, 1));
    m_autoScaleRows.mapValueColumns(1,
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3);

    rmsMap->insert("ACT_RMSPN4", QPoint(RoleIndexes::L1, 2));
    rmsMap->insert("ACT_RMSPN5", QPoint(RoleIndexes::L2, 2));
    rmsMap->insert("ACT_RMSPN6", QPoint(RoleIndexes::L3, 2));
    m_autoScaleRows.mapValueColumns(2,
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3);

    //(3) ∠UI is a calculated value - see TableEventConsumer::setAngleUI
    QHash<QString, QPoint> *dftMap = new QHash<QString, QPoint>();
    dftMap->insert("CALC_ANGLEDIFF1", QPoint(RoleIndexes::L1, 3));
    dftMap->insert("CALC_ANGLEDIFF2", QPoint(RoleIndexes::L2, 3));
    dftMap->insert("CALC_ANGLEDIFF3", QPoint(RoleIndexes::L3, 3));

    QHash<QString, QPoint> *burdenMap = new QHash<QString, QPoint>();
    burdenMap->insert("ACT_Burden1", QPoint(RoleIndexes::L1, 4));
    burdenMap->insert("ACT_Burden2", QPoint(RoleIndexes::L2, 4));
    burdenMap->insert("ACT_Burden3", QPoint(RoleIndexes::L3, 4));
    m_autoScaleRows.mapValueColumns(4,
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3);

    burdenMap->insert("ACT_PFactor1", QPoint(RoleIndexes::L1, 5));
    burdenMap->insert("ACT_PFactor2", QPoint(RoleIndexes::L2, 5));
    burdenMap->insert("ACT_PFactor3", QPoint(RoleIndexes::L3, 5));

    burdenMap->insert("ACT_Ratio1", QPoint(RoleIndexes::L1, 6));
    burdenMap->insert("ACT_Ratio2", QPoint(RoleIndexes::L2, 6));
    burdenMap->insert("ACT_Ratio3", QPoint(RoleIndexes::L3, 6));

    m_valueMapping.insert(static_cast<int>(Modules::RmsModule), rmsMap);
    m_valueMapping.insert(static_cast<int>(Modules::DftModule), dftMap);
    m_valueMapping.insert(static_cast<int>(m_modulVeinId), burdenMap);

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
