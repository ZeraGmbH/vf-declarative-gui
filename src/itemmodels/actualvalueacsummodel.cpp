#include "actualvalueacsummodel.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueAcSumModel::ActualValueAcSumModel(QObject *t_parent) :
    ZeraGlueLogicItemModelBase(lineVal(LINE_COUNT), 1, t_parent)
{
}

ActualValueAcSumModel::~ActualValueAcSumModel()
{
}

void ActualValueAcSumModel::setupTable()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "U [V]", RoleIndexes::DC_U);
    setData(mIndex, "I [A]", RoleIndexes::DC_I);
    setData(mIndex, "P [W]", RoleIndexes::DC_P);
    // 1st line / 1st column
    mIndex = index(lineVal(LINE_VALUES), 0);
    setData(mIndex, "DC", RoleIndexes::Name);
}

void ActualValueAcSumModel::setupMapping()
{
    QHash<QString, QPoint> *rmsMap = new QHash<QString, QPoint>();
    rmsMap->insert("ACT_RMSPN7", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES)));
    rmsMap->insert("ACT_RMSPN8", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES)));

    QHash<QString, QPoint> *p1m4Map = new QHash<QString, QPoint>();
    p1m4Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES)));

    m_valueMapping.insert(static_cast<int>(Modules::RmsModule), rmsMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module4), p1m4Map);
}

void ActualValueAcSumModel::updateTranslation()
{
    updateMModeTranslations();
}

QHash<int, QByteArray> ActualValueAcSumModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::Name, "Name");
    roles.insert(RoleIndexes::DC_U, "DC_U");
    roles.insert(RoleIndexes::DC_I, "DC_I");
    roles.insert(RoleIndexes::DC_P, "DC_P");
    return roles;
}

void ActualValueAcSumModel::insertMeasMode(int yCoordinate, QString measMode)
{
    Q_UNUSED(yCoordinate)
    Q_UNUSED(measMode)
}

void ActualValueAcSumModel::updateMModeTranslations()
{
}
