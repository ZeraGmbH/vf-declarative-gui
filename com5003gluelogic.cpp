#include "com5003gluelogic.h"
#include <QStandardItemModel>
#include <QHash>
#include <QPoint>
#include <QTimer>

#include <ve_commandevent.h>
#include <vcmp_componentdata.h>
#include <vcmp_entitydata.h>
#include <vcmp_introspectiondata.h>

//required for fake introspection of the glue logic entity
#include <QJsonObject>
#include <QJsonArray>

//required for vector2d data type
#include <QVector2D>

//required for atan2 function
#include <math.h>

// DISCLAIMER: this is glue logic code, in this sense use the unix philosophy "worse is better"

class ActualValueModel : public QStandardItemModel {
public:
  explicit ActualValueModel(QObject *t_parent) : QStandardItemModel(t_parent){}
  ActualValueModel(int t_rows, int t_columns, QObject *t_parent) : QStandardItemModel(t_rows, t_columns, t_parent) {}

  // QAbstractItemModel interface
public:
  QHash<int, QByteArray> roleNames() const override {
    int rowIndex = Qt::UserRole;
    QHash<int, QByteArray> roles;
    roles.insert(rowIndex, "Name");
    rowIndex++;
    roles.insert(rowIndex, "L1");
    rowIndex++;
    roles.insert(rowIndex, "L2");
    rowIndex++;
    roles.insert(rowIndex, "L3");
    rowIndex++;
    roles.insert(rowIndex, "Sum");
    rowIndex++;
    roles.insert(rowIndex, "Unit");
    return roles;
  }
};

class FftTableModel : public QStandardItemModel {
public:
  explicit FftTableModel(QObject *t_parent) : QStandardItemModel(t_parent)
  {
    setupTimer();
  }
  FftTableModel(int t_rows, int t_columns, QObject *t_parent) : QStandardItemModel(t_rows, t_columns, t_parent)
  {
    setupTimer();
  }

  // QAbstractItemModel interface
public:
  QHash<int, QByteArray> roleNames() const override {
    int rowIndex = Qt::UserRole;
    QHash<int, QByteArray> roles;
    //    roles.insert(rowIndex, "RowIndex");
    rowIndex=AMP_L1; //leave the first one for eventual harmonic order
    roles.insert(rowIndex, "AmplitudeL1");
    rowIndex=AMP_L2;
    roles.insert(rowIndex, "AmplitudeL2");
    rowIndex=AMP_L3;
    roles.insert(rowIndex, "AmplitudeL3");
    rowIndex=AMP_L4;
    roles.insert(rowIndex, "AmplitudeL4");
    rowIndex=AMP_L5;
    roles.insert(rowIndex, "AmplitudeL5");
    rowIndex=AMP_L6;
    roles.insert(rowIndex, "AmplitudeL6");
    rowIndex=VECTOR_L1;
    roles.insert(rowIndex, "VectorL1");
    rowIndex=VECTOR_L2;
    roles.insert(rowIndex, "VectorL2");
    rowIndex=VECTOR_L3;
    roles.insert(rowIndex, "VectorL3");
    rowIndex=VECTOR_L4;
    roles.insert(rowIndex, "VectorL4");
    rowIndex=VECTOR_L5;
    roles.insert(rowIndex, "VectorL5");
    rowIndex=VECTOR_L6;
    roles.insert(rowIndex, "VectorL6");
    return roles;
  }

  enum RoleIndexes {
    AMP_L1=Qt::UserRole+1,
    AMP_L2,
    AMP_L3,
    AMP_L4,
    AMP_L5,
    AMP_L6,
    VECTOR_L1=AMP_L1+100,
    VECTOR_L2,
    VECTOR_L3,
    VECTOR_L4,
    VECTOR_L5,
    VECTOR_L6,
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

class ModelRowPair {
public:
  ModelRowPair(QStandardItemModel * t_model, int t_row) :
    m_model(t_model),
    m_row(t_row)
  {
  }

  bool isNull() const
  {
    return (m_model == 0 || m_row == 0);
  }

