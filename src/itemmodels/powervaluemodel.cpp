#include "powervaluemodel.h"
#include "vfcomponenteventdispatcher.h"
#include <QJsonDocument>

PowerValueModel::PowerValueModel() :
    TableEventItemModelBase(5, 1)
{
}

void PowerValueModel::setLabelsAndUnits()
{
    using namespace CommonTable;
    //column names
    QModelIndex mIndex = index(0, 0);
    setData(mIndex, m_translation->TrValue("L1"), RoleIndexes::L1);
    setData(mIndex, m_translation->TrValue("L2"), RoleIndexes::L2);
    setData(mIndex, m_translation->TrValue("L3"), RoleIndexes::L3);
    setData(mIndex, "Σ", RoleIndexes::SUM);
    setData(mIndex, "[ ]", RoleIndexes::UNIT);

    //row names
    mIndex = index(1, 0);
    setData(mIndex, m_translation->TrValue("P"), RoleIndexes::NAME);
    mIndex = index(2, 0);
    setData(mIndex, m_translation->TrValue("Q"), RoleIndexes::NAME);
    mIndex = index(3, 0);
    setData(mIndex, m_translation->TrValue("S"), RoleIndexes::NAME);

    //update for units
    updateMModeTranslations();
}

void PowerValueModel::setupMapping()
{
    using namespace CommonTable;

    QHash<QString, QPoint> *p1m1Map = new QHash<QString, QPoint>();
    p1m1Map->insert("ACT_PowerDisplayName", QPoint(RoleIndexes::NAME, 1));
    p1m1Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, 1));
    p1m1Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, 1));
    p1m1Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, 1));
    p1m1Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM, 1));
    p1m1Map->insert("INF_ModuleInterface", QPoint(RoleIndexes::UNIT, 1));

    QHash<QString, QPoint> *p1m2Map = new QHash<QString, QPoint>();
    p1m2Map->insert("ACT_PowerDisplayName", QPoint(RoleIndexes::NAME, 2));
    p1m2Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, 2));
    p1m2Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, 2));
    p1m2Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, 2));
    p1m2Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM, 2));
    p1m2Map->insert("INF_ModuleInterface", QPoint(RoleIndexes::UNIT, 2));

    QHash<QString, QPoint> *p1m3Map = new QHash<QString, QPoint>();
    p1m3Map->insert("ACT_PowerDisplayName", QPoint(RoleIndexes::NAME, 3));
    p1m3Map->insert("ACT_PQS1", QPoint(RoleIndexes::L1, 3));
    p1m3Map->insert("ACT_PQS2", QPoint(RoleIndexes::L2, 3));
    p1m3Map->insert("ACT_PQS3", QPoint(RoleIndexes::L3, 3));
    p1m3Map->insert("ACT_PQS4", QPoint(RoleIndexes::SUM, 3));
    p1m3Map->insert("INF_ModuleInterface", QPoint(RoleIndexes::UNIT, 3));

    m_valueMapping.insert(static_cast<int>(Modules::Power1Module1), p1m1Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module2), p1m2Map);
    m_valueMapping.insert(static_cast<int>(Modules::Power1Module3), p1m3Map);
}

QHash<int, QByteArray> PowerValueModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::L1, "L1");
    roles.insert(RoleIndexes::L2, "L2");
    roles.insert(RoleIndexes::L3, "L3");
    roles.insert(RoleIndexes::SUM, "Sum");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}

void PowerValueModel::insertPowerName(int yCoordinate, QString measName)
{
    m_dynamicPowerName.insert(yCoordinate, measName);
    updateMModeTranslations();
}

void PowerValueModel::insertPowerUnit(int yCoordinate, QString measUnit)
{
    m_dynamicPowerUnit.insert(yCoordinate, measUnit);
    updateMModeTranslations();
}

void PowerValueModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    if(cData->componentName() == QLatin1String("ACT_PowerDisplayName")) {
        QString newValue = cData->newValue().toString();
        insertPowerName(valueCoordiates.y(), newValue);
    }

    else if(cData->componentName() == QLatin1String("INF_ModuleInterface")) {
        QString newValue = cData->newValue().toString();
        const auto json = QJsonDocument::fromJson(newValue.toUtf8());
        QJsonValue unit = json["ComponentInfo"]["ACT_PQS1"]["Unit"];
        insertPowerUnit(valueCoordiates.y(), unit.toString());
    }
    else {
        TableEventItemModelBase::handleComponentChangeCoord(cData, valueCoordiates);
    }
}

void PowerValueModel::updateMModeTranslations()
{
    using namespace CommonTable;
    QModelIndex mIndex = index(1, 0);
    setData(mIndex, QString("%1").arg(m_translation->TrValue(m_dynamicPowerName.value(mIndex.row())).toString()), RoleIndexes::NAME);
    setData(mIndex, QString("%1").arg(m_translation->TrValue(m_dynamicPowerUnit.value(mIndex.row())).toString()), RoleIndexes::UNIT);

    mIndex = index(2, 0);
    setData(mIndex, QString("%1").arg(m_translation->TrValue(m_dynamicPowerName.value(mIndex.row())).toString()), RoleIndexes::NAME);
    setData(mIndex, QString("%1").arg(m_translation->TrValue(m_dynamicPowerUnit.value(mIndex.row())).toString()), RoleIndexes::UNIT);

    mIndex = index(3, 0);
    setData(mIndex, QString("%1").arg(m_translation->TrValue(m_dynamicPowerName.value(mIndex.row())).toString()), RoleIndexes::NAME);
    setData(mIndex, QString("%1").arg(m_translation->TrValue(m_dynamicPowerUnit.value(mIndex.row())).toString()), RoleIndexes::UNIT);

}
