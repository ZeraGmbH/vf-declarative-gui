#include "actualvalueemobacsummodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueEmobAcSumModel::ActualValueEmobAcSumModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueEmobAcSumModel::setLabelsAndUnits()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "P [W]", RoleIndexes::SUM_P);
    setData(mIndex, m_translation->TrValue("λ"), RoleIndexes::SUM_LAMDA);
    setData(mIndex, "F [Hz]", RoleIndexes::FREQ);
    mIndex = index(lineVal(LINE_VALUES), 0);
    setData(mIndex, "Σ", RoleIndexes::NAME);
}

void ActualValueEmobAcSumModel::setupMapping()
{
    QHash<QString, QPoint> *lambdaMap = new QHash<QString, QPoint>();
    lambdaMap->insert("ACT_Lambda4", QPoint(RoleIndexes::SUM_LAMDA, lineVal(LINE_VALUES)));
    lambdaMap->insert("ACT_Load4", QPoint(RoleIndexes::SUM_LAMDA_LOAD_TYPE, lineVal(LINE_VALUES)));
    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM_P, lineVal(LINE_VALUES)));
    QHash<QString, QPoint> *rangeMap  = new QHash<QString, QPoint>();
    rangeMap->insert("ACT_Frequency", QPoint(RoleIndexes::FREQ, lineVal(LINE_VALUES)));

    m_valueMapping.insert(static_cast<int>(Modules::LambdaModule), lambdaMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_valueMapping.insert(static_cast<int>(Modules::RangeModule), rangeMap);
}

QHash<int, QByteArray> ActualValueEmobAcSumModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "NAME");
    roles.insert(RoleIndexes::SUM_P, "SUM_P");
    roles.insert(RoleIndexes::SUM_LAMDA, "SUM_LAMDA");
    roles.insert(RoleIndexes::SUM_LAMDA_LOAD_TYPE, "SUM_LAMDA_LOAD_TYPE");
    roles.insert(RoleIndexes::FREQ, "FREQ");
    return roles;
}

void ActualValueEmobAcSumModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    RowAutoScaler::TSingleScaleResult singleResult;
    int columnRole = 0;
    QString headerText;
    double unscaledValue = cData->newValue().toDouble();
    if(valueCoordiates == QPoint(RoleIndexes::SUM_P, lineVal(LINE_VALUES))) {
        columnRole = RoleIndexes::SUM_P;
        singleResult = m_autoScalerP.scaleSingleVal(unscaledValue);
        headerText = QString("P [%1W]").arg(singleResult.unitPrefix);
    }

    if(columnRole > 0) {
        QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
        setData(mIndex, headerText, columnRole);
        double scaledValue = unscaledValue * singleResult.scaleFactor;
        mIndex = index(lineVal(LINE_VALUES), 0);
        setData(mIndex, scaledValue, columnRole);
    }
    else
        TableEventItemModelBase::handleComponentChangeCoord(cData, valueCoordiates);
}
