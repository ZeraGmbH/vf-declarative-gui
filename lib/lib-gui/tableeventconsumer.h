#ifndef TABLEEVENTCONSUMER_H
#define TABLEEVENTCONSUMER_H

#include "vfcomponenteventdispatcher.h"
#include "tableeventitemmodelbase.h"
#include "ffttablemodel.h"
#include "harmonicpowertablemodel.h"
#include "vfeventconsumerinterface.h"
#include "gluelogicpropertymap.h"

#include <ve_eventdata.h>

class TableEventConsumer : public QObject, public VfEventConsumerInterface
{
    Q_OBJECT
public:
    TableEventConsumer(GlueLogicPropertyMap *propertyMap);
    ~TableEventConsumer();

    void handleComponentChange(const VeinComponent::ComponentData *cData) override;

private:
    void setupFftMappings();
    void setAngleUI(int systemNumber);
    void setupPropertyMap();
    void setupDftDispatchTable();
    void setLabelsAndUnits();

    void handleDftValue(const VeinComponent::ComponentData *cData);
    void handleFftValues(const VeinComponent::ComponentData *cData);
    void handleHarmonicPowerValues(const VeinComponent::ComponentData *cData);

    void distributeAngleValue(double vectorAngle, const VeinComponent::ComponentData *cData);
    double calcVectorLength(double re, double im);
    double avoidDivisionByZero(double val);
    void sessionNameReceived(QString sessionName);
    void onSessionChange();

    GlueLogicPropertyMap *m_propertyMap;
    ZeraTranslation *m_translation = nullptr;
    QString m_currentSessionName;

    TableEventItemModelBase *m_actValueData;
    TableEventItemModelBase *m_actValueDataWithAux;
    QList<TableEventItemModelBase*> m_actValueModels;
    struct TQmlLabelModelPair {
        TQmlLabelModelPair(QString qmlName, TableEventItemModelBase* model);
        QString m_qmlName;
        TableEventItemModelBase* m_model;
    };
    QList<TQmlLabelModelPair> m_osciValueModels;

    TableEventItemModelBase *m_burden1Data;
    TableEventItemModelBase *m_burden2Data;

    FftTableModel *m_fftTableData;
    FftTableModel *m_fftTableDataRelative;

    HarmonicPowerTableModel *m_harmonicPowerTableData;
    HarmonicPowerTableModel *m_harmonicPowerTableDataRelative;

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
    void createActualValueModels();
    void cleanupActualValueModels();
};


#endif // TABLEEVENTCONSUMER_H
