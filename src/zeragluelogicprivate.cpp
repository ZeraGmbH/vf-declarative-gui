#include "zeragluelogicprivate.h"
#include "actualvaluemodel.h"
#include "actualvalueonlypmodel.h"
#include "actualvalue4thphasedcmodel.h"
#include "actualvalueacsummodel.h"
#include "burdenvaluemodel.h"

#include <math.h>

#include <QVector2D>

ZeraGlueLogicPrivate::ZeraGlueLogicPrivate(ZeraGlueLogic *t_public, GlueLogicPropertyMap *t_propertyMap) :
    m_qPtr(t_public),
    m_propertyMap(t_propertyMap),
    m_translation(ZeraTranslation::getInstance()),
    m_actValueData(new ActualValueModel(m_qPtr)),
    m_actValueOnlyPData(new ActualValueOnlyPModel(m_qPtr)),
    m_actValue4thPhaseDcData(new ActualValue4thPhaseDcModel(m_qPtr)),
    m_actValueAcSumData(new ActualValueAcSumModel(m_qPtr)),
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

bool ZeraGlueLogicPrivate::handleActualValues(ZeraGlueLogicItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData)
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

bool ZeraGlueLogicPrivate::handleFftValues(const VeinComponent::ComponentData *t_cmpData)
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