  QStandardItemModel * m_model=0;
  int m_row=0;
  //optional timer used for values that change too frequently
  QTimer *m_updateInterval=0; //use the qt parent system to cleanup the instance
};

class Com5003GlueLogicPrivate {
  Com5003GlueLogicPrivate(Com5003GlueLogic *t_public) :
    q_ptr(t_public),
    m_actValueData(new ActualValueModel(14, 6, q_ptr)),
    m_osciP1Data(new QStandardItemModel(3, 128, q_ptr)),
    m_osciP2Data(new QStandardItemModel(3, 128, q_ptr)),
    m_osciP3Data(new QStandardItemModel(3, 128, q_ptr)),
    m_fftTableData(new FftTableModel(40, 1, q_ptr))
  {
    setupActualTable();
    setupActualValueMapping();
    setupOsciData();
    setupFftData();
  }

  ~Com5003GlueLogicPrivate()
  {
    for(int i=0; i<m_actualValueMapping->count(); ++i)
    {
      QHash<QString, QPoint> *tmpToDelete = m_actualValueMapping->values().at(i);
      delete tmpToDelete;
    }
    delete m_actualValueMapping;
    delete m_actValueData;

    delete m_osciP1Data;
    delete m_osciP2Data;
    delete m_osciP3Data;

    delete m_fftTableData;
  }

  void setupIntrospection() {
    // only these component names are known in the QML context
    QStringList componentNames;
    componentNames.append(m_actualValueComponentName);
    componentNames.append(m_osciP1ComponentName);
    componentNames.append(m_osciP2ComponentName);
    componentNames.append(m_osciP3ComponentName);
    componentNames.append(m_fftTableModelComponentName);
    componentNames.append("EntityName");

    VeinComponent::IntrospectionData *newData=0;
    QJsonObject tmpObject;
    tmpObject.insert(QString("components"), QJsonArray::fromStringList(componentNames));
    newData = new VeinComponent::IntrospectionData();
    newData->setEntityId(m_entityId);
    newData->setJsonData(tmpObject);
    newData->setEventOrigin(VeinComponent::IntrospectionData::EventOrigin::EO_LOCAL);
    newData->setEventTarget(VeinComponent::IntrospectionData::EventTarget::ET_LOCAL);

    VeinEvent::CommandEvent *newEvent = new VeinEvent::CommandEvent(VeinEvent::CommandEvent::EventSubtype::NOTIFICATION, newData);
    emit q_ptr->sigSendEvent(newEvent);
  }

