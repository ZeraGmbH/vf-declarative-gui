#include "actualvaluelemdcsingleimodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_VALUE_I,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueLemDcSingleIModel::ActualValueLemDcSingleIModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueLemDcSingleIModel::setLabelsAndUnits()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(lineVal(LINE_VALUE_I), 0);
    setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "A", RoleIndexes::UNIT);
}

void ActualValueLemDcSingleIModel::setupMapping()
{
    using namespace CommonTable;
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_DC8", QPoint(RoleIndexes::AUX, lineVal(LINE_VALUE_I)));
    m_autoScaleRows.mapValueColumns(lineVal(LINE_VALUE_I),
                    QList<int>() << RoleIndexes::AUX);
    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
}

QHash<int, QByteArray> ActualValueLemDcSingleIModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::AUX, "AUX");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}
