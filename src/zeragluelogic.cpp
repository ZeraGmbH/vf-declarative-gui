#include "zeragluelogic.h"
#include "actualvaluemodel.h"
#include <QStandardItemModel>
#include <QHash>
#include <QPoint>
#include <QTimer>

#include <ve_commandevent.h>
#include <vcmp_componentdata.h>

//required for vector2d data type
#include <QVector2D>

//required for atan2 function
#include <math.h>

#include <functional>


class BurdenValueModel : public QStandardItemModel
{
public:
    explicit BurdenValueModel(QObject *t_parent) : QStandardItemModel(t_parent){}
    BurdenValueModel(int t_rows, int t_columns, QObject *t_parent) : QStandardItemModel(t_rows, t_columns, t_parent) {}
    virtual ~BurdenValueModel() override;
    // QAbstractItemModel interface
public:
    QHash<int, QByteArray> roleNames() const override
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
};

BurdenValueModel::~BurdenValueModel() {}

class FftTableModel : public QStandardItemModel
{
public:
    explicit FftTableModel(QObject *t_parent) : QStandardItemModel(t_parent)
    {
    }
    FftTableModel(int t_rows, int t_columns, QObject *t_parent) : QStandardItemModel(t_rows, t_columns, t_parent)
    {
    }
    virtual ~FftTableModel() override;

    // QAbstractItemModel interface
public:
    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roles;
        //    roles.insert(rowIndex, "RowIndex");
        roles.insert(AMP_L1, "AmplitudeL1"); //leave the first one for eventual harmonic order
        roles.insert(AMP_L2, "AmplitudeL2");
        roles.insert(AMP_L3, "AmplitudeL3");
        roles.insert(AMP_L4, "AmplitudeL4");
        roles.insert(AMP_L5, "AmplitudeL5");
        roles.insert(AMP_L6, "AmplitudeL6");
        roles.insert(AMP_L7, "AmplitudeL7");
        roles.insert(AMP_L8, "AmplitudeL8");
        roles.insert(VECTOR_L1, "VectorL1");
        roles.insert(VECTOR_L2, "VectorL2");
        roles.insert(VECTOR_L3, "VectorL3");
        roles.insert(VECTOR_L4, "VectorL4");
        roles.insert(VECTOR_L5, "VectorL5");
        roles.insert(VECTOR_L6, "VectorL6");
        roles.insert(VECTOR_L7, "VectorL7");
        roles.insert(VECTOR_L8, "VectorL8");

        return roles;
    }

    enum RoleIndexes
    {
        AMP_L1=Qt::UserRole+1,
        AMP_L2,
        AMP_L3,
        AMP_L4,
        AMP_L5,
        AMP_L6,
        AMP_L7,
        AMP_L8,
        VECTOR_L1=AMP_L1+100,
        VECTOR_L2,
        VECTOR_L3,
        VECTOR_L4,
        VECTOR_L5,
        VECTOR_L6,
        VECTOR_L7,
        VECTOR_L8,
    };

private:
};

FftTableModel::~FftTableModel() {}

//harmonic power values
class HPTableModel : public QStandardItemModel
{
public:
    explicit HPTableModel(QObject *t_parent) : QStandardItemModel(t_parent)
    {
        setupTimer();
    }
    HPTableModel(int t_rows, int t_columns, QObject *t_parent) : QStandardItemModel(t_rows, t_columns, t_parent)
    {
        setupTimer();
    }
    virtual ~HPTableModel() override;

    // QAbstractItemModel interface
public:
    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roles;

        roles.insert(POWER_S1_P, "PowerS1P");
        roles.insert(POWER_S2_P, "PowerS2P");
        roles.insert(POWER_S3_P, "PowerS3P");
        roles.insert(POWER_S1_Q, "PowerS1Q");
        roles.insert(POWER_S2_Q, "PowerS2Q");
        roles.insert(POWER_S3_Q, "PowerS3Q");
        roles.insert(POWER_S1_S, "PowerS1S");
        roles.insert(POWER_S2_S, "PowerS2S");
        roles.insert(POWER_S3_S, "PowerS3S");

        return roles;
    }

    enum RoleIndexes
    {
        POWER_S1_P=Qt::UserRole+1,
        POWER_S2_P,
        POWER_S3_P,
        POWER_S1_Q=POWER_S1_P+100,
        POWER_S2_Q,
        POWER_S3_Q,
        POWER_S1_S=POWER_S1_Q+100,
        POWER_S2_S,
        POWER_S3_S,
    };

private:
    QTimer m_dataChangeTimer;
    void setupTimer()
    {
        m_dataChangeTimer.setInterval(1000);
        m_dataChangeTimer.setSingleShot(false);
        QObject::connect(&m_dataChangeTimer, &QTimer::timeout, [&]() {
            emit dataChanged(index(0, 0), index(rowCount()-1, columnCount()-1));
        });
        m_dataChangeTimer.start();
    }
};

HPTableModel::~HPTableModel() {}

class ModelRowPair
{
public:
    ModelRowPair(QStandardItemModel * t_model, int t_row) :
        m_model(t_model),
        m_row(t_row)
    {
    }

    bool isNull() const
    {
        return (m_model == nullptr || m_row == 0);
    }

    QStandardItemModel * m_model=nullptr;
    //optional timer used for values that change too frequently
    QTimer *m_updateInterval=nullptr; //uses the qt parent system to cleanup the instance
    int m_row=0;
};

