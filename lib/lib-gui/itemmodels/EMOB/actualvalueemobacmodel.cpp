#include "actualvalueemobacmodel.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_UPN,
    LINE_UANGLE,
    LINE_I,
    LINE_IANGLE,
    LINE_POWER,
    LINE_LAMBDA,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueEmobAcModel::ActualValueEmobAcModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

ActualValueEmobAcModel::~ActualValueEmobAcModel()
{
}

void ActualValueEmobAcModel::setLabelsAndUnits()
{
    using namespace CommonTable;
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, m_translation->TrValue("AC"), RoleIndexes::NAME);
    setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
    setData(mIndex, "[ ]", RoleIndexes::UNIT);

    // 1st column: row names
    mIndex = index(lineVal(LINE_UPN), 0);
    setData(mIndex, m_translation->TrValue("U"), RoleIndexes::NAME);
    mIndex = index(lineVal(LINE_UANGLE), 0);
    setData(mIndex, m_translation->TrValue("∠U"), RoleIndexes::NAME);
    mIndex = index(lineVal(LINE_I), 0);
    setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
    mIndex = index(lineVal(LINE_IANGLE), 0);
    setData(mIndex, m_translation->TrValue("∠I"), RoleIndexes::NAME);
    mIndex = index(lineVal(LINE_LAMBDA), 0);
    setData(mIndex, m_translation->TrValue("λ"), RoleIndexes::NAME);
    mIndex = index(lineVal(LINE_POWER), 0);
    setData(mIndex, m_translation->TrValue("P"), RoleIndexes::NAME);

    // last column unit names
    mIndex = index(lineVal(LINE_UPN), 0);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "V", RoleIndexes::UNIT);
    mIndex = index(lineVal(LINE_UANGLE), 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    mIndex = index(lineVal(LINE_I), 0);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "A", RoleIndexes::UNIT);
    mIndex = index(lineVal(LINE_IANGLE), 0);
    setData(mIndex, "°", RoleIndexes::UNIT);
    mIndex = index(lineVal(LINE_POWER), 0);
    m_autoScaleRows.setUnitInfo(mIndex.row(), "W", RoleIndexes::UNIT);
    //mIndex = index(lineVal(LINE_LAMBDA), 0); //none

    updateMModeTranslations();
}

void ActualValueEmobAcModel::setupMapping()
{
    using namespace CommonTable;
    QHash<QString, QPoint> *rmsMap = new QHash<QString, QPoint>();
    rmsMap->insert("ACT_RMSPN1", QPoint(RoleIndexes::L1, lineVal(LINE_UPN)));
    rmsMap->insert("ACT_RMSPN2", QPoint(RoleIndexes::L2, lineVal(LINE_UPN)));
    rmsMap->insert("ACT_RMSPN3", QPoint(RoleIndexes::L3, lineVal(LINE_UPN)));
    m_autoScaleRows.mapValueColumns(lineVal(LINE_UPN),
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3);

    QHash<QString, QPoint> *dftMap = new QHash<QString, QPoint>();
    dftMap->insert("ACT_DFTPN1", QPoint(RoleIndexes::L1, lineVal(LINE_UANGLE)));
    dftMap->insert("ACT_DFTPN2", QPoint(RoleIndexes::L2, lineVal(LINE_UANGLE)));
    dftMap->insert("ACT_DFTPN3", QPoint(RoleIndexes::L3, lineVal(LINE_UANGLE)));

    rmsMap->insert("ACT_RMSPN4", QPoint(RoleIndexes::L1, lineVal(LINE_I)));
    rmsMap->insert("ACT_RMSPN5", QPoint(RoleIndexes::L2, lineVal(LINE_I)));
    rmsMap->insert("ACT_RMSPN6", QPoint(RoleIndexes::L3, lineVal(LINE_I)));
    m_autoScaleRows.mapValueColumns(lineVal(LINE_I),
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3);

    dftMap->insert("ACT_DFTPN4", QPoint(RoleIndexes::L1, lineVal(LINE_IANGLE)));
    dftMap->insert("ACT_DFTPN5", QPoint(RoleIndexes::L2, lineVal(LINE_IANGLE)));
    dftMap->insert("ACT_DFTPN6", QPoint(RoleIndexes::L3, lineVal(LINE_IANGLE)));

    QHash<QString, QPoint> *lambdaMap = new QHash<QString, QPoint>();
    lambdaMap->insert("ACT_Lambda1", QPoint(RoleIndexes::L1, lineVal(LINE_LAMBDA)));
    lambdaMap->insert("ACT_Lambda2", QPoint(RoleIndexes::L2, lineVal(LINE_LAMBDA)));
    lambdaMap->insert("ACT_Lambda3", QPoint(RoleIndexes::L3, lineVal(LINE_LAMBDA)));

    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("PAR_MeasuringMode", QPoint(RoleIndexes::NAME, lineVal(LINE_POWER)));
    p1m1Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, lineVal(LINE_POWER)));
    p1m1Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, lineVal(LINE_POWER)));
    p1m1Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, lineVal(LINE_POWER)));
    m_autoScaleRows.mapValueColumns(lineVal(LINE_POWER),
                    QList<int>() << RoleIndexes::L1 << RoleIndexes::L2 << RoleIndexes::L3);

    m_valueMapping.insert(static_cast<int>(Modules::RmsModule), rmsMap);
    m_valueMapping.insert(static_cast<int>(Modules::DftModule), dftMap);
    m_valueMapping.insert(static_cast<int>(Modules::LambdaModule), lambdaMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
}

QHash<int, QByteArray> ActualValueEmobAcModel::roleNames() const
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

void ActualValueEmobAcModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    if(cData->componentName() == QLatin1String("PAR_MeasuringMode")) {
        QString newValue = cData->newValue().toString();
        insertMeasMode(valueCoordiates.y(), newValue);
    }
    else {
        TableEventItemModelBase::handleComponentChangeCoord(cData, valueCoordiates);
    }
}

void ActualValueEmobAcModel::insertMeasMode(int yCoordinate, QString measMode)
{
    m_dynamicMeasuringModeDescriptor.insert(yCoordinate, measMode);
    updateMModeTranslations();
}

void ActualValueEmobAcModel::updateMModeTranslations()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(lineVal(LINE_POWER), 0);
    //setData(mIndex, QString("(%1) P").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
    setData(mIndex, "P");
}
