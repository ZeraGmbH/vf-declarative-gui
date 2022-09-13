#include "actualvalueacsummodel.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueAcSumModel::ActualValueAcSumModel(QObject *t_parent) :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1, t_parent)
{
}

ActualValueAcSumModel::~ActualValueAcSumModel()
{
}

void ActualValueAcSumModel::setLabelsAndUnits()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "P [W]", RoleIndexes::SUM_P);
    setData(mIndex, "λ", RoleIndexes::SUM_LAMDA);
    setData(mIndex, "F [Hz]", RoleIndexes::FREQ);
    mIndex = index(lineVal(LINE_VALUES), 0);
    setData(mIndex, "Σ", RoleIndexes::NAME);
}

void ActualValueAcSumModel::setupMapping()
{
    QHash<QString, QPoint> *lambdaMap = new QHash<QString, QPoint>();
    lambdaMap->insert("ACT_Lambda4", QPoint(RoleIndexes::SUM_LAMDA, lineVal(LINE_VALUES)));
    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM_P, lineVal(LINE_VALUES)));
    QHash<QString, QPoint> *rangeMap  = new QHash<QString, QPoint>();
    rangeMap->insert("ACT_Frequency", QPoint(RoleIndexes::FREQ, lineVal(LINE_VALUES)));

    m_valueMapping.insert(static_cast<int>(Modules::LambdaModule), lambdaMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_valueMapping.insert(static_cast<int>(Modules::RangeModule), rangeMap);
}

QHash<int, QByteArray> ActualValueAcSumModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "NAME");
    roles.insert(RoleIndexes::SUM_P, "SUM_P");
    roles.insert(RoleIndexes::SUM_LAMDA, "SUM_LAMDA");
    roles.insert(RoleIndexes::FREQ, "FREQ");
    return roles;
}
