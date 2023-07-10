#include "actualvaluelemdcperphaseumodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES_U,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueLemDCPerPhaseUModel::ActualValueLemDCPerPhaseUModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueLemDCPerPhaseUModel::setLabelsAndUnits()
{
    using namespace CommonTable;

    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
    setData(mIndex, m_translation->TrValue("AUX"), RoleIndexes::AUX);

    mIndex = index(lineVal(LINE_VALUES_U), 0);
    setData(mIndex, m_translation->TrValue("U"), RoleIndexes::NAME);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "V", RoleIndexes::UNIT);
}

void ActualValueLemDCPerPhaseUModel::setupMapping()
{
    using namespace CommonTable;
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_DC1", QPoint(RoleIndexes::L1, lineVal(LINE_VALUES_U)));
    fftMap->insert("ACT_DC2", QPoint(RoleIndexes::L2, lineVal(LINE_VALUES_U)));
    fftMap->insert("ACT_DC3", QPoint(RoleIndexes::L3, lineVal(LINE_VALUES_U)));
    fftMap->insert("ACT_DC7", QPoint(RoleIndexes::AUX, lineVal(LINE_VALUES_U)));
    m_autoScaleRows.mapValueColumns(lineVal(LINE_VALUES_U),
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3 << RoleIndexes::AUX);
    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
}

QHash<int, QByteArray> ActualValueLemDCPerPhaseUModel::roleNames() const
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