  void setupActualTable()
  {
    //column names
    QModelIndex mIndex = m_actValueData->index(0, 0);
    m_actValueData->setData(mIndex, "L1", Qt::UserRole+1);
    m_actValueData->setData(mIndex, "L2", Qt::UserRole+2);
    m_actValueData->setData(mIndex, "L3", Qt::UserRole+3);
    m_actValueData->setData(mIndex, "Σ", Qt::UserRole+4);
    m_actValueData->setData(mIndex, "[ ]", Qt::UserRole+5);

    //row names
    //mIndex = m_actValueData->index(0, 0); //none
    mIndex = m_actValueData->index(1, 0);
    m_actValueData->setData(mIndex, QObject::tr("UPN", "phase to neutral"), Qt::UserRole);
    mIndex = m_actValueData->index(2, 0);
    m_actValueData->setData(mIndex, QObject::tr("UPP", "phase to phase"), Qt::UserRole);
    mIndex = m_actValueData->index(3, 0);
    m_actValueData->setData(mIndex, QObject::tr("kU", "harmonic distortion"), Qt::UserRole);
    mIndex = m_actValueData->index(4, 0);
    m_actValueData->setData(mIndex, QObject::tr("I", "current"), Qt::UserRole);
    mIndex = m_actValueData->index(5, 0);
    m_actValueData->setData(mIndex, QObject::tr("kI", "harmonic distortion"), Qt::UserRole);
    mIndex = m_actValueData->index(6, 0);
    m_actValueData->setData(mIndex, QObject::tr("∠U", "phase"), Qt::UserRole);
    mIndex = m_actValueData->index(7, 0);
    m_actValueData->setData(mIndex, QObject::tr("∠I", "phase"), Qt::UserRole);
    mIndex = m_actValueData->index(8, 0);
    m_actValueData->setData(mIndex, QObject::tr("∠UI", "phase difference"), Qt::UserRole);
    mIndex = m_actValueData->index(9, 0);
    m_actValueData->setData(mIndex, QObject::tr("λ", "power factor"), Qt::UserRole);
    mIndex = m_actValueData->index(10, 0);
    m_actValueData->setData(mIndex, QObject::tr("P", "power"), Qt::UserRole);
    mIndex = m_actValueData->index(11, 0);
    m_actValueData->setData(mIndex, QObject::tr("Q", "reactive power"), Qt::UserRole);
    mIndex = m_actValueData->index(12, 0);
    m_actValueData->setData(mIndex, QObject::tr("S", "apparent power"), Qt::UserRole);
    mIndex = m_actValueData->index(13, 0);
    m_actValueData->setData(mIndex, QObject::tr("F", "frequency"), Qt::UserRole);

    //unit names
    mIndex = m_actValueData->index(1, 0);
    m_actValueData->setData(mIndex, "V", Qt::UserRole+5);
    mIndex = m_actValueData->index(2, 0);
    m_actValueData->setData(mIndex, "V", Qt::UserRole+5);
    mIndex = m_actValueData->index(3, 0);
    m_actValueData->setData(mIndex, "%", Qt::UserRole+5);
    mIndex = m_actValueData->index(4, 0);
    m_actValueData->setData(mIndex, "A", Qt::UserRole+5);
    mIndex = m_actValueData->index(5, 0);
    m_actValueData->setData(mIndex, "%", Qt::UserRole+5);
    mIndex = m_actValueData->index(6, 0);
    m_actValueData->setData(mIndex, "°", Qt::UserRole+5);
    mIndex = m_actValueData->index(7, 0);
    m_actValueData->setData(mIndex, "°", Qt::UserRole+5);
    mIndex = m_actValueData->index(8, 0);
    m_actValueData->setData(mIndex, "°", Qt::UserRole+5);
    //mIndex = m_actValueData->index(9, 0);
    //m_actValueData->setData(mIndex, "", Qt::UserRole+5);
    mIndex = m_actValueData->index(10, 0);
    m_actValueData->setData(mIndex, "W", Qt::UserRole+5);
    mIndex = m_actValueData->index(11, 0);
    m_actValueData->setData(mIndex, "VAR", Qt::UserRole+5);
    mIndex = m_actValueData->index(12, 0);
    m_actValueData->setData(mIndex, "VA", Qt::UserRole+5);
    mIndex = m_actValueData->index(13, 0);
    m_actValueData->setData(mIndex, "Hz", Qt::UserRole+5);

    //empty spaces
    mIndex = m_actValueData->index(0, 0);
    m_actValueData->setData(mIndex, "", Qt::UserRole);

    for(int i=1; i<10; ++i)
    {
      mIndex = m_actValueData->index(i, 4);
      m_actValueData->setData(mIndex, "", Qt::UserRole);
    }

    mIndex = m_actValueData->index(9, 5);
    m_actValueData->setData(mIndex, "", Qt::UserRole);

    mIndex = m_actValueData->index(13, 1);
    m_actValueData->setData(mIndex, "", Qt::UserRole);
    mIndex = m_actValueData->index(13, 2);
    m_actValueData->setData(mIndex, "", Qt::UserRole);
    mIndex = m_actValueData->index(13, 3);
    m_actValueData->setData(mIndex, "", Qt::UserRole);
  }