class ZeraGlueLogicPrivate
{
    ZeraGlueLogicPrivate(ZeraGlueLogic *t_public, GlueLogicPropertyMap *t_propertyMap) :
        m_qPtr(t_public),
        m_propertyMap(t_propertyMap),
        m_translation(ZeraTranslation::getInstance()),
        m_actValueData(new ActualValueModel(14, 1, m_qPtr)),
        m_burden1Data(new BurdenValueModel(7, 1, m_qPtr)),
        m_burden2Data(new BurdenValueModel(7, 1, m_qPtr)),
        m_osciP1Data(new QStandardItemModel(3, 128, m_qPtr)),
        m_osciP2Data(new QStandardItemModel(3, 128, m_qPtr)),
        m_osciP3Data(new QStandardItemModel(3, 128, m_qPtr)),
        m_osciAUXData(new QStandardItemModel(3, 128, m_qPtr)),
        m_fftTableData(new FftTableModel(1, 1, m_qPtr)), //dynamic size
        m_fftRelativeTableData(new FftTableModel(1, 1, m_qPtr)), //dynamic size
        m_hpTableData(new HPTableModel(1, 1, m_qPtr)), //dynamic size
        m_hpRelativeTableData(new HPTableModel(1, 1, m_qPtr)) //dynamic size
    {
        QObject::connect(m_translation, &ZeraTranslation::sigLanguageChanged, m_qPtr, [this](){updateTranslation();});

        setupActualTable();
        setupBurdenTable();
        setupActualValueMapping();
        setupBurdenMapping();
        setupOsciData();
        setupFftData();
        setupPropertyMap();
        setupDftDispatchTable();
    }

    ~ZeraGlueLogicPrivate()
    {
        for(int i=0; i<m_actualValueMapping->count(); ++i)
        {
            QHash<QString, QPoint> *tmpToDelete = m_actualValueMapping->values().at(i);
            delete tmpToDelete;
        }
        delete m_actualValueMapping;
        delete m_actValueData;

        for(int i=0; i<m_burdenMapping->count(); ++i)
        {
            QHash<QString, QPoint> *tmpToDelete = m_burdenMapping->values().at(i);
            delete tmpToDelete;
        }
        delete m_burdenMapping;
        delete m_burden1Data;
        delete m_burden2Data;

        delete m_osciP1Data;
        delete m_osciP2Data;
        delete m_osciP3Data;
        delete m_osciAUXData;

        delete m_fftTableData;
        delete m_fftRelativeTableData;
    }

