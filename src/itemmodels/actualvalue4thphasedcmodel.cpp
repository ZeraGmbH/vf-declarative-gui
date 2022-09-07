#include "actualvalue4thphasedcmodel.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

ActualValue4thPhaseDcModel::ActualValue4thPhaseDcModel(QObject *t_parent) :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1, t_parent)
{
}

ActualValue4thPhaseDcModel::~ActualValue4thPhaseDcModel()
{
}

void ActualValue4thPhaseDcModel::setupTable()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "DC", RoleIndexes::NAME);
    setData(mIndex, "U [V]", RoleIndexes::DC_U);
    setData(mIndex, "I [A]", RoleIndexes::DC_I);
    setData(mIndex, "P [W]", RoleIndexes::DC_P);
}

void ActualValue4thPhaseDcModel::setupMapping()
{
    // DC: we cannot use RMS
    QHash<QString, QPoint> *fftMap = new QHash<QString, QPoint>();
    fftMap->insert("ACT_FFT7", QPoint(RoleIndexes::DC_U, lineVal(LINE_VALUES)));
    fftMap->insert("ACT_FFT8", QPoint(RoleIndexes::DC_I, lineVal(LINE_VALUES)));

    QHash<QString, QPoint> *p1m4Map = new QHash<QString, QPoint>();
    p1m4Map->insert("ACT_PQS1", QPoint(RoleIndexes::DC_P, lineVal(LINE_VALUES)));

    m_valueMapping.insert(static_cast<int>(Modules::FftModule), fftMap);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module4), p1m4Map);
}

void ActualValue4thPhaseDcModel::updateTranslation()
{
    setupTable();
}

QHash<int, QByteArray> ActualValue4thPhaseDcModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "NAME");
    roles.insert(RoleIndexes::DC_U, "DC_U");
    roles.insert(RoleIndexes::DC_I, "DC_I");
    roles.insert(RoleIndexes::DC_P, "DC_P");
    return roles;
}

void ActualValue4thPhaseDcModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
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