  /**
   * @brief Maps x, y positions of components into the itemmodel
   *
   * QPoint is the x, y  / column, row position in the itemmodel.
   * QML uses roles instead of columns!
   */
  void setupActualValueMapping()
  {
    QHash<QString, QPoint> *rmsMap = new QHash<QString, QPoint>();
    rmsMap->insert("ACT_RMSPN1", QPoint(1, 1));
    rmsMap->insert("ACT_RMSPN2", QPoint(2, 1));
    rmsMap->insert("ACT_RMSPN3", QPoint(3, 1));

    rmsMap->insert("ACT_RMSPN4", QPoint(1, 4));
    rmsMap->insert("ACT_RMSPN5", QPoint(2, 4));
    rmsMap->insert("ACT_RMSPN6", QPoint(3, 4));

    rmsMap->insert("ACT_RMSPP1", QPoint(1, 2));
    rmsMap->insert("ACT_RMSPP2", QPoint(2, 2));
    rmsMap->insert("ACT_RMSPP3", QPoint(3, 2));


    QHash<QString, QPoint> *thdnMap = new QHash<QString, QPoint>();
    thdnMap->insert("ACT_THDN1", QPoint(1, 3));
    thdnMap->insert("ACT_THDN2", QPoint(2, 3));
    thdnMap->insert("ACT_THDN3", QPoint(3, 3));

    thdnMap->insert("ACT_THDN4", QPoint(1, 5));
    thdnMap->insert("ACT_THDN5", QPoint(2, 5));
    thdnMap->insert("ACT_THDN6", QPoint(3, 5));

    QHash<QString, QPoint> *dftMap = new QHash<QString, QPoint>();
    dftMap->insert("ACT_DFTPN1", QPoint(1, 6));
    dftMap->insert("ACT_DFTPN2", QPoint(2, 6));
    dftMap->insert("ACT_DFTPN3", QPoint(3, 6));

    dftMap->insert("ACT_DFTPN4", QPoint(1, 7));
    dftMap->insert("ACT_DFTPN5", QPoint(2, 7));
    dftMap->insert("ACT_DFTPN6", QPoint(3, 7));

    dftMap->insert("ACT_DFTPP1", QPoint(1, 8));
    dftMap->insert("ACT_DFTPP2", QPoint(2, 8));
    dftMap->insert("ACT_DFTPP3", QPoint(3, 8));

    //nothing here for lambda

    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("PAR_MeasuringMode", QPoint(0, 10));
    p1m1Map->insert("ACT_PQS1", QPoint(1, 10));
    p1m1Map->insert("ACT_PQS2", QPoint(2, 10));
    p1m1Map->insert("ACT_PQS3", QPoint(3, 10));
    p1m1Map->insert("ACT_PQS4", QPoint(4, 10));

    QHash<QString, QPoint> *p1m2Map = new QHash<QString, QPoint>();
    p1m2Map->insert("PAR_MeasuringMode", QPoint(0, 11));
    p1m2Map->insert("ACT_PQS1", QPoint(1, 11));
    p1m2Map->insert("ACT_PQS2", QPoint(2, 11));
    p1m2Map->insert("ACT_PQS3", QPoint(3, 11));
    p1m2Map->insert("ACT_PQS4", QPoint(4, 11));

    QHash<QString, QPoint> *p1m3Map = new QHash<QString, QPoint>();
    p1m3Map->insert("PAR_MeasuringMode", QPoint(0, 12));
    p1m3Map->insert("ACT_PQS1", QPoint(1, 12));
    p1m3Map->insert("ACT_PQS2", QPoint(2, 12));
    p1m3Map->insert("ACT_PQS3", QPoint(3, 12));
    p1m3Map->insert("ACT_PQS4", QPoint(4, 12));

    QHash<QString, QPoint> *rangeMap = new QHash<QString, QPoint>();
    rangeMap->insert("ACT_Frequency", QPoint(4, 13));


    m_actualValueMapping->insert(static_cast<int>(Modules::RmsModule), rmsMap);
    m_actualValueMapping->insert(static_cast<int>(Modules::ThdnModule), thdnMap);
    m_actualValueMapping->insert(static_cast<int>(Modules::DftModule), dftMap);
    m_actualValueMapping->insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_actualValueMapping->insert(static_cast<int>(Modules::Power1Module2), p1m2Map);
    m_actualValueMapping->insert(static_cast<int>(Modules::Power1Module3), p1m3Map);
    m_actualValueMapping->insert(static_cast<int>(Modules::RangeModule), rangeMap);
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
    }

