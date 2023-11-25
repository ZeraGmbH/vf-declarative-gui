#include "tableeventconsumer.h"
#include "actualvaluemodel.h"
#include "actualvaluemodelwithaux.h"
#include "actualvalueemobacmodel.h"
#include "actualvalueemobdcmodel.h"
#include "actualvalueemobacsummodel.h"
#include "actualvaluelemdcperphaseumodel.h"
#include "actualvaluelemdcsingleimodel.h"
#include "actualvaluelemdcperphasepmodel.h"
#include "burdenvaluemodel.h"
#include "oscimodel.h"
#include <math.h>

#include <QVector2D>

TableEventConsumer::TableEventConsumer(GlueLogicPropertyMap *propertyMap) :
    m_propertyMap(propertyMap),
    m_translation(ZeraTranslation::getInstance()),
    m_actValueData(new ActualValueModel),
    m_actValueDataWithAux(new ActualValueModelWithAux),
    m_actValueModels(QList<TableEventItemModelBase*>()
            << m_actValueData
            << m_actValueDataWithAux
            << new ActualValueEmobAcModel
            << new ActualValueEmobDcModel
            << new ActualValueEmobAcSumModel
            << new ActualValueLemDCPerPhaseUModel
            << new ActualValueLemDcSingleIModel
            << new ActualValueLemDcPerPhasePModel),
    m_osciValueModels(QList<TQmlLabelModelPair>()
            << TQmlLabelModelPair("OSCIP1Model", new OsciModel(QStringList() << "ACT_OSCI1" << "ACT_OSCI4"))
            << TQmlLabelModelPair("OSCIP2Model", new OsciModel(QStringList() << "ACT_OSCI2" << "ACT_OSCI5"))
            << TQmlLabelModelPair("OSCIP3Model", new OsciModel(QStringList() << "ACT_OSCI3" << "ACT_OSCI6"))
            << TQmlLabelModelPair("OSCIPNModel", new OsciModel(QStringList() << "ACT_OSCI7" << "ACT_OSCI8"))),
    m_burden1Data(new BurdenValueModel(Modules::Burden1Module)),
    m_burden2Data(new BurdenValueModel(Modules::Burden2Module)),
    m_fftTableData(new FftTableModel(1, 1, nullptr)), //dynamic size
    m_fftRelativeTableData(new FftTableModel(1, 1, nullptr)), //dynamic size
    m_hpTableData(new HarmonicPowerTableModel(1, 1, nullptr)), //dynamic size
    m_hpRelativeTableData(new HarmonicPowerTableModel(1, 1, nullptr)) //dynamic size
{
    QObject::connect(m_translation, &ZeraTranslation::sigLanguageChanged, this, [this](){setLabelsAndUnits();});

    setLabelsAndUnits();

    for(const auto &itemModel : qAsConst(m_actValueModels))
        itemModel->setupMapping();
    for(const auto &item : qAsConst(m_osciValueModels))
        item.m_model->setupMapping();
    m_burden1Data->setupMapping();
    m_burden2Data->setupMapping();
    setupFftData();
    setupPropertyMap();
    setupDftDispatchTable();
}


