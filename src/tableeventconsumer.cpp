#include "tableeventconsumer.h"
#include "actualvaluemodel.h"
#include "actualvalueonlypmodel.h"
#include "actualvalue4thphasedcmodel.h"
#include "actualvalueacsummodel.h"
#include "burdenvaluemodel.h"

#include <math.h>

#include <QVector2D>

TableEventConsumer::TableEventConsumer(GlueLogicPropertyMap *t_propertyMap) :
    m_propertyMap(t_propertyMap),
    m_translation(ZeraTranslation::getInstance()),
    m_actValueData(new ActualValueModel(nullptr)),
    m_actValueOnlyPData(new ActualValueOnlyPModel(nullptr)),
    m_actValue4thPhaseDcData(new ActualValue4thPhaseDcModel(nullptr)),
    m_actValueAcSumData(new ActualValueAcSumModel(nullptr)),
    m_burden1Data(new BurdenValueModel(Modules::Burden1Module, nullptr)),
    m_burden2Data(new BurdenValueModel(Modules::Burden2Module, nullptr)),
    m_osciP1Data(new QStandardItemModel(3, 128, nullptr)),
    m_osciP2Data(new QStandardItemModel(3, 128, nullptr)),
    m_osciP3Data(new QStandardItemModel(3, 128, nullptr)),
    m_osciAUXData(new QStandardItemModel(3, 128, nullptr)),
    m_fftTableData(new FftTableModel(1, 1, nullptr)), //dynamic size
    m_fftRelativeTableData(new FftTableModel(1, 1, nullptr)), //dynamic size
    m_hpTableData(new HarmonicPowerTableModel(1, 1, nullptr)), //dynamic size
    m_hpRelativeTableData(new HarmonicPowerTableModel(1, 1, nullptr)) //dynamic size
{
    QObject::connect(m_translation, &ZeraTranslation::sigLanguageChanged, this, [this](){updateTranslation();});

    m_actValueData->setupTable();
    m_actValueOnlyPData->setupTable();
    m_actValue4thPhaseDcData->setupTable();
    m_actValueAcSumData->setupTable();
    m_burden1Data->setupTable();
    m_burden2Data->setupTable();

    m_actValueData->setupMapping();
    m_actValueOnlyPData->setupMapping();
    m_actValue4thPhaseDcData->setupMapping();
    m_actValueAcSumData->setupMapping();
    m_burden1Data->setupMapping();
    m_burden2Data->setupMapping();
    setupOsciData();
    setupFftData();
    setupPropertyMap();
    setupDftDispatchTable();
}


TableEventConsumer::~TableEventConsumer()
{
    delete m_actValueData;
    delete m_actValueOnlyPData;
    delete m_actValue4thPhaseDcData;
    delete m_actValueAcSumData;
    delete m_burden1Data;
    delete m_burden2Data;

    delete m_osciP1Data;
    delete m_osciP2Data;
    delete m_osciP3Data;
    delete m_osciAUXData;

    delete m_fftTableData;
    delete m_fftRelativeTableData;
}

void TableEventConsumer::setupOsciData()
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

    std::shared_ptr<ModelRowPair> tempModelPair;
    //P1
    tempModelPair = std::make_shared<ModelRowPair>(m_osciP1Data, 1);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI1", tempModelPair); //UL1
    tempModelPair = std::make_shared<ModelRowPair>(m_osciP1Data, 2);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI4", tempModelPair); //IL1
    //P2
    tempModelPair = std::make_shared<ModelRowPair>(m_osciP2Data, 1);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI2", tempModelPair); //UL2
    tempModelPair = std::make_shared<ModelRowPair>(m_osciP2Data, 2);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI5", tempModelPair); //IL2
    //P3
    tempModelPair = std::make_shared<ModelRowPair>(m_osciP3Data, 1);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI3", tempModelPair); //UL3
    tempModelPair = std::make_shared<ModelRowPair>(m_osciP3Data, 2);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI6", tempModelPair); //IL3
    //PN
    tempModelPair = std::make_shared<ModelRowPair>(m_osciAUXData, 1);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI7", tempModelPair); //UN
    tempModelPair = std::make_shared<ModelRowPair>(m_osciAUXData, 2);
    tempModelPair->m_updateInterval.setInterval(valueInterval);
    tempModelPair->m_updateInterval.setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI8", tempModelPair); //IN
}

void TableEventConsumer::setupFftData()
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

QString TableEventConsumer::getActualValueModelNameById(int t_moduleId)
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
        return "ERROR in QString getActualValueModelNameById(int t_moduleId)";
    }
}

void TableEventConsumer::setAngleUI(int t_systemNumber)
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
    //m_actValue4thPhaseDcData??
    //m_actValueAcSumData
}

