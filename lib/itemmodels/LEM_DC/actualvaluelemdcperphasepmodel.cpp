#include "actualvaluelemdcperphasepmodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_VALUE_P,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueLemDcPerPhasePModel::ActualValueLemDcPerPhasePModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueLemDcPerPhasePModel::setLabelsAndUnits()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(lineVal(LINE_VALUE_P), 0);
    setData(mIndex, m_translation->TrValue("P"), RoleIndexes::NAME);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "W", RoleIndexes::UNIT);
}

void ActualValueLemDcPerPhasePModel::setupMapping()
{
    using namespace CommonTable;
    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, lineVal(LINE_VALUE_P)));
    QHash<QString, QPoint> *p1m2Map = new QHash<QString, QPoint>();
    p1m2Map->insert("ACT_PQS1", QPoint(RoleIndexes::L2, lineVal(LINE_VALUE_P)));
    QHash<QString, QPoint> *p1m3Map = new QHash<QString, QPoint>();
    p1m3Map->insert("ACT_PQS1", QPoint(RoleIndexes::L3, lineVal(LINE_VALUE_P)));
    QHash<QString, QPoint> *p1m4Map = new QHash<QString, QPoint>();
    p1m4Map->insert("ACT_PQS1", QPoint(RoleIndexes::AUX, lineVal(LINE_VALUE_P)));
    m_autoScaleRows.mapValueColumns(lineVal(LINE_VALUE_P),
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3 << RoleIndexes::AUX);

    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module2), p1m2Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module3), p1m3Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module4), p1m4Map);
}

QHash<int, QByteArray> ActualValueLemDcPerPhasePModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::L1, "L1");
    roles.insert(RoleIndexes::L2, "L2");
    roles.insert(RoleIndexes::L3, "L3");
    roles.insert(RoleIndexes::AUX, "AUX");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}