    void setupActualTable()
    {
        using namespace CommonTable;
        //column names
        QModelIndex mIndex = m_actValueData->index(0, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
        m_actValueData->setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
        m_actValueData->setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
        m_actValueData->setData(mIndex, m_translation->TrValue("AUX"), RoleIndexes::AUX);
        m_actValueData->setData(mIndex, "Σ", RoleIndexes::SUM);
        m_actValueData->setData(mIndex, "[ ]", RoleIndexes::UNIT);

        //row names
        //mIndex = m_actValueData->index(0, 0); //none
        mIndex = m_actValueData->index(1, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(2, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("UPP"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(3, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("∠U"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(4, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("kU"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(5, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(6, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("∠I"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(7, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("kI"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(8, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(9, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("λ"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(10, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("P"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(11, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("Q"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(12, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("S"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(13, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("F"), RoleIndexes::NAME);

        //unit names
        mIndex = m_actValueData->index(1, 0);
        m_actValueData->setData(mIndex, "V", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(2, 0);
        m_actValueData->setData(mIndex, "V", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(3, 0);
        m_actValueData->setData(mIndex, "°", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(4, 0);
        m_actValueData->setData(mIndex, "%", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(5, 0);
        m_actValueData->setData(mIndex, "A", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(6, 0);
        m_actValueData->setData(mIndex, "°", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(7, 0);
        m_actValueData->setData(mIndex, "%", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(8, 0);
        m_actValueData->setData(mIndex, "°", RoleIndexes::UNIT);
        //mIndex = m_actValueData->index(9, 0); //none
        mIndex = m_actValueData->index(10, 0);
        m_actValueData->setData(mIndex, "W", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(11, 0);
        m_actValueData->setData(mIndex, "VAR", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(12, 0);
        m_actValueData->setData(mIndex, "VA", RoleIndexes::UNIT);
        mIndex = m_actValueData->index(13, 0);
        m_actValueData->setData(mIndex, "Hz", RoleIndexes::UNIT);
    }

    /**
   * @brief Maps x, y positions of components into the itemmodel
   *
   * QPoint is the x, y  / column, row position in the itemmodel.
   * QML uses roles instead of columns!
   */
    void setupActualValueMapping()
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


        m_actualValueMapping->insert(static_cast<int>(Modules::RmsModule), rmsMap);
        m_actualValueMapping->insert(static_cast<int>(Modules::ThdnModule2), thdnMap);
        m_actualValueMapping->insert(static_cast<int>(Modules::DftModule), dftMap);
        m_actualValueMapping->insert(static_cast<int>(Modules::LambdaModule), lambdaMap);
        m_actualValueMapping->insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
        m_actualValueMapping->insert(static_cast<int>(Modules::Power1Module2), p1m2Map);
        m_actualValueMapping->insert(static_cast<int>(Modules::Power1Module3), p1m3Map);
        m_actualValueMapping->insert(static_cast<int>(Modules::RangeModule), rangeMap);
    }

    void setupBurdenTable()
    {
        using namespace CommonTable;
        QModelIndex mIndex = m_burden1Data->index(0, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("BRD1"), RoleIndexes::L1);
        m_burden1Data->setData(mIndex, m_translation->TrValue("BRD2"), RoleIndexes::L2);
        m_burden1Data->setData(mIndex, m_translation->TrValue("BRD3"), RoleIndexes::L3);
        m_burden1Data->setData(mIndex, "[ ]", RoleIndexes::UNIT);

        mIndex = m_burden1Data->index(1, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(2, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(3, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(4, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("Sb"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(5, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("cos(β)"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(6, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("Sn"), RoleIndexes::NAME);

        //unit names
        mIndex = m_burden1Data->index(1, 0);
        m_burden1Data->setData(mIndex, "V", RoleIndexes::UNIT);
        mIndex = m_burden1Data->index(2, 0);
        m_burden1Data->setData(mIndex, "A", RoleIndexes::UNIT);
        mIndex = m_burden1Data->index(3, 0);
        m_burden1Data->setData(mIndex, "°", RoleIndexes::UNIT);
        //mIndex = m_burdenData->index(4, 0);
        //m_burdenData->setData(mIndex, "", RoleIndexes::UNIT);
        mIndex = m_burden1Data->index(4, 0);
        m_burden1Data->setData(mIndex, "VA", RoleIndexes::UNIT);
        mIndex = m_burden1Data->index(6, 0);
        m_burden1Data->setData(mIndex, "%", RoleIndexes::UNIT);


        mIndex = m_burden2Data->index(0, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("BRD1"), RoleIndexes::L1);
        m_burden2Data->setData(mIndex, m_translation->TrValue("BRD2"), RoleIndexes::L2);
        m_burden2Data->setData(mIndex, m_translation->TrValue("BRD3"), RoleIndexes::L3);
        m_burden2Data->setData(mIndex, "[ ]", RoleIndexes::UNIT);

        mIndex = m_burden2Data->index(1, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(2, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(3, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(4, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("Sb"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(5, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("cos(β)"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(6, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("Sn"), RoleIndexes::NAME);

        //unit names
        mIndex = m_burden2Data->index(1, 0);
        m_burden2Data->setData(mIndex, "V", RoleIndexes::UNIT);
        mIndex = m_burden2Data->index(2, 0);
        m_burden2Data->setData(mIndex, "A", RoleIndexes::UNIT);
        mIndex = m_burden2Data->index(3, 0);
        m_burden2Data->setData(mIndex, "°", RoleIndexes::UNIT);
        //mIndex = m_burdenData->index(4, 0);
        //m_burdenData->setData(mIndex, "", RoleIndexes::UNIT);
        mIndex = m_burden2Data->index(4, 0);
        m_burden2Data->setData(mIndex, "VA", RoleIndexes::UNIT);
        mIndex = m_burden2Data->index(6, 0);
        m_burden2Data->setData(mIndex, "%", RoleIndexes::UNIT);
    }

    void setupBurdenMapping()
    {
        using namespace CommonTable;

        QHash<QString, QPoint> *rmsMap = new QHash<QString, QPoint>();
        rmsMap->insert("ACT_RMSPN1", QPoint(RoleIndexes::L1, 1));
        rmsMap->insert("ACT_RMSPN2", QPoint(RoleIndexes::L2, 1));
        rmsMap->insert("ACT_RMSPN3", QPoint(RoleIndexes::L3, 1));

        rmsMap->insert("ACT_RMSPN4", QPoint(RoleIndexes::L1, 2));
        rmsMap->insert("ACT_RMSPN5", QPoint(RoleIndexes::L2, 2));
        rmsMap->insert("ACT_RMSPN6", QPoint(RoleIndexes::L3, 2));

        //(3) ∠UI is a calculated value

        QHash<QString, QPoint> *burdenMap1 = new QHash<QString, QPoint>();
        burdenMap1->insert("ACT_Burden1", QPoint(RoleIndexes::L1, 4));
        burdenMap1->insert("ACT_Burden2", QPoint(RoleIndexes::L2, 4));
        burdenMap1->insert("ACT_Burden3", QPoint(RoleIndexes::L3, 4));

        burdenMap1->insert("ACT_PFactor1", QPoint(RoleIndexes::L1, 5));
        burdenMap1->insert("ACT_PFactor2", QPoint(RoleIndexes::L2, 5));
        burdenMap1->insert("ACT_PFactor3", QPoint(RoleIndexes::L3, 5));

        burdenMap1->insert("ACT_Ratio1", QPoint(RoleIndexes::L1, 6));
        burdenMap1->insert("ACT_Ratio2", QPoint(RoleIndexes::L2, 6));
        burdenMap1->insert("ACT_Ratio3", QPoint(RoleIndexes::L3, 6));

        QHash<QString, QPoint> *burdenMap2 = new QHash<QString, QPoint>();
        burdenMap2->insert("ACT_Burden1", QPoint(RoleIndexes::L1, 4));
        burdenMap2->insert("ACT_Burden2", QPoint(RoleIndexes::L2, 4));
        burdenMap2->insert("ACT_Burden3", QPoint(RoleIndexes::L3, 4));

        burdenMap2->insert("ACT_PFactor1", QPoint(RoleIndexes::L1, 5));
        burdenMap2->insert("ACT_PFactor2", QPoint(RoleIndexes::L2, 5));
        burdenMap2->insert("ACT_PFactor3", QPoint(RoleIndexes::L3, 5));

        burdenMap2->insert("ACT_Ratio1", QPoint(RoleIndexes::L1, 6));
        burdenMap2->insert("ACT_Ratio2", QPoint(RoleIndexes::L2, 6));
        burdenMap2->insert("ACT_Ratio3", QPoint(RoleIndexes::L3, 6));

        m_burdenMapping->insert(static_cast<int>(Modules::RmsModule), rmsMap);
        m_burdenMapping->insert(static_cast<int>(Modules::Burden1Module), burdenMap1);
        m_burdenMapping->insert(static_cast<int>(Modules::Burden2Module), burdenMap2);
    }

    void setupOsciData()
    {
        QModelIndex tmpIndex;
        const int valueInterval = 1000;

        //fill in the x axis values
        for(int i=0; i<128; ++i)
        {
            tmpIndex = m_osciP1Data->index(0, i);
            m_osciP1Data->setData(tmpIndex, i, Qt::DisplayRole);
            tmpIndex = m_osciP2Data->index(0, i);
            m_osciP2Data->setData(tmpIndex, i, Qt::DisplayRole);
            tmpIndex = m_osciP3Data->index(0, i);
            m_osciP3Data->setData(tmpIndex, i, Qt::DisplayRole);
            tmpIndex = m_osciAUXData->index(0, i);
            m_osciAUXData->setData(tmpIndex, i, Qt::DisplayRole);
        }

        //P1
        ModelRowPair osci1Pair(m_osciP1Data, 1);
        osci1Pair.m_updateInterval=new QTimer(m_qPtr);
        osci1Pair.m_updateInterval->setInterval(valueInterval);
        osci1Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI1", osci1Pair); //UL1
        ModelRowPair osci2Pair(m_osciP1Data, 2);
        osci2Pair.m_updateInterval=new QTimer(m_qPtr);
        osci2Pair.m_updateInterval->setInterval(valueInterval);
        osci2Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI4", osci2Pair); //IL1
        //P2
        ModelRowPair osci3Pair(m_osciP2Data, 1);
        osci3Pair.m_updateInterval=new QTimer(m_qPtr);
        osci3Pair.m_updateInterval->setInterval(valueInterval);
        osci3Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI2", osci3Pair); //UL2
        ModelRowPair osci4Pair(m_osciP2Data, 2);
        osci4Pair.m_updateInterval=new QTimer(m_qPtr);
        osci4Pair.m_updateInterval->setInterval(valueInterval);
        osci4Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI5", osci4Pair); //IL2
        //P3
        ModelRowPair osci5Pair(m_osciP3Data, 1);
        osci5Pair.m_updateInterval=new QTimer(m_qPtr);
        osci5Pair.m_updateInterval->setInterval(valueInterval);
        osci5Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI3", osci5Pair); //UL3
        ModelRowPair osci6Pair(m_osciP3Data, 2);
        osci6Pair.m_updateInterval=new QTimer(m_qPtr);
        osci6Pair.m_updateInterval->setInterval(valueInterval);
        osci6Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI6", osci6Pair); //IL3
        //PN
        ModelRowPair osci7Pair(m_osciAUXData, 1);
        osci7Pair.m_updateInterval=new QTimer(m_qPtr);
        osci7Pair.m_updateInterval->setInterval(valueInterval);
        osci7Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI7", osci7Pair); //UN
        ModelRowPair osci8Pair(m_osciAUXData, 2);
        osci8Pair.m_updateInterval=new QTimer(m_qPtr);
        osci8Pair.m_updateInterval->setInterval(valueInterval);
        osci8Pair.m_updateInterval->setSingleShot(true);
        m_osciMapping.insert("ACT_OSCI8", osci8Pair); //IN
    }

    void setupFftData()
    {
        m_fftTableRoleMapping.insert("ACT_FFT1", FftTableModel::AMP_L1);
        m_fftTableRoleMapping.insert("ACT_FFT2", FftTableModel::AMP_L2);
        m_fftTableRoleMapping.insert("ACT_FFT3", FftTableModel::AMP_L3);
        m_fftTableRoleMapping.insert("ACT_FFT4", FftTableModel::AMP_L4);
        m_fftTableRoleMapping.insert("ACT_FFT5", FftTableModel::AMP_L5);
        m_fftTableRoleMapping.insert("ACT_FFT6", FftTableModel::AMP_L6);
        m_fftTableRoleMapping.insert("ACT_FFT7", FftTableModel::AMP_L7);
        m_fftTableRoleMapping.insert("ACT_FFT8", FftTableModel::AMP_L8);

        //harmonic power values
        m_hpwTableRoleMapping.insert("ACT_HPP1", HPTableModel::POWER_S1_P);
        m_hpwTableRoleMapping.insert("ACT_HPP2", HPTableModel::POWER_S2_P);
        m_hpwTableRoleMapping.insert("ACT_HPP3", HPTableModel::POWER_S3_P);

        m_hpwTableRoleMapping.insert("ACT_HPQ1", HPTableModel::POWER_S1_Q);
        m_hpwTableRoleMapping.insert("ACT_HPQ2", HPTableModel::POWER_S2_Q);
        m_hpwTableRoleMapping.insert("ACT_HPQ3", HPTableModel::POWER_S3_Q);

        m_hpwTableRoleMapping.insert("ACT_HPS1", HPTableModel::POWER_S1_S);
        m_hpwTableRoleMapping.insert("ACT_HPS2", HPTableModel::POWER_S2_S);
        m_hpwTableRoleMapping.insert("ACT_HPS3", HPTableModel::POWER_S3_S);
    }

    /**
     * @brief AVM = ActualValueModel
     * @param t_moduleId
     * @return
     */
    QString getAvmNameById(int t_moduleId)
    {
        switch(static_cast<Modules>(t_moduleId))
        {
        case Modules::Power1Module1:
            return "P";
        case Modules::Power1Module2:
            return "Q";
        case Modules::Power1Module3:
            return "S";
        default:
            Q_ASSERT(false);
            return "ERROR in QString getAvmNameById(int t_moduleId)";
        }
    }

    void setAngleUI(int t_systemNumber)
    {
        Q_ASSERT(t_systemNumber==-1 || (t_systemNumber>0 && t_systemNumber<4));
        double tmpAngle = 0;
        QModelIndex tmpIndex;

        switch(t_systemNumber)
        {
        case -1:
            return; //angle calculation is currently not supported for ACT_DFTPN(7/8) so skip this function
        case 1:
        {
            tmpAngle = m_angleI1-m_angleU1;
            break;
        }
        case 2:
        {
            tmpAngle = m_angleI2-m_angleU2;
            break;
        }
        case 3:
        {
            tmpAngle = m_angleI3-m_angleU3;
            break;
        }
        }

        tmpIndex = m_burden1Data->index(3,0);
        m_burden1Data->setData(tmpIndex, tmpAngle, Qt::UserRole+t_systemNumber); // QML doesn't understand columns, so use roles
        tmpIndex = m_burden2Data->index(3,0);
        m_burden2Data->setData(tmpIndex, tmpAngle, Qt::UserRole+t_systemNumber); // QML doesn't understand columns, so use roles


        if(tmpAngle > 180) //display as negative
        {
            tmpAngle -= 360;
        }
        else if(tmpAngle < -180) //display as positive
        {
            tmpAngle += 360;
        }

        tmpIndex = m_actValueData->index(8, 0);
        m_actValueData->setData(tmpIndex, tmpAngle, Qt::UserRole+t_systemNumber); // QML doesn't understand columns, so use roles
    }

    bool handleActualValues(QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        const QPoint valueCoordiates = t_componentMapping->value(t_cmpData->componentName());
        if(valueCoordiates.isNull() == false) //nothing is at 0, 0
        {
            QModelIndex mIndex = m_actValueData->index(valueCoordiates.y(), 0); // QML doesn't understand columns!

            if(t_cmpData->entityId() != static_cast<int>(Modules::DftModule))
            {
                if(t_cmpData->componentName() == QLatin1String("PAR_MeasuringMode")) // these values need some string formatting
                {
                    //dynamic translation
                    m_dynamicMeasuringModeDescriptor.insert(valueCoordiates.y(), t_cmpData->newValue().toString()); //update dynamic reference table
                    const QString translatedMode = m_translation->TrValue(t_cmpData->newValue().toString()).toString();
                    Q_ASSERT(translatedMode.isEmpty() == false); //only triggers when the translation is missing in zeratranslation.cpp!
                    // (%Mode) %Name
                    const QString tmpValue = QString("(%1) %2").arg(translatedMode).arg(getAvmNameById(t_cmpData->entityId()));
                    m_actValueData->setData(mIndex, tmpValue, valueCoordiates.x()); // QML doesn't understand column, so use roles
                }
                else
                {
                    //uses the mapped coordinates to insert the data in the model at x,y -> column,row position
                    m_actValueData->setData(mIndex, t_cmpData->newValue(), valueCoordiates.x()); // QML doesn't understand columns, so use roles
                }
            }
            else //these are vectors that need calculation and are aligned to the reference channel
            {
                QList<double> tmpVector = qvariant_cast<QList<double> >(t_cmpData->newValue());
                if(tmpVector.isEmpty() == false)
                {
                    double vectorAngle = atan2(tmpVector.at(1), tmpVector.at(0)) / M_PI * 180; //y=im, x=re converted to degree
                    if(vectorAngle < 0)
                    {
                        vectorAngle = 360 + vectorAngle;
                    }

                    m_actValueData->setData(mIndex, vectorAngle, valueCoordiates.x());

                    //use lookup table to call the right lambda that returns the id to update the angles
                    setAngleUI(m_dftDispatchTable.value(t_cmpData->componentName())(vectorAngle));
                }
            }
            retVal = true;
        }
        return retVal;
    }

    bool handleBurden1Values(QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        const QPoint valueCoordiates = t_componentMapping->value(t_cmpData->componentName());
        if(valueCoordiates.isNull() == false) //nothing is at 0, 0
        {
            QModelIndex mIndex = m_burden1Data->index(valueCoordiates.y(), 0); // QML doesn't understand columns!
            //uses the mapped coordinates to insert the data in the model at x,y -> column,row position
            m_burden1Data->setData(mIndex, t_cmpData->newValue(), valueCoordiates.x()); // QML doesn't understand columns, so use roles
        }

        return retVal;
    }

    bool handleBurden2Values(QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        const QPoint valueCoordiates = t_componentMapping->value(t_cmpData->componentName());
        if(valueCoordiates.isNull() == false) //nothing is at 0, 0
        {
            QModelIndex mIndex = m_burden2Data->index(valueCoordiates.y(), 0); // QML doesn't understand columns!
            //uses the mapped coordinates to insert the data in the model at x,y -> column,row position
            m_burden2Data->setData(mIndex, t_cmpData->newValue(), valueCoordiates.x()); // QML doesn't understand columns, so use roles
        }

        return retVal;
    }

    bool handleOsciValues(const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal=false;
        ModelRowPair tmpPair = m_osciMapping.value(t_cmpData->componentName(), ModelRowPair(nullptr, 0));
        if(tmpPair.isNull() == false)
        {
            QStandardItemModel *tmpModel = tmpPair.m_model;
            QModelIndex tmpIndex;
            const QList<double> tmpData = qvariant_cast<QList<double> >(t_cmpData->newValue());

            QSignalBlocker blocker(tmpModel); //no need to send dataChanged for every iteration
            for(int i=0; i<tmpData.length(); ++i)
            {
                tmpIndex = tmpModel->index(tmpPair.m_row, i);
                tmpModel->setData(tmpIndex, tmpData.at(i), Qt::DisplayRole);
            }
            blocker.unblock();
            if(tmpPair.m_updateInterval->isActive() == false)
            {
                emit tmpModel->dataChanged(tmpModel->index(tmpPair.m_row, 0), tmpModel->index(tmpPair.m_row, tmpData.length()-1));
                tmpPair.m_updateInterval->start();
            }
            retVal = true;
        }
        return retVal;
    }

    bool handleFftValues(const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        int fftTableRole=m_fftTableRoleMapping.value(t_cmpData->componentName(), 0);
        if(fftTableRole != 0)
        {
            const QList<double> tmpData = qvariant_cast<QList<double> >(t_cmpData->newValue());
            /**
       * @note The size check fixes:
       * Alignment trap: not handling instruction edd21b00 at [<000523ae>]
       * Unhandled fault: alignment exception (0x001) at 0x65747379
       */
            if(tmpData.length() > 3) //base oscillation imaginary part is at index 3
            {
                QModelIndex fftTableIndex, fftRelativeTableIndex;
                QVector2D tmpVec2d;
                double re, im, vectorAngle, length, ampBaseOscillation;

                //set ampBaseOscillation
                re = tmpData.at(2);
                im = tmpData.at(3);
                tmpVec2d.setX(re);
                tmpVec2d.setY(im);
                length = tmpVec2d.length();

                ampBaseOscillation = length;
                if(ampBaseOscillation == 0.0) //avoid division by zero
                {
                    ampBaseOscillation = pow(10, -15);
                }

                m_fftTableData->setRowCount(tmpData.length()/2);
                m_fftRelativeTableData->setRowCount(tmpData.length()/2);
                for(int i=0; i<tmpData.length(); i+=2)
                {
                    re = tmpData.at(i);
                    im = tmpData.at(i+1);
                    tmpVec2d.setX(re);
                    tmpVec2d.setY(im);
                    length = tmpVec2d.length();

                    fftTableIndex = m_fftTableData->index(i/2, 0);
                    m_fftTableData->setData(fftTableIndex, length, fftTableRole);

                    fftRelativeTableIndex = m_fftRelativeTableData->index(i/2, 0);
                    if(Q_UNLIKELY(i/2==1)) //base oscillation is shown as absolute value (i=0 is DC)
                    {
                        m_fftRelativeTableData->setData(fftRelativeTableIndex, length, fftTableRole); //absolute value
                    }
                    else
                    {
                        m_fftRelativeTableData->setData(fftRelativeTableIndex, 100.0*length/ampBaseOscillation, fftTableRole); //value relative to the amplitude of the base oscillation
                    }

                    vectorAngle = (i!=0) * atan2(im, re) / M_PI * 180; //first harmonic (0) is a DC value, so it has no phase position
                    if(vectorAngle < 0)
                    {
                        vectorAngle = 360 + vectorAngle;
                    }
                    m_fftTableData->setData(fftTableIndex, vectorAngle, fftTableRole+100);
                    m_fftRelativeTableData->setData(fftRelativeTableIndex, vectorAngle, fftTableRole+100);
                }
                retVal = true;
            }
        }
        return retVal;
    }

    bool handleHarmonicPowerValues(const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        const int tableRole=m_hpwTableRoleMapping.value(t_cmpData->componentName(), 0);
        if(tableRole != 0)
        {
            const QList<double> tmpData = qvariant_cast<QList<double> >(t_cmpData->newValue());
            if(tmpData.isEmpty()==false)
            {
                QModelIndex tmpIndex, tmpRelativeIndex;
                QSignalBlocker blocker(m_hpTableData);
                QSignalBlocker relativeBlocker(m_hpRelativeTableData);
                double ampBaseOscillation, currentValue;
                //set ampBaseOscillation
                ampBaseOscillation = tmpData.at(1);

                m_hpTableData->setRowCount(tmpData.length());
                m_hpRelativeTableData->setRowCount(tmpData.length());
                for(int i=0; i<tmpData.length(); ++i)
                {
                    currentValue = tmpData.at(i);
                    tmpIndex = m_hpTableData->index(i, 0);
                    m_hpTableData->setData(tmpIndex, currentValue, tableRole);

                    tmpRelativeIndex = m_hpRelativeTableData->index(i, 0);
                    if(Q_UNLIKELY(i==1)) //base oscillation is shown as absolute value (i=0 is DC)
                    {
                        m_hpRelativeTableData->setData(tmpRelativeIndex, ampBaseOscillation, tableRole); //absolute value
                    }
                    else
                    {
                        m_hpRelativeTableData->setData(tmpRelativeIndex, 100.0*currentValue/ampBaseOscillation, tableRole); //value relative to the amplitude of the base oscillation
                    }
                }
                retVal = true;
                blocker.unblock();
                relativeBlocker.unblock();
            }
        }
        return retVal;
    }

    void setupPropertyMap()
    {
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_actualValueComponentName, QVariant::fromValue<QObject*>(m_actValueData));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_burden1ComponentName, QVariant::fromValue<QObject*>(m_burden1Data));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_burden2ComponentName, QVariant::fromValue<QObject*>(m_burden2Data));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_osciP1ComponentName, QVariant::fromValue<QObject*>(m_osciP1Data));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_osciP2ComponentName, QVariant::fromValue<QObject*>(m_osciP2Data));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_osciP3ComponentName, QVariant::fromValue<QObject*>(m_osciP3Data));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_osciPNComponentName, QVariant::fromValue<QObject*>(m_osciAUXData));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_fftTableModelComponentName, QVariant::fromValue<QObject*>(m_fftTableData));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_fftRelativeTableModelComponentName, QVariant::fromValue<QObject*>(m_fftRelativeTableData));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_hpwTableModelComponentName, QVariant::fromValue<QObject*>(m_hpTableData));
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_hpwRelativeTableModelComponentName, QVariant::fromValue<QObject*>(m_hpRelativeTableData));
    }

    /**
     * @brief dispatch table for dft values, the lambdas return the index for setAngleUI()
     */
    void setupDftDispatchTable()
    {
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN1"), [this](double vectorAngle) -> int { m_angleU1 = vectorAngle; return 1; });
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN2"), [this](double vectorAngle) -> int { m_angleU2 = vectorAngle; return 2; });
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN3"), [this](double vectorAngle) -> int { m_angleU3 = vectorAngle; return 3; });
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN4"), [this](double vectorAngle) -> int { m_angleI1 = vectorAngle; return 1; });
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN5"), [this](double vectorAngle) -> int { m_angleI2 = vectorAngle; return 2; });
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN6"), [this](double vectorAngle) -> int { m_angleI3 = vectorAngle; return 3; });
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN7"), [](double) -> int { return -1; }); //currently the angle is not calculated
        m_dftDispatchTable.insert(QLatin1String("ACT_DFTPN8"), [](double) -> int { return -1; }); //currently the angle is not calculated
    }

    void updateTranslation()
    {
        using namespace CommonTable;
        //actValue
        QModelIndex mIndex = m_actValueData->index(0, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
        m_actValueData->setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
        m_actValueData->setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
        m_actValueData->setData(mIndex, m_translation->TrValue("AUX"), RoleIndexes::AUX);
        m_actValueData->setData(mIndex, "Σ", RoleIndexes::SUM);
        m_actValueData->setData(mIndex, "[ ]", RoleIndexes::UNIT);

        //mIndex = m_actValueData->index(0, 0); //none
        mIndex = m_actValueData->index(1, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(2, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("UPP"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(3, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("∠U"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(4, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("kU"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(5, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(6, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("∠I"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(7, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("kI"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(8, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(9, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("λ"), RoleIndexes::NAME);
        mIndex = m_actValueData->index(10, 0);
        m_actValueData->setData(mIndex, QString("(%1) P").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
        mIndex = m_actValueData->index(11, 0);
        m_actValueData->setData(mIndex, QString("(%1) Q").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
        mIndex = m_actValueData->index(12, 0);
        m_actValueData->setData(mIndex, QString("(%1) S").arg(m_translation->TrValue(m_dynamicMeasuringModeDescriptor.value(mIndex.row())).toString()), RoleIndexes::NAME);
        mIndex = m_actValueData->index(13, 0);
        m_actValueData->setData(mIndex, m_translation->TrValue("F"), RoleIndexes::NAME);

        //burden1
        mIndex = m_burden1Data->index(0, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("BRD1"), RoleIndexes::L1);
        m_burden1Data->setData(mIndex, m_translation->TrValue("BRD2"), RoleIndexes::L2);
        m_burden1Data->setData(mIndex, m_translation->TrValue("BRD3"), RoleIndexes::L3);
        m_burden1Data->setData(mIndex, "[ ]", RoleIndexes::UNIT);

        mIndex = m_burden1Data->index(1, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(2, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(3, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(4, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("Sb"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(5, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("cos(β)"), RoleIndexes::NAME);
        mIndex = m_burden1Data->index(6, 0);
        m_burden1Data->setData(mIndex, m_translation->TrValue("Sn"), RoleIndexes::NAME);

        //burden2
        mIndex = m_burden2Data->index(0, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("BRD1"), RoleIndexes::L1);
        m_burden2Data->setData(mIndex, m_translation->TrValue("BRD2"), RoleIndexes::L2);
        m_burden2Data->setData(mIndex, m_translation->TrValue("BRD3"), RoleIndexes::L3);
        m_burden2Data->setData(mIndex, "[ ]", RoleIndexes::UNIT);

        mIndex = m_burden2Data->index(1, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("UPN"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(2, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(3, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("∠UI"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(4, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("Sb"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(5, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("cos(β)"), RoleIndexes::NAME);
        mIndex = m_burden2Data->index(6, 0);
        m_burden2Data->setData(mIndex, m_translation->TrValue("Sn"), RoleIndexes::NAME);
    }

    ZeraGlueLogic *m_qPtr;
    GlueLogicPropertyMap *m_propertyMap;
    ZeraTranslation *m_translation = nullptr;

    QStandardItemModel *m_actValueData;
    QStandardItemModel *m_burden1Data;
    QStandardItemModel *m_burden2Data;

    QStandardItemModel *m_osciP1Data;
    QStandardItemModel *m_osciP2Data;
    QStandardItemModel *m_osciP3Data;
    QStandardItemModel *m_osciAUXData;

    FftTableModel *m_fftTableData;
    FftTableModel *m_fftRelativeTableData;

    HPTableModel *m_hpTableData;
    HPTableModel *m_hpRelativeTableData;

    //stands for QHash<"entity descriptor", QHash<"component name", 2D coordinates>*>
    template <typename T>
    using CoordinateMapping = QHash<T, QHash<QString, QPoint>*>;

    CoordinateMapping<int> *m_actualValueMapping = new CoordinateMapping<int>();
    CoordinateMapping<int> *m_burdenMapping = new CoordinateMapping<int>();

    QHash<QString, ModelRowPair> m_osciMapping;
    QHash<QString, int> m_fftTableRoleMapping;
    QHash<QString, int> m_hpwTableRoleMapping;

    QHash<int, QString> m_dynamicMeasuringModeDescriptor = {{10, ""}, {11, ""}, {12, ""}};

    double m_dftReferenceValue; //vector diagram reference angle

    static constexpr char const *s_actualValueComponentName = "ActualValueModel";
    static constexpr char const *s_burden1ComponentName = "BurdenModelI";
    static constexpr char const *s_burden2ComponentName = "BurdenModelU";
    static constexpr char const *s_osciP1ComponentName = "OSCIP1Model";
    static constexpr char const *s_osciP2ComponentName = "OSCIP2Model";
    static constexpr char const *s_osciP3ComponentName = "OSCIP3Model";
    static constexpr char const *s_osciPNComponentName = "OSCIPNModel";
    static constexpr char const *s_fftTableModelComponentName = "FFTTableModel";
    static constexpr char const *s_fftRelativeTableModelComponentName = "FFTRelativeTableModel";
    static constexpr char const *s_hpwTableModelComponentName = "HPWTableModel";
    static constexpr char const *s_hpwRelativeTableModelComponentName = "HPWRelativeTableModel";

    QHash<QString, std::function<int(double)> > m_dftDispatchTable;

    double m_angleU1=0;
    double m_angleU2=0;
    double m_angleU3=0;

    double m_angleI1=0;
    double m_angleI2=0;
    double m_angleI3=0;

    enum class Modules : int {
        ModeModule = 1000,
        ReferenceModule = 1001,
        RangeModule = 1020,
        SampleModule = 1030,
        RmsModule = 1040,
        DftModule = 1050,
        FftModule = 1060,
        Power1Module1 = 1070, // P
        Power1Module2 = 1071, // Q
        Power1Module3 = 1072, // S
        //Power1Module4 = 1073, // P+Q+S for SCPI clients
        //Power2Module1 = 1090, // CED session
        Power3Module = 1100,
        ThdnModule1 = 1110,
        ThdnModule2 = 1111,
        OsciModule = 1120,
        Sec1Module = 1130,
        LambdaModule = 1140,
        //StatusModule = 1150,
        Burden1Module = 1160,
        Burden2Module = 1161,
        //TranformerModule = 1170,
        //AdjustmentModule = 1190,
        //ScpiModule = 9999,
    };

    friend class ZeraGlueLogic;
};

ZeraGlueLogic::ZeraGlueLogic(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent) :
    VeinEvent::EventSystem(t_parent),
    m_dPtr(new ZeraGlueLogicPrivate(this, t_propertyMap))
{
}

ZeraGlueLogic::~ZeraGlueLogic()
{
    delete m_dPtr;
    m_dPtr=nullptr;
}

bool ZeraGlueLogic::processEvent(QEvent *t_event)
{
    using namespace VeinEvent;
    bool retVal = false;
    if(t_event->type()==CommandEvent::eventType())
    {
        CommandEvent *cEvent = static_cast<CommandEvent *>(t_event);
        Q_ASSERT(cEvent != nullptr);

        EventData *evData = cEvent->eventData();
        Q_ASSERT(evData != nullptr);

        if (cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION
                && evData->type() == VeinComponent::ComponentData::dataType())
        {
            switch(static_cast<ZeraGlueLogicPrivate::Modules>(evData->entityId()))
            {
            case ZeraGlueLogicPrivate::Modules::OsciModule:
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                retVal = m_dPtr->handleOsciValues(cmpData);
                break;
            }
            case ZeraGlueLogicPrivate::Modules::FftModule:
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                retVal = m_dPtr->handleFftValues(cmpData);
                break;
            }
            case ZeraGlueLogicPrivate::Modules::Power3Module:
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                retVal = m_dPtr->handleHarmonicPowerValues(cmpData);
                break;
            }
            case ZeraGlueLogicPrivate::Modules::Burden1Module:
            {
                const auto burdenMapping = m_dPtr->m_burdenMapping->value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping != nullptr))
                {
                    const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                    retVal = m_dPtr->handleBurden1Values(burdenMapping, cmpData);
                }
                break;
            }
            case ZeraGlueLogicPrivate::Modules::Burden2Module:
            {
                const auto burdenMapping = m_dPtr->m_burdenMapping->value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping != nullptr))
                {
                    const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                    retVal = m_dPtr->handleBurden2Values(burdenMapping, cmpData);
                }
                break;
            }
            default: /// @note values handled earlier in the switch case will not show up in the actual values table!
            {
                const auto avMapping = m_dPtr->m_actualValueMapping->value(evData->entityId(), nullptr);
                const auto burdenMapping = m_dPtr->m_burdenMapping->value(evData->entityId(), nullptr);
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);

                Q_ASSERT(cmpData != nullptr);
                if(Q_UNLIKELY(avMapping != nullptr))
                {
                    retVal = m_dPtr->handleActualValues(avMapping, cmpData);
                }
                if(Q_UNLIKELY(burdenMapping != nullptr)) //rms values
                {
                    retVal = true;
                    m_dPtr->handleBurden1Values(burdenMapping, cmpData);
                    m_dPtr->handleBurden2Values(burdenMapping, cmpData);
                }
                break;
            }
            }
        }
    }
    return retVal;
}
