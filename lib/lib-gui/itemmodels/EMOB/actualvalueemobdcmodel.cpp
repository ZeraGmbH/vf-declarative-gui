#include "actualvalueemobdcmodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueEmobDcModel::ActualValueEmobDcModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueEmobDcModel::setLabelsAndUnits()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "DC", RoleIndexes::NAME);
    setData(mIndex, "U [V]", RoleIndexes::DC_U);
    setData(mIndex, "I [A]", RoleIndexes::DC_I);
    setData(mIndex, "P [W]", RoleIndexes::DC_P);
}

void ActualValueEmobDcModel::setupMapping()
{
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_DC7", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES)));
    fftMap->insert("ACT_DC8", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES)));

    QHash<QString, QPoint> *p1m4Map = new QHash<QString, QPoint>();
    p1m4Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES)));

    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module4), p1m4Map);
}

QHash<int, QByteArray> ActualValueEmobDcModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "NAME");
    roles.insert(RoleIndexes::DC_U, "DC_U");
    roles.insert(RoleIndexes::DC_I, "DC_I");
    roles.insert(RoleIndexes::DC_P, "DC_P");
    return roles;
}

void ActualValueEmobDcModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    RowAutoScaler::TSingleScaleResult singleResult;
    int columnRole = 0;
    QString headerText;
    double unscaledValue = cData->newValue().toDouble();

    if(valueCoordiates == QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES))) {
        columnRole = RoleIndexes::DC_U;
        singleResult = m_autoScalerU.scaleSingleVal(unscaledValue);
        headerText = QString("U [%1V]").arg(singleResult.unitPrefix);
    }
    else if(valueCoordiates == QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES))) {
        columnRole = RoleIndexes::DC_I;
        singleResult = m_autoScalerI.scaleSingleVal(unscaledValue);
        headerText = QString("I [%1A]").arg(singleResult.unitPrefix);
    }
    else if(valueCoordiates == QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES))) {
        columnRole = RoleIndexes::DC_P;
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