void TableEventConsumer::handleComponentChange(const VeinComponent::ComponentData *cData)
{
    QList<TableEventItemModelBase *> allBaseItemModels = TableEventItemModelBase::getAllBaseModels();
    for(auto model : qAsConst(allBaseItemModels)) {
        model->handleComponentChange(cData);
    }

    switch(static_cast<Modules>(cData->entityId()))
    {
    case Modules::OsciModule:
    {
        handleOsciValues(cData);
        break;
    }
    case Modules::FftModule:
    {
        handleFftValues(cData);
        break;
    }
    case Modules::Power3Module:
    {
        handleHarmonicPowerValues(cData);
        break;
    }
    case Modules::Burden1Module:
    {
        const auto burdenMapping = m_burden1Data->getValueMapping().value(cData->entityId(), nullptr);
        if(Q_UNLIKELY(burdenMapping != nullptr)) {
            handleBurdenValues(m_burden1Data, burdenMapping, cData);
        }
        break;
    }
    case Modules::Burden2Module:
    {
        const auto burdenMapping = m_burden2Data->getValueMapping().value(cData->entityId(), nullptr);
        if(Q_UNLIKELY(burdenMapping != nullptr)) {
            handleBurdenValues(m_burden2Data, burdenMapping, cData);
        }
        break;
    }
    default: /// @note values handled earlier in the switch case will not show up in the actual values table!
    {
        QList<TableEventItemModelBase*> actValueModels = QList<TableEventItemModelBase*>()
                << m_actValueData
                << m_actValueOnlyPData
                << m_actValue4thPhaseDcData
                << m_actValueAcSumData;
        for(auto model : qAsConst(actValueModels)) {
            const auto avMapping = model->getValueMapping().value(cData->entityId(), nullptr);
            if(Q_UNLIKELY(avMapping != nullptr)) {
                handleActualValues(model, avMapping, cData);
            }
        }

        QList<TableEventItemModelBase*> burdenModels = QList<TableEventItemModelBase*>()
                << m_burden1Data
                << m_burden2Data;
        for(auto model : qAsConst(burdenModels)) {
            const auto burdenMapping = model->getValueMapping().value(cData->entityId(), nullptr);
            if(Q_UNLIKELY(burdenMapping != nullptr)) { //rms values
                handleBurdenValues(model, burdenMapping, cData);
            }
        }
        break;
    }
    }
}

bool TableEventConsumer::handleActualValues(TableEventItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
{
    bool retVal = false;
    const QPoint valueCoordiates = t_componentMapping->value(t_cmpData->componentName());
    if(valueCoordiates.isNull() == false) //nothing is at 0, 0
    {
        QModelIndex mIndex = itemModel->index(valueCoordiates.y(), 0);
        if(t_cmpData->entityId() == static_cast<int>(Modules::DftModule)) {
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

bool TableEventConsumer::handleBurdenValues(TableEventItemModelBase *itemModel, QHash<QString, QPoint> *t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
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

bool TableEventConsumer::handleOsciValues(const VeinComponent::ComponentData *t_cmpData)
{
    bool retVal=false;
    auto iter = m_osciMapping.find(t_cmpData->componentName());
    if(iter != m_osciMapping.end())
    {
        std::shared_ptr<ModelRowPair> tmpPair = iter.value();
        QStandardItemModel *tmpModel = tmpPair->m_model;
        QModelIndex tmpIndex;
        const QList<double> tmpData = qvariant_cast<QList<double> >(t_cmpData->newValue());

        QSignalBlocker blocker(tmpModel); //no need to send dataChanged for every iteration
        for(int i=0; i<tmpData.length(); ++i)
        {
            tmpIndex = tmpModel->index(tmpPair->m_row, i);
            tmpModel->setData(tmpIndex, tmpData.at(i), Qt::DisplayRole);
        }
        blocker.unblock();
        if(tmpPair->m_updateInterval.isActive() == false)
        {
            emit tmpModel->dataChanged(tmpModel->index(tmpPair->m_row, 0), tmpModel->index(tmpPair->m_row, tmpData.length()-1));
            tmpPair->m_updateInterval.start();
        }
        retVal = true;
    }
    return retVal;
}

bool TableEventConsumer::handleFftValues(const VeinComponent::ComponentData *t_cmpData)
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

bool TableEventConsumer::handleHarmonicPowerValues(const VeinComponent::ComponentData *t_cmpData)
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

void TableEventConsumer::setupPropertyMap()
{
    m_propertyMap->insert("ActualValueModel", QVariant::fromValue<QObject*>(m_actValueData));
    m_propertyMap->insert("ActualValueOnlyPModel", QVariant::fromValue<QObject*>(m_actValueOnlyPData));
    m_propertyMap->insert("ActualValue4thPhaseDcModel", QVariant::fromValue<QObject*>(m_actValue4thPhaseDcData));
    m_propertyMap->insert("ActualValueAcSumModel", QVariant::fromValue<QObject*>(m_actValueAcSumData));
    m_propertyMap->insert("BurdenModelI", QVariant::fromValue<QObject*>(m_burden1Data));
    m_propertyMap->insert("BurdenModelU", QVariant::fromValue<QObject*>(m_burden2Data));
    m_propertyMap->insert("OSCIP1Model", QVariant::fromValue<QObject*>(m_osciP1Data));
    m_propertyMap->insert("OSCIP2Model", QVariant::fromValue<QObject*>(m_osciP2Data));
    m_propertyMap->insert("OSCIP3Model", QVariant::fromValue<QObject*>(m_osciP3Data));
    m_propertyMap->insert("OSCIPNModel", QVariant::fromValue<QObject*>(m_osciAUXData));
    m_propertyMap->insert("FFTTableModel", QVariant::fromValue<QObject*>(m_fftTableData));
    m_propertyMap->insert("FFTRelativeTableModel", QVariant::fromValue<QObject*>(m_fftRelativeTableData));
    m_propertyMap->insert("HPWTableModel", QVariant::fromValue<QObject*>(m_hpTableData));
    m_propertyMap->insert("HPWRelativeTableModel", QVariant::fromValue<QObject*>(m_hpRelativeTableData));
}

void TableEventConsumer::setupDftDispatchTable()
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

void TableEventConsumer::updateTranslation()
{
    using namespace CommonTable;
    m_actValueData->updateTranslation();
    m_actValueOnlyPData->updateTranslation();
    m_actValue4thPhaseDcData->updateTranslation();
    m_actValueAcSumData->updateTranslation();
    m_burden1Data->updateTranslation();
    m_burden2Data->updateTranslation();
}