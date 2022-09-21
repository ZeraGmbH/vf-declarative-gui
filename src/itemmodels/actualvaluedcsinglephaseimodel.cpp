#include "actualvaluedcsinglephaseimodel.h"
#include "vfcomponenteventdispatcher.h"

enum class LineDefinitions : int {
    LINE_VALUE_I,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValueDCSinglePhaseIModel::ActualValueDCSinglePhaseIModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

void ActualValueDCSinglePhaseIModel::setLabelsAndUnits()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(lineVal(LINE_VALUE_I), 0);
    setData(mIndex, m_translation->TrValue("I"), RoleIndexes::NAME);
    setData(mIndex, "A", RoleIndexes::UNIT);
}

void ActualValueDCSinglePhaseIModel::setupMapping()
{
    using namespace CommonTable;
    // DC: we cannot use RMS
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_FFT8", QPoint(RoleIndexes::AUX, lineVal(LINE_VALUE_I)));

    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
}

QHash<int, QByteArray> ActualValueDCSinglePhaseIModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::AUX, "AUX");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}

void ActualValueDCSinglePhaseIModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    if(cData->entityId() == static_cast<int>(Modules::FftModule)) {
        const QList<double> fftValList = qvariant_cast<QList<double>>(cData->newValue());
        if(fftValList.count() > 1) {
            QModelIndex mIndex = index(valueCoordiates.y(), 0);
            setData(mIndex, fftValList[0], valueCoordiates.x());
        }
    }
}