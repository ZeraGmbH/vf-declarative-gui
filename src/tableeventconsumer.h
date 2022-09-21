#ifndef TABLEEVENTCONSUMER_H
#define TABLEEVENTCONSUMER_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"
#include "ffttablemodel.h"
#include "harmonicpowertablemodel.h"
#include "modelrowpair.h"
#include "vfeventconsumerinterface.h"
#include "gluelogicpropertymap.h"

#include <ve_eventdata.h>

class TableEventConsumer : public QObject, public VfEventConsumerInterface
{
    Q_OBJECT
public:
    TableEventConsumer(GlueLogicPropertyMap *t_propertyMap);
    ~TableEventConsumer();

    void handleComponentChange(const VeinComponent::ComponentData *cData) override;

private:
    void setupOsciData();

    void setupFftData();

    QString getActualValueModelNameById(int t_moduleId);

    void setAngleUI(int t_systemNumber);

    bool handleActualValues(TableEventItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData);
    bool handleBurdenValues(TableEventItemModelBase *itemModel, QHash<QString, QPoint>* t_componentMapping, const VeinComponent::ComponentData *t_cmpData);
    bool handleOsciValues(const VeinComponent::ComponentData *t_cmpData);
    bool handleFftValues(const VeinComponent::ComponentData *t_cmpData);
    bool handleHarmonicPowerValues(const VeinComponent::ComponentData *t_cmpData);

    void setupPropertyMap();
    void setupDftDispatchTable();
    void setLabelsAndUnits();

    GlueLogicPropertyMap *m_propertyMap;
    ZeraTranslation *m_translation = nullptr;

    TableEventItemModelBase *m_actValueData;
    TableEventItemModelBase *m_actValueOnlyPData;
    TableEventItemModelBase *m_actValue4thPhaseDcData;
    TableEventItemModelBase *m_actValueAcSumData;
    TableEventItemModelBase *m_actValueDcPerPhaseUData;
    TableEventItemModelBase *m_burden1Data;
    TableEventItemModelBase *m_burden2Data;

    QStandardItemModel *m_osciP1Data;
    QStandardItemModel *m_osciP2Data;
    QStandardItemModel *m_osciP3Data;
    QStandardItemModel *m_osciAUXData;

    FftTableModel *m_fftTableData;
    FftTableModel *m_fftRelativeTableData;

    HarmonicPowerTableModel *m_hpTableData;
    HarmonicPowerTableModel *m_hpRelativeTableData;

    QHash<QString, std::shared_ptr<ModelRowPair>> m_osciMapping;
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
};


#endif // TABLEEVENTCONSUMER_H