    //P1
    ModelRowPair osci1Pair(m_osciP1Data, 1);
    osci1Pair.m_updateInterval=new QTimer(q_ptr);
    osci1Pair.m_updateInterval->setInterval(valueInterval);
    osci1Pair.m_updateInterval->setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI1", osci1Pair); //UL1
    ModelRowPair osci2Pair(m_osciP1Data, 2);
    osci2Pair.m_updateInterval=new QTimer(q_ptr);
    osci2Pair.m_updateInterval->setInterval(valueInterval);
    osci2Pair.m_updateInterval->setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI4", osci2Pair); //IL1
    //P2
    ModelRowPair osci3Pair(m_osciP2Data, 1);
    osci3Pair.m_updateInterval=new QTimer(q_ptr);
    osci3Pair.m_updateInterval->setInterval(valueInterval);
    osci3Pair.m_updateInterval->setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI2", osci3Pair); //UL2
    ModelRowPair osci4Pair(m_osciP2Data, 2);
    osci4Pair.m_updateInterval=new QTimer(q_ptr);
    osci4Pair.m_updateInterval->setInterval(valueInterval);
    osci4Pair.m_updateInterval->setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI5", osci4Pair); //IL2
    //P3
    ModelRowPair osci5Pair(m_osciP3Data, 1);
    osci5Pair.m_updateInterval=new QTimer(q_ptr);
    osci5Pair.m_updateInterval->setInterval(valueInterval);
    osci5Pair.m_updateInterval->setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI3", osci5Pair); //UL3
    ModelRowPair osci6Pair(m_osciP3Data, 2);
    osci6Pair.m_updateInterval=new QTimer(q_ptr);
    osci6Pair.m_updateInterval->setInterval(valueInterval);
    osci6Pair.m_updateInterval->setSingleShot(true);
    m_osciMapping.insert("ACT_OSCI6", osci6Pair); //IL3
  }

  void setupFftData()
  {
    m_fftTableRoleMapping.insert("ACT_FFT1", FftTableModel::AMP_L1);
    m_fftTableRoleMapping.insert("ACT_FFT2", FftTableModel::AMP_L2);
    m_fftTableRoleMapping.insert("ACT_FFT3", FftTableModel::AMP_L3);
    m_fftTableRoleMapping.insert("ACT_FFT4", FftTableModel::AMP_L4);
    m_fftTableRoleMapping.insert("ACT_FFT5", FftTableModel::AMP_L5);
    m_fftTableRoleMapping.insert("ACT_FFT6", FftTableModel::AMP_L6);
  }

  /**
   * @brief AVM = ActualValueModel
   * @param t_moduleId
   * @return
   */
  QString getAvmNameById(int t_moduleId) {
    switch(t_moduleId) {
      case static_cast<int>(Modules::Power1Module1):
        return "P";
      case static_cast<int>(Modules::Power1Module2):
        return "Q";
      case static_cast<int>(Modules::Power1Module3):
        return "S";
      default:
        Q_ASSERT(false);
        return "ERROR in QString getAvmNameById(int t_moduleId)";
    }
  }

  void setLambda(int m_systemNumber) {
    Q_ASSERT(m_systemNumber>1 || m_systemNumber<3);

    double tmpLambda = 0;
    QModelIndex tmpIndex = m_actValueData->index(9, 0);

    switch(m_systemNumber)
    {
      case 1:
      {
        tmpLambda = m_lambdaS1 > 0 ? m_lambdaP1/m_lambdaS1 : 0;
        break;
      }
      case 2:
      {
        tmpLambda = m_lambdaS2 > 0 ? m_lambdaP2/m_lambdaS2 : 0;
        break;
      }
      case 3:
      {
        tmpLambda = m_lambdaS3 > 0 ? m_lambdaP3/m_lambdaS3 : 0;
        break;
      }
    }

    m_actValueData->setData(tmpIndex, tmpLambda, Qt::UserRole+m_systemNumber); // QML doesn't understand columns, so use roles

  }

