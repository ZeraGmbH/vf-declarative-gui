#include "actualvaluedcperphaseumodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES_U,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueDCPerPhaseUModel::ActualValueDCPerPhaseUModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueDCPerPhaseUModel::setLabelsAndUnits()
{
    using namespace CommonTable;

    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "DC", RoleIndexes::NAME);
    setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
    setData(mIndex, m_translation->TrValue("AUX"), RoleIndexes::AUX);

    mIndex = index(lineVal(LINE_VALUES_U), 0);
    setData(mIndex, m_translation->TrValue("U"), RoleIndexes::NAME);
    setData(mIndex, "V", RoleIndexes::UNIT);
}

void ActualValueDCPerPhaseUModel::setupMapping()
{
    using namespace CommonTable;
    // DC: we cannot use RMS
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_FFT1", QPoint(RoleIndexes::L1, lineVal(LINE_VALUES_U)));
    fftMap->insert("ACT_FFT2", QPoint(RoleIndexes::L2, lineVal(LINE_VALUES_U)));
    fftMap->insert("ACT_FFT3", QPoint(RoleIndexes::L3, lineVal(LINE_VALUES_U)));
    fftMap->insert("ACT_FFT7", QPoint(RoleIndexes::AUX, lineVal(LINE_VALUES_U)));

    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
}

QHash<int, QByteArray> ActualValueDCPerPhaseUModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::L1, "L1");
    roles.insert(RoleIndexes::L2, "L2");
    roles.insert(RoleIndexes::L3, "L3");
    roles.insert(RoleIndexes::AUX, "AUX");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}

void ActualValueDCPerPhaseUModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
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

