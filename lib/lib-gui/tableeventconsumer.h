#ifndef TABLEEVENTCONSUMER_H
#define TABLEEVENTCONSUMER_H

#include "gluelogicpropertymap.h"
#include "tableeventitemmodelbase.h"
#include "ffttablemodel.h"
#include "harmonicpowertablemodel.h"

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
    void setupPropertyMapForCustomModels();
    void setupDftDispatchTable();
    void setLabelsAndUnits();

    void handleDftValue(const VeinComponent::ComponentData *cData);
    void handleFftValues(const VeinComponent::ComponentData *cData);
    void handleHarmonicPowerValues(const VeinComponent::ComponentData *cData);

    void createActualValueModels();
    void cleanupActualValueModels();
    void distributeAngleValue(double vectorAngle, const VeinComponent::ComponentData *cData);
    static double calcVectorLength(double re, double im);
    static double avoidDivisionByZero(double val);
    void sessionNameReceived(QString sessionName);
    void onSessionChange();

    GlueLogicPropertyMap *m_propertyMap;
    ZeraTranslation *m_translation = nullptr;
    QString m_currentSessionName;

    QList<TableEventItemModelBase*> m_sessionSpecificActualValueModels;

    // item models that require tailored handling:
    // * loaded once in ctor
    // * sessions using them use one view implementation
    struct TQmlLabelModelPair {
        TQmlLabelModelPair(QString qmlName, TableEventItemModelBase* model);
        QString m_qmlName;
        TableEventItemModelBase* m_model;
    };
    QList<TQmlLabelModelPair> m_osciValueModels;
    FftTableModel *m_fftTableData;
    FftTableModel *m_fftTableDataRelative;
    HarmonicPowerTableModel *m_harmonicPowerTableData;
    HarmonicPowerTableModel *m_harmonicPowerTableDataRelative;

    // helpers for tailored handling
    QHash<QString, int> m_fftTableRoleMapping;
    QHash<QString, int> m_hpwTableRoleMapping;
    QHash<QString, std::function<int(double)> > m_dftDispatchTable;
    double m_angleU1 = 0;
    double m_angleU2 = 0;
    double m_angleU3 = 0;
    double m_angleI1 = 0;
    double m_angleI2 = 0;
    double m_angleI3 = 0;
};

#endif // TABLEEVENTCONSUMER_H