  bool handleFetchEvents(VeinEvent::EventData *t_evData, VeinEvent::CommandEvent *t_cEvent)
  {
    bool retVal=false;
    VeinComponent::ComponentData *fetcherData = static_cast<VeinComponent::ComponentData *>(t_evData);
    Q_ASSERT(fetcherData);

    if(fetcherData->eventCommand() == VeinComponent::ComponentData::Command::CCMD_FETCH)
    {
      if(fetcherData->componentName() == m_actualValueComponentName)
      {
        fetcherData->setNewValue(QVariant::fromValue<QObject *>(m_actValueData));
      }
      else if(fetcherData->componentName() == m_osciP1ComponentName)
      {
        fetcherData->setNewValue(QVariant::fromValue<QObject *>(m_osciP1Data));
      }
      else if(fetcherData->componentName() == m_osciP2ComponentName)
      {
        fetcherData->setNewValue(QVariant::fromValue<QObject *>(m_osciP2Data));
      }
      else if(fetcherData->componentName() == m_osciP3ComponentName)
      {
        fetcherData->setNewValue(QVariant::fromValue<QObject *>(m_osciP3Data));
      }
      else if(fetcherData->componentName() == m_fftTableModelComponentName)
      {
        fetcherData->setNewValue(QVariant::fromValue<QObject *>(m_fftTableData));
      }
      else if(fetcherData->componentName() == "EntityName")
      {
        fetcherData->setNewValue(m_entityName);
      }
      fetcherData->setEventOrigin(VeinComponent::ComponentData::EventOrigin::EO_LOCAL);
      fetcherData->setEventTarget(VeinComponent::ComponentData::EventTarget::ET_IRRELEVANT);
      t_cEvent->setEventSubtype(VeinEvent::CommandEvent::EventSubtype::NOTIFICATION);

      retVal = true;
    }
    return retVal;
  }

  bool handleActualValues(QHash<QString, QPoint>* t_componentMapping, VeinComponent::ComponentData *t_cmpData)
  {
    bool retVal = false;
    QPoint valueCoordiantes = t_componentMapping->value(t_cmpData->componentName());
    if(valueCoordiantes.isNull() == false) //nothing is at 0, 0
    {
      QModelIndex mIndex = m_actValueData->index(valueCoordiantes.y(), 0); // QML doesn't understand columns!

      if(t_cmpData->entityId() != static_cast<int>(Modules::DftModule))
      {
        if(t_cmpData->componentName() == "PAR_MeasuringMode") // these values need some string formatting
        {
          // (%Mode) %Name
          QString tmpValue = QString("(%1) %2").arg(t_cmpData->newValue().toString()).arg(getAvmNameById(t_cmpData->entityId()));
          m_actValueData->setData(mIndex, tmpValue, Qt::UserRole+valueCoordiantes.x()); // QML doesn't understand column, so use roles
        }
        else
        {
          if(t_cmpData->entityId() == static_cast<int>(Modules::Power1Module1))
          {
            if(t_cmpData->componentName() == "ACT_PQS1") // P1/S1 lambda calculation
            {
              m_lambdaP1=t_cmpData->newValue().toDouble();
              setLambda(1);
            }
            else if(t_cmpData->componentName() == "ACT_PQS2") // P2/S2 lambda calculation
            {
              m_lambdaP2=t_cmpData->newValue().toDouble();
              setLambda(2);
            }
            else if(t_cmpData->componentName() == "ACT_PQS3") // P3/S3 lambda calculation
            {
              m_lambdaP3=t_cmpData->newValue().toDouble();
              setLambda(3);
            }
          }
          else if(t_cmpData->entityId() == static_cast<int>(Modules::Power1Module3))
          {
            if(t_cmpData->componentName() == "ACT_PQS1") // P1/S1 lambda calculation
            {
              m_lambdaS1=t_cmpData->newValue().toDouble();
              setLambda(1);
            }
            else if(t_cmpData->componentName() == "ACT_PQS2") // P2/S2 lambda calculation
            {
              m_lambdaS2=t_cmpData->newValue().toDouble();
              setLambda(2);
            }
            else if(t_cmpData->componentName() == "ACT_PQS3") // P3/S3 lambda calculation
            {
              m_lambdaS3=t_cmpData->newValue().toDouble();
              setLambda(3);
            }
          }

          //uses the mapped coordinates to insert the data in the model at x,y -> column,row position
          m_actValueData->setData(mIndex, t_cmpData->newValue(), Qt::UserRole+valueCoordiantes.x()); // QML doesn't understand columns, so use roles
        }

      }
      else //these are vectors that need calculation and are aligned to the reference channel
      {
        QList<double> tmpVector = qvariant_cast<QList<double> >(t_cmpData->newValue());
        if(tmpVector.isEmpty() == false)
        {
          double vectorAngle = atan2(tmpVector.at(1), tmpVector.at(0)); //re, im
          if(t_cmpData->componentName() == "ACT_DFTPN1") /// @todo use a user selected reference channel or PLL reference channel
          {
            m_dftReferenceValue = vectorAngle;
          }
          vectorAngle -= m_dftReferenceValue;
          m_actValueData->setData(mIndex, vectorAngle, Qt::UserRole+valueCoordiantes.x());
        }
      }
      retVal = true;
    }
    return retVal;
  }

