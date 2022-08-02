#include "zeragluelogic.h"
#include "actualvaluemodel.h"
#include "actualvalueonlypmodel.h"
#include "burdenvaluemodel.h"
#include "ffttablemodel.h"
#include "hptablemodel.h"

#include <QHash>
#include <QPoint>

#include <ve_commandevent.h>
#include <vcmp_componentdata.h>

//required for vector2d data type
#include <QVector2D>

//required for atan2 function
#include <math.h>

#include <functional>


//harmonic power values

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
        m_actValueData(new ActualValueModel(m_qPtr)),
        m_actValueOnlyPData(new ActualValueOnlyPModel(m_qPtr)),
        m_burden1Data(new BurdenValueModel(Modules::Burden1Module, m_qPtr)),
        m_burden2Data(new BurdenValueModel(Modules::Burden2Module, m_qPtr)),
        m_osciP1Data(new QStandardItemModel(3, 128, m_qPtr)),
        m_osciP2Data(new QStandardItemModel(3, 128, m_qPtr)),
        m_osciP3Data(new QStandardItemModel(3, 128, m_qPtr)),
        m_osciAUXData(new QStandardItemModel(3, 128, m_qPtr)),
        m_fftTableData(new FftTableModel(1, 1, m_qPtr)), //dynamic size
        m_fftRelativeTableData(new FftTableModel(1, 1, m_qPtr)), //dynamic size
        m_hpTableData(new HarmonicPowerTableModel(1, 1, m_qPtr)), //dynamic size
        m_hpRelativeTableData(new HarmonicPowerTableModel(1, 1, m_qPtr)) //dynamic size
    {
        QObject::connect(m_translation, &ZeraTranslation::sigLanguageChanged, m_qPtr, [this](){updateTranslation();});

        m_actValueData->setupTable();
        m_actValueOnlyPData->setupTable();
        m_burden1Data->setupTable();
        m_burden2Data->setupTable();

        m_actValueData->setupMapping();
        m_actValueOnlyPData->setupMapping();
        m_burden1Data->setupMapping();
        m_burden2Data->setupMapping();
        setupOsciData();
        setupFftData();
        setupPropertyMap();
        setupDftDispatchTable();
    }

    ~ZeraGlueLogicPrivate()
    {
        delete m_actValueData;
        delete m_actValueOnlyPData;
        delete m_burden1Data;
        delete m_burden2Data;

        delete m_osciP1Data;
        delete m_osciP2Data;
        delete m_osciP3Data;
        delete m_osciAUXData;

        delete m_fftTableData;
        delete m_fftRelativeTableData;
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
        m_hpwTableRoleMapping.insert("ACT_HPP1", HarmonicPowerTableModel::POWER_S1_P);
        m_hpwTableRoleMapping.insert("ACT_HPP2", HarmonicPowerTableModel::POWER_S2_P);
        m_hpwTableRoleMapping.insert("ACT_HPP3", HarmonicPowerTableModel::POWER_S3_P);

        m_hpwTableRoleMapping.insert("ACT_HPQ1", HarmonicPowerTableModel::POWER_S1_Q);
        m_hpwTableRoleMapping.insert("ACT_HPQ2", HarmonicPowerTableModel::POWER_S2_Q);
        m_hpwTableRoleMapping.insert("ACT_HPQ3", HarmonicPowerTableModel::POWER_S3_Q);

        m_hpwTableRoleMapping.insert("ACT_HPS1", HarmonicPowerTableModel::POWER_S1_S);
        m_hpwTableRoleMapping.insert("ACT_HPS2", HarmonicPowerTableModel::POWER_S2_S);
        m_hpwTableRoleMapping.insert("ACT_HPS3", HarmonicPowerTableModel::POWER_S3_S);
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
        //m_actValueOnlyPData??
    }

    bool handleActualValues(ZeraGlueLogicItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        const QPoint valueCoordiates = t_componentMapping->value(t_cmpData->componentName());
        if(valueCoordiates.isNull() == false) //nothing is at 0, 0
        {
            QModelIndex mIndex = itemModel->index(valueCoordiates.y(), 0);
            if(t_cmpData->entityId() != static_cast<int>(Modules::DftModule)) {
                if(t_cmpData->componentName() == QLatin1String("PAR_MeasuringMode")) {
                    // inform itemModel so it translates meas modes properly from now on
                    QString newValue = t_cmpData->newValue().toString();
                    auto weHavASeriousTodoHere = dynamic_cast<ActualValueModel*>(itemModel);
                    if(weHavASeriousTodoHere) {
                        weHavASeriousTodoHere->insertMeasMode(valueCoordiates.y(), newValue);
                    }
                    auto weHavASeriousTodoHerePModel = dynamic_cast<ActualValueOnlyPModel*>(itemModel);
                    if(weHavASeriousTodoHerePModel) {
                        weHavASeriousTodoHerePModel->insertMeasMode(valueCoordiates.y(), newValue);
                    }
                }
                else {
                    //uses the mapped coordinates to insert the data in the model at x,y -> column,row position
                    itemModel->setData(mIndex, t_cmpData->newValue(), valueCoordiates.x());
                }
            }
            else //these are vectors that need calculation and are aligned to the reference channel
            {
                QList<double> tmpVector = qvariant_cast<QList<double> >(t_cmpData->newValue());
                if(tmpVector.isEmpty() == false) {
                    double vectorAngle = atan2(tmpVector.at(1), tmpVector.at(0)) / M_PI * 180; //y=im, x=re converted to degree
                    if(vectorAngle < 0) {
                        vectorAngle = 360 + vectorAngle;
                    }
                    itemModel->setData(mIndex, vectorAngle, valueCoordiates.x());
                    //use lookup table to call the right lambda that returns the id to update the angles
                    setAngleUI(m_dftDispatchTable.value(t_cmpData->componentName())(vectorAngle));
                }
            }
            retVal = true;
        }
        return retVal;
    }

    bool handleBurdenValues(ZeraGlueLogicItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
    {
        bool retVal = false;
        const QPoint valueCoordiates = t_componentMapping->value(t_cmpData->componentName());
        if(valueCoordiates.isNull() == false) //nothing is at 0, 0
        {
            QModelIndex mIndex = itemModel->index(valueCoordiates.y(), 0); // QML doesn't understand columns!
            //uses the mapped coordinates to insert the data in the model at x,y -> column,row position
            itemModel->setData(mIndex, t_cmpData->newValue(), valueCoordiates.x()); // QML doesn't understand columns, so use roles
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
        m_propertyMap->insert(ZeraGlueLogicPrivate::s_actualValueOnlyPComponentName, QVariant::fromValue<QObject*>(m_actValueOnlyPData));
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
        m_actValueData->updateTranslation();
        m_actValueOnlyPData->updateTranslation();
        m_burden1Data->updateTranslation();
        m_burden2Data->updateTranslation();
    }

    ZeraGlueLogic *m_qPtr;
    GlueLogicPropertyMap *m_propertyMap;
    ZeraTranslation *m_translation = nullptr;

    ZeraGlueLogicItemModelBase *m_actValueData;
    ZeraGlueLogicItemModelBase *m_actValueOnlyPData;
    ZeraGlueLogicItemModelBase *m_burden1Data;
    ZeraGlueLogicItemModelBase *m_burden2Data;

    QStandardItemModel *m_osciP1Data;
    QStandardItemModel *m_osciP2Data;
    QStandardItemModel *m_osciP3Data;
    QStandardItemModel *m_osciAUXData;

    FftTableModel *m_fftTableData;
    FftTableModel *m_fftRelativeTableData;

    HarmonicPowerTableModel *m_hpTableData;
    HarmonicPowerTableModel *m_hpRelativeTableData;

    QHash<QString, ModelRowPair> m_osciMapping;
    QHash<QString, int> m_fftTableRoleMapping;
    QHash<QString, int> m_hpwTableRoleMapping;

    double m_dftReferenceValue; //vector diagram reference angle

    static constexpr char const *s_actualValueComponentName = "ActualValueModel";
    static constexpr char const *s_actualValueOnlyPComponentName = "ActualValueOnlyPModel";
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
            switch(static_cast<Modules>(evData->entityId()))
            {
            case Modules::OsciModule:
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                retVal = m_dPtr->handleOsciValues(cmpData);
                break;
            }
            case Modules::FftModule:
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                retVal = m_dPtr->handleFftValues(cmpData);
                break;
            }
            case Modules::Power3Module:
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                retVal = m_dPtr->handleHarmonicPowerValues(cmpData);
                break;
            }
            case Modules::Burden1Module:
            {
                const auto burdenMapping = m_dPtr->m_burden1Data->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping != nullptr)) {
                    const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                    retVal = m_dPtr->handleBurdenValues(m_dPtr->m_burden1Data, burdenMapping, cmpData);
                }
                break;
            }
            case Modules::Burden2Module:
            {
                const auto burdenMapping = m_dPtr->m_burden2Data->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping != nullptr)) {
                    const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                    retVal = m_dPtr->handleBurdenValues(m_dPtr->m_burden2Data, burdenMapping, cmpData);
                }
                break;
            }
            default: /// @note values handled earlier in the switch case will not show up in the actual values table!
            {
                const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
                Q_ASSERT(cmpData != nullptr);
                const auto avMapping = m_dPtr->m_actValueData->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(avMapping != nullptr))
                {
                    retVal = m_dPtr->handleActualValues(m_dPtr->m_actValueData, avMapping, cmpData);
                }
                const auto avMappingOnlyP = m_dPtr->m_actValueOnlyPData->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(avMappingOnlyP != nullptr))
                {
                    retVal = m_dPtr->handleActualValues(m_dPtr->m_actValueOnlyPData, avMappingOnlyP, cmpData);
                }

                const auto burdenMapping1 = m_dPtr->m_burden1Data->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping1 != nullptr)) //rms values
                {
                    retVal = true;
                    m_dPtr->handleBurdenValues(m_dPtr->m_burden1Data, burdenMapping1, cmpData);
                }
                const auto burdenMapping2 = m_dPtr->m_burden2Data->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping2 != nullptr)) //rms values
                {
                    retVal = true;
                    m_dPtr->handleBurdenValues(m_dPtr->m_burden2Data, burdenMapping2, cmpData);
                }
                break;
            }
            }
        }
    }
    return retVal;
}

ZeraGlueLogicItemModelBase::ZeraGlueLogicItemModelBase(int t_rows, int t_columns, QObject *t_parent) :
    QStandardItemModel(t_rows, t_columns, t_parent),
    m_translation(ZeraTranslation::getInstance())
{
}

ZeraGlueLogicItemModelBase::~ZeraGlueLogicItemModelBase()
{
    for(auto point : qAsConst(m_valueMapping)) {
        delete point;
    }
}

QHash<int, QHash<QString, QPoint> *> ZeraGlueLogicItemModelBase::getValueMapping()
{
    return m_valueMapping;
}
