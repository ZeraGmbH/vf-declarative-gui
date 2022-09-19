#include "actualvaluedcperphase.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES_PH1,
    LINE_VALUES_PH2,
    LINE_VALUES_PH3,
    LINE_VALUES_PH4,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueDCPerPhase::ActualValueDCPerPhase() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueDCPerPhase::setLabelsAndUnits()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "DC", RoleIndexes::NAME);
    setData(mIndex, "U [V]", RoleIndexes::DC_U);
    setData(mIndex, "I [A]", RoleIndexes::DC_I);
    setData(mIndex, "P [W]", RoleIndexes::DC_P);
}

void ActualValueDCPerPhase::setupMapping()
{
    // DC: we cannot use RMS
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_FFT1", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES_PH1)));
    fftMap->insert("ACT_FFT2", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES_PH1)));
    fftMap->insert("ACT_FFT3", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES_PH2)));
    fftMap->insert("ACT_FFT4", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES_PH2)));
    fftMap->insert("ACT_FFT5", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES_PH3)));
    fftMap->insert("ACT_FFT6", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES_PH3)));
    fftMap->insert("ACT_FFT7", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES_PH4)));
    fftMap->insert("ACT_FFT8", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES_PH4)));

    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES_PH1)));
    QHash<QString, QPoint> *p1m2Map = new QHash<QString, QPoint>();
    p1m2Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES_PH2)));
    QHash<QString, QPoint> *p1m3Map = new QHash<QString, QPoint>();
    p1m3Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES_PH3)));
    QHash<QString, QPoint> *p1m4Map = new QHash<QString, QPoint>();
    p1m4Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES_PH4)));

    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module2), p1m2Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module3), p1m3Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module4), p1m4Map);
}

QHash<int, QByteArray> ActualValueDCPerPhase::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "NAME");
    roles.insert(RoleIndexes::DC_U, "DC_U");
    roles.insert(RoleIndexes::DC_I, "DC_I");
    roles.insert(RoleIndexes::DC_P, "DC_P");
    return roles;
}

void ActualValueDCPerPhase::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    if(cData->entityId() == static_cast<int>(Modules::FftModule)) {
        const QList<double> fftValList = qvariant_cast<QList<double>>(cData->newValue());
        if(fftValList.count() > 1) {
            QModelIndex mIndex = index(valueCoordiates.y(), 0);
            setData(mIndex, fftValList[0], valueCoordiates.x());
        }
    }
    else {
        TableEventItemModelBase::handleComponentChangeCoord(cData, valueCoordiates);
    }
}
