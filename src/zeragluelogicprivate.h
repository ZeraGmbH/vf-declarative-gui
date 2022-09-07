#ifndef _ZERAGLUELOGICPRIVATE_H
#define _ZERAGLUELOGICPRIVATE_H

#include "zeragluelogic.h"
#include "zeragluelogicitemmodelbase.h"
#include "ffttablemodel.h"
#include "harmonicpowertablemodel.h"
#include "modelrowpair.h"

#include <ve_eventdata.h>

class ZeraGlueLogicPrivate
{
    ZeraGlueLogicPrivate(ZeraGlueLogic *t_public, GlueLogicPropertyMap *t_propertyMap);
    ~ZeraGlueLogicPrivate();


    void setupOsciData();

    void setupFftData();

    QString getActualValueModelNameById(int t_moduleId);

    void setAngleUI(int t_systemNumber);

    void handleComponentChange(const VeinComponent::ComponentData *cData, VeinEvent::EventData *evData);
    bool handleActualValues(ZeraGlueLogicItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData);
    bool handleBurdenValues(ZeraGlueLogicItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData);
    bool handleOsciValues(const VeinComponent::ComponentData *t_cmpData);
    bool handleFftValues(const VeinComponent::ComponentData *t_cmpData);
    bool handleHarmonicPowerValues(const VeinComponent::ComponentData *t_cmpData);

    void setupPropertyMap();
    void setupDftDispatchTable();
    void updateTranslation();

    ZeraGlueLogic *m_qPtr;
    GlueLogicPropertyMap *m_propertyMap;
    ZeraTranslation *m_translation = nullptr;

    ZeraGlueLogicItemModelBase *m_actValueData;
    ZeraGlueLogicItemModelBase *m_actValueOnlyPData;
    ZeraGlueLogicItemModelBase *m_actValue4thPhaseDcData;
    ZeraGlueLogicItemModelBase *m_actValueAcSumData;
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

    QHash<QString, std::function<int(double)> > m_dftDispatchTable;

    double m_angleU1=0;
    double m_angleU2=0;
    double m_angleU3=0;

    double m_angleI1=0;
    double m_angleI2=0;
    double m_angleI3=0;

    friend class ZeraGlueLogic;
};


#endif // _ZERAGLUELOGICPRIVATE_H
