#include "actualvalueonlypmodel.h"

ActualValueOnlyPModel::ActualValueOnlyPModel(QObject *t_parent) :
    ZeraGlueLogicItemModelBase(14, 1, t_parent)
{
}

ActualValueOnlyPModel::~ActualValueOnlyPModel()
{
}

void ActualValueOnlyPModel::setupTable()
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

void ActualValueOnlyPModel::setupMapping()
{
    using namespace CommonTable;
    QHash<QString, QPoint> *rmsMap = new QHash<QString, QPoint>();
    rmsMap->insert("ACT_RMSPN1", QPoint(RoleIndexes::L1, 1));
    rmsMap->insert("ACT_RMSPN2", QPoint(RoleIndexes::L2, 1));
    rmsMap->insert("ACT_RMSPN3", QPoint(RoleIndexes::L3, 1));
    rmsMap->insert("ACT_RMSPN7", QPoint(RoleIndexes::AUX, 1));

    rmsMap->insert("ACT_RMSPP1", QPoint(RoleIndexes::L1, 2));
    rmsMap->insert("ACT_RMSPP2", QPoint(RoleIndexes::L2, 2));
    rmsMap->insert("ACT_RMSPP3", QPoint(RoleIndexes::L3, 2));

    QHash<QString, QPoint> *dftMap = new QHash<QString, QPoint>();
    dftMap->insert("ACT_DFTPN1", QPoint(RoleIndexes::L1, 3));
    dftMap->insert("ACT_DFTPN2", QPoint(RoleIndexes::L2, 3));
    dftMap->insert("ACT_DFTPN3", QPoint(RoleIndexes::L3, 3));
    dftMap->insert("ACT_DFTPN7", QPoint(RoleIndexes::AUX, 3));

    QHash<QString, QPoint> *thdnMap = new QHash<QString, QPoint>();
    thdnMap->insert("ACT_THDR1", QPoint(RoleIndexes::L1, 4));
    thdnMap->insert("ACT_THDR2", QPoint(RoleIndexes::L2, 4));
    thdnMap->insert("ACT_THDR3", QPoint(RoleIndexes::L3, 4));

    rmsMap->insert("ACT_RMSPN4", QPoint(RoleIndexes::L1, 5));
    rmsMap->insert("ACT_RMSPN5", QPoint(RoleIndexes::L2, 5));
    rmsMap->insert("ACT_RMSPN6", QPoint(RoleIndexes::L3, 5));
    rmsMap->insert("ACT_RMSPN8", QPoint(RoleIndexes::AUX, 5));

    dftMap->insert("ACT_DFTPN4", QPoint(RoleIndexes::L1, 6));
    dftMap->insert("ACT_DFTPN5", QPoint(RoleIndexes::L2, 6));
    dftMap->insert("ACT_DFTPN6", QPoint(RoleIndexes::L3, 6));
    dftMap->insert("ACT_DFTPN8", QPoint(RoleIndexes::AUX, 6));

    thdnMap->insert("ACT_THDR4", QPoint(RoleIndexes::L1, 7));
    thdnMap->insert("ACT_THDR5", QPoint(RoleIndexes::L2, 7));
    thdnMap->insert("ACT_THDR6", QPoint(RoleIndexes::L3, 7));

    //(8) ∠UI is a calculated value

    QHash<QString, QPoint> *lambdaMap = new QHash<QString, QPoint>();
    lambdaMap->insert("ACT_Lambda1", QPoint(RoleIndexes::L1, 9));
    lambdaMap->insert("ACT_Lambda2", QPoint(RoleIndexes::L2, 9));
    lambdaMap->insert("ACT_Lambda3", QPoint(RoleIndexes::L3, 9));
    lambdaMap->insert("ACT_Lambda4", QPoint(RoleIndexes::SUM, 9));

    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("PAR_MeasuringMode", QPoint(RoleIndexes::NAME, 10));
    p1m1Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, 10));
    p1m1Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, 10));
    p1m1Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, 10));
    p1m1Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM, 10));

    QHash<QString, QPoint> *p1m2Map = new QHash<QString, QPoint>();
    p1m2Map->insert("PAR_MeasuringMode", QPoint(RoleIndexes::NAME, 11));
    p1m2Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, 11));
    p1m2Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, 11));
    p1m2Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, 11));
    p1m2Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM, 11));

    QHash<QString, QPoint> *p1m3Map = new QHash<QString, QPoint>();
    p1m3Map->insert("PAR_MeasuringMode", QPoint(RoleIndexes::NAME, 12));
    p1m3Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, 12));
    p1m3Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, 12));
    p1m3Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, 12));
    p1m3Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM, 12));

    QHash<QString, QPoint> *rangeMap = new QHash<QString, QPoint>();
    rangeMap->insert("ACT_Frequency", QPoint(RoleIndexes::SUM, 13));

    m_valueMapping.insert(static_cast<int>(Modules::RmsModule), rmsMap);
    m_valueMapping.insert(static_cast<int>(Modules::ThdnModule2), thdnMap);
    m_valueMapping.insert(static_cast<int>(Modules::DftModule), dftMap);
    m_valueMapping.insert(static_cast<int>(Modules::LambdaModule), lambdaMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module2), p1m2Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module3), p1m3Map);
    m_valueMapping.insert(static_cast<int>(Modules::RangeModule), rangeMap);
}

void ActualValueOnlyPModel::updateTranslation()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(0, 0);
    setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
    setData(mIndex, m_translation->TrValue("AUX"), RoleIndexes::AUX);
    setData(mIndex, "Σ", RoleIndexes::SUM);
    setData(mIndex, "[ ]", RoleIndexes::UNIT);

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
    updateMModeTranslations();
    mIndex = index(13, 0);
    setData(mIndex, m_translation->TrValue("F"), RoleIndexes::NAME);
}

QHash<int, QByteArray> ActualValueOnlyPModel::roleNames() const
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

void ActualValueOnlyPModel::insertMeasMode(int yCoordinate, QString measMode)
{
    m_dynamicMeasuringModeDescriptor.insert(yCoordinate, measMode);
    updateMModeTranslations();
}

void ActualValueOnlyPModel::updateMModeTranslations()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(10, 0);
    setData(mIndex, QString("(%1) P").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
    mIndex = index(11, 0);
    setData(mIndex, QString("(%1) Q").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
    mIndex = index(12, 0);
    setData(mIndex, QString("(%1) S").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
}