TableEventConsumer::~TableEventConsumer()
{
    for(const auto &itemModel : qAsConst(m_actValueModels))
        delete itemModel;
    for(const auto &item : qAsConst(m_osciValueModels))
        delete item.m_model;
    m_osciValueModels.clear();

    delete m_burden1Data;
    delete m_burden2Data;

    delete m_fftTableData;
    delete m_fftRelativeTableData;
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

void TableEventConsumer::setupPropertyMap()
{
    for(const auto &itemModel : qAsConst(m_actValueModels))
        m_propertyMap->insert(itemModel->metaObject()->className(), QVariant::fromValue<QObject*>(itemModel));

    m_propertyMap->insert("BurdenModelI", QVariant::fromValue<QObject*>(m_burden1Data));
    m_propertyMap->insert("BurdenModelU", QVariant::fromValue<QObject*>(m_burden2Data));
    for(const auto &item : qAsConst(m_osciValueModels))
        m_propertyMap->insert(item.m_qmlName, QVariant::fromValue<QObject*>(item.m_model));
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

void TableEventConsumer::setLabelsAndUnits()
{
    for(const auto &itemModel : qAsConst(m_actValueModels))
        itemModel->setLabelsAndUnits();
    for(const auto &item : qAsConst(m_osciValueModels))
        item.m_model->setLabelsAndUnits();
    m_burden1Data->setLabelsAndUnits();
    m_burden2Data->setLabelsAndUnits();
}

void TableEventConsumer::handleComponentChange(const VeinComponent::ComponentData *cData)
{
    QList<TableEventItemModelBase *> allBaseItemModels = TableEventItemModelBase::getAllBaseModels();
    for(auto model : qAsConst(allBaseItemModels))
        model->handleComponentChange(cData);

    switch(static_cast<Modules>(cData->entityId()))
    {
    case Modules::FftModule:
        handleFftValues(cData);
        break;
    case Modules::Power3Module:
        handleHarmonicPowerValues(cData);
        break;
    case Modules::DftModule:
        handleDftValues(cData);
        break;
    default:
        break;
    }
}

void TableEventConsumer::handleDftValues(const VeinComponent::ComponentData *cData)
{
    for(const auto &itemModel : qAsConst(m_actValueModels)) {
        const auto componentMapping = itemModel->getValueMapping().value(cData->entityId(), nullptr);
        if(Q_UNLIKELY(componentMapping)) {
            const QPoint valueCoordiates = componentMapping->value(cData->componentName());
            if(!valueCoordiates.isNull()) { //nothing is at 0, 0
                QModelIndex mIndex = itemModel->index(valueCoordiates.y(), 0);
                QList<double> tmpVector = qvariant_cast<QList<double> >(cData->newValue());
                if(!tmpVector.isEmpty()) {
                    double vectorAngle = atan2(tmpVector.at(1), tmpVector.at(0)) / M_PI * 180; //y=im, x=re converted to degree
                    if(vectorAngle < 0)
                        vectorAngle += 360;
                    itemModel->setData(mIndex, vectorAngle, valueCoordiates.x());
                    //use lookup table to call the right lambda that returns the id to update the angles
                    setAngleUI(m_dftDispatchTable.value(cData->componentName())(vectorAngle));
                }
            }
        }
    }
}

void TableEventConsumer::handleFftValues(const VeinComponent::ComponentData *cData)
{
    int fftTableRole = m_fftTableRoleMapping.value(cData->componentName(), 0);
    if(fftTableRole != 0) {
        const QList<double> tmpData = qvariant_cast<QList<double> >(cData->newValue());
        if(tmpData.length() > 3) { // base harmonic is mandatory: re idx=2 / im idx=3
            double ampBaseHarmonic = calcVectorLength(tmpData.at(2), tmpData.at(3));
            if(ampBaseHarmonic == 0.0) // avoid division by zero
                ampBaseHarmonic = 1e-15;
            const int harmonicCount = tmpData.length() / 2;
            m_fftTableData->setRowCount(harmonicCount);
            m_fftRelativeTableData->setRowCount(harmonicCount);
            for(int i=0; i<tmpData.length(); i+=2) {
                const double re = tmpData.at(i);
                const double im = tmpData.at(i+1);
                const double length = calcVectorLength(re, im);
                double vectorAngle = (i != 0) * atan2(im, re) / M_PI * 180; //first harmonic (0) is a DC value, so it has no phase position
                if(vectorAngle < 0)
                    vectorAngle += 360;

                int harmonicIdx = i / 2;
                QModelIndex fftTableIndex = m_fftTableData->index(harmonicIdx, 0);
                m_fftTableData->setData(fftTableIndex, length, fftTableRole);
                m_fftTableData->setData(fftTableIndex, vectorAngle, fftTableRole + FftTableModel::ampVectorOffset);

                QModelIndex fftRelativeTableIndex = m_fftRelativeTableData->index(harmonicIdx, 0);
                if(Q_UNLIKELY(harmonicIdx == 1)) // base harmonic is shown as absolute value
                    m_fftRelativeTableData->setData(fftRelativeTableIndex, length, fftTableRole); // absolute value
                else
                    m_fftRelativeTableData->setData(fftRelativeTableIndex, 100.0*length / ampBaseHarmonic, fftTableRole); //value relative to the amplitude of the base oscillation
                m_fftRelativeTableData->setData(fftRelativeTableIndex, vectorAngle, fftTableRole + FftTableModel::ampVectorOffset);
            }
        }
    }
}

void TableEventConsumer::handleHarmonicPowerValues(const VeinComponent::ComponentData *cData)
{
    const int tableRole = m_hpwTableRoleMapping.value(cData->componentName(), 0);
    if(tableRole != 0) {
        const QList<double> tmpData = qvariant_cast<QList<double> >(cData->newValue());
        if(!tmpData.isEmpty()) {
            QSignalBlocker blocker(m_hpTableData);
            QSignalBlocker relativeBlocker(m_hpRelativeTableData);
            double ampBaseHarmonic = tmpData.at(1);
            if(ampBaseHarmonic == 0.0) //avoid division by zero
                ampBaseHarmonic = 1e-15;

            const int harmonicCount = tmpData.length();
            m_hpTableData->setRowCount(harmonicCount);
            m_hpRelativeTableData->setRowCount(harmonicCount);
            for(int i=0; i<harmonicCount; ++i) {
                double currentValue = tmpData.at(i);
                QModelIndex tmpIndex = m_hpTableData->index(i, 0);
                m_hpTableData->setData(tmpIndex, currentValue, tableRole);

                QModelIndex tmpRelativeIndex = m_hpRelativeTableData->index(i, 0);
                if(Q_UNLIKELY(i == 1)) //base oscillation is shown as absolute value (i=0 is DC)
                    m_hpRelativeTableData->setData(tmpRelativeIndex, ampBaseHarmonic, tableRole); //absolute value
                else
                    m_hpRelativeTableData->setData(tmpRelativeIndex, 100.0*currentValue/ampBaseHarmonic, tableRole); //value relative to the amplitude of the base oscillation
            }
            blocker.unblock();
            relativeBlocker.unblock();
        }
    }
}

void TableEventConsumer::setAngleUI(int systemNumber)
{
    Q_ASSERT(systemNumber==-1 || (systemNumber>0 && systemNumber<4));
    double tmpAngle = 0;
    switch(systemNumber)
    {
    case -1:
        return; //angle calculation is currently not supported for ACT_DFTPN(7/8) so skip this function
    case 1:
        tmpAngle = m_angleI1-m_angleU1;
        break;
    case 2:
        tmpAngle = m_angleI2-m_angleU2;
        break;
    case 3:
        tmpAngle = m_angleI3-m_angleU3;
        break;
    }

    QModelIndex tmpIndex = m_burden1Data->index(3,0);
    m_burden1Data->setData(tmpIndex, tmpAngle, Qt::UserRole+systemNumber); // QML doesn't understand columns, so use roles
    tmpIndex = m_burden2Data->index(3,0);
    m_burden2Data->setData(tmpIndex, tmpAngle, Qt::UserRole+systemNumber); // QML doesn't understand columns, so use roles

    if(tmpAngle > 180) //display as negative
        tmpAngle -= 360;
    else if(tmpAngle < -180) //display as positive
        tmpAngle += 360;
    tmpIndex = m_actValueData->index(8, 0);
    m_actValueData->setData(tmpIndex, tmpAngle, Qt::UserRole+systemNumber);
    tmpIndex = m_actValueDataWithAux->index(8, 0);
    m_actValueDataWithAux->setData(tmpIndex, tmpAngle, Qt::UserRole+systemNumber);
}

double TableEventConsumer::calcVectorLength(double re, double im)
{
    QVector2D tmpVec2d(re, im);
    return tmpVec2d.length();
}

TableEventConsumer::TQmlLabelModelPair::TQmlLabelModelPair(QString qmlName, TableEventItemModelBase *model)
{
    m_qmlName = qmlName;
    m_model = model;
}