  bool handleOsciValues(VeinComponent::ComponentData *t_cmpData)
  {
    bool retVal=false;
    ModelRowPair tmpPair = m_osciMapping.value(t_cmpData->componentName(), ModelRowPair(0, 0));
    if(tmpPair.isNull() == false)
    {
      QStandardItemModel *tmpModel = tmpPair.m_model;
      QModelIndex tmpIndex;
      QList<double> tmpData = qvariant_cast<QList<double> >(t_cmpData->newValue());

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

  bool handleFftValues(VeinComponent::ComponentData *t_cmpData)
  {
    bool retVal = false;
    int fftTableRole=m_fftTableRoleMapping.value(t_cmpData->componentName(), 0);
    if(fftTableRole != 0)
    {
      QList<double> tmpData = qvariant_cast<QList<double> >(t_cmpData->newValue());
      QModelIndex fftTableIndex;
      QVector2D tmpVec2d;
      double re, im, angle, length;

      QSignalBlocker blocker(m_fftTableData);
      for(int i=0; i<tmpData.length(); i+=2)
      {
        re = tmpData.at(i);
        im = tmpData.at(i+1);
        tmpVec2d.setX(re);
        tmpVec2d.setY(im);
        length = tmpVec2d.length();

        fftTableIndex = m_fftTableData->index(i/2, 0);
        m_fftTableData->setData(fftTableIndex, length, fftTableRole);
        angle = (i!=0) * atan2(im, re); //first harmonic (0) is a DC value, so it has no phase position
        m_fftTableData->setData(fftTableIndex, angle, fftTableRole+100);
      }
      blocker.unblock();

      retVal = true;
    }
    return retVal;
  }

  Com5003GlueLogic *q_ptr;
  QStandardItemModel *m_actValueData;

  QStandardItemModel *m_osciP1Data;
  QStandardItemModel *m_osciP2Data;
  QStandardItemModel *m_osciP3Data;

  FftTableModel *m_fftTableData;

  //stands for QHash<"entity descriptor", QHash<"component name", 2D coordinates>*>
  template <typename T>
  using CoordinateMapping = QHash<T, QHash<QString, QPoint>*>;

  CoordinateMapping<int> *m_actualValueMapping = new CoordinateMapping<int>();

  QHash<QString, ModelRowPair> m_osciMapping;
  QHash<QString, int> m_fftTableRoleMapping;

  double m_dftReferenceValue; //vector diagram reference angle
  const int m_entityId = 50;

  const QString m_actualValueComponentName = "ActualValueModel";
  const QString m_osciP1ComponentName = "OSCIP1Model";
  const QString m_osciP2ComponentName = "OSCIP2Model";
  const QString m_osciP3ComponentName = "OSCIP3Model";

  const QString m_fftTableModelComponentName = "FFTTableModel";

  const QString m_entityName = "Local.GlueLogic";

  double m_lambdaP1=0;
  double m_lambdaP2=0;
  double m_lambdaP3=0;

  double m_lambdaS1=0;
  double m_lambdaS2=0;
  double m_lambdaS3=0;

  enum class Modules : int {
    GlueLogic = 50,
    ModeModule = 1000,
    RangeModule = 1001,
    SampleModule = 1002,
    RmsModule = 1003,
    DftModule = 1004,
    FftModule = 1005,
    Power1Module1 = 1006, // P
    Power1Module2 = 1007, // Q
    Power1Module3 = 1008, // S
    //Power1Module4 = 1009, // P+Q+S for SCPI clients
    ThdnModule = 1010,
    OsciModule = 1011,
    Sec1Module = 1012,
    Power3Module = 1013,
    //ScpiModule = 1014,
  };

  friend class Com5003GlueLogic;
};

Com5003GlueLogic::Com5003GlueLogic(QObject *t_parent) :
  VeinEvent::EventSystem(t_parent),
  d_ptr(new Com5003GlueLogicPrivate(this))
{
}

Com5003GlueLogic::~Com5003GlueLogic()
{
  delete d_ptr;
  d_ptr=0;
}

void Com5003GlueLogic::startIntrospection()
{
  d_ptr->setupIntrospection();
}

bool Com5003GlueLogic::processEvent(QEvent *t_event)
{
  using namespace VeinEvent;
  bool retVal = false;
  if(t_event->type()==CommandEvent::eventType())
  {
    CommandEvent *cEvent = static_cast<CommandEvent *>(t_event);
    Q_ASSERT(cEvent != nullptr);

    EventData *evData = cEvent->eventData();
    Q_ASSERT(evData != nullptr);

    switch(evData->entityId())
    {
      case static_cast<int>(d_ptr->Modules::GlueLogic):
      {
        if(evData->type() == VeinComponent::ComponentData::dataType())
        {
          retVal = d_ptr->handleFetchEvents(evData, cEvent);
        }
        else if(evData->type() == VeinComponent::EntityData::dataType())
        {
          VeinComponent::EntityData * eData = static_cast<VeinComponent::EntityData *>(evData);
          Q_ASSERT(eData != nullptr);
          if(eData->eventCommand() == VeinComponent::EntityData::ECMD_SUBSCRIBE)
          {
            retVal = true;
            t_event->accept();
            d_ptr->setupIntrospection();
          }
        }
        break;
      }
      case static_cast<int>(d_ptr->Modules::OsciModule):
      {
        if (evData->type() == VeinComponent::ComponentData::dataType())
        {
          if(cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION)
          {
            VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
            Q_ASSERT(cmpData != nullptr);

            retVal = d_ptr->handleOsciValues(cmpData);
          }
        }
        break;
      }
      case static_cast<int>(d_ptr->Modules::FftModule):
      {
        if (evData->type() == VeinComponent::ComponentData::dataType())
        {
          if(cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION)
          {
            VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
            Q_ASSERT(cmpData);

            retVal = d_ptr->handleFftValues(cmpData);
          }
        }
        break;
      }
      default: /// @note values handled earlier in the switch case will not show up in the actual values table!
      {
        if (evData->type() == VeinComponent::ComponentData::dataType())
        {
          if(cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION)
          {
            auto componentMapping = d_ptr->m_actualValueMapping->value(evData->entityId(), nullptr);
            if(Q_UNLIKELY(componentMapping != nullptr))
            {
              VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
              Q_ASSERT(cmpData);

              retVal = d_ptr->handleActualValues(componentMapping, cmpData);
            }
          }
        }
        break;
      }
    }
  }
  return retVal;
}
