#include "vfcomponenteventdispatcher.h"
#include "temphumiditypressuremodel.h"

enum class LineDefinitions : int {
    LINE_HEADER,
    LINE_VALUES,

    LINE_COUNT
};

#define lineVal(val) static_cast<int>(LineDefinitions::val)

TempHumidityPressureModel::TempHumidityPressureModel() :
    TableEventItemModelBase(lineVal(LINE_COUNT), 1)
{
}

TempHumidityPressureModel::~TempHumidityPressureModel()
{
}

void TempHumidityPressureModel::setLabelsAndUnits()
{
    // header line
    QModelIndex mIndex = index(lineVal(LINE_HEADER), 0);
    setData(mIndex, "T [°C]", RoleIndexes::Temperature);
    setData(mIndex, "H [%]", RoleIndexes::Humidity);
    setData(mIndex, "P [hPa]", RoleIndexes::Pressure);
}

void TempHumidityPressureModel::setupMapping()
{
    QHash<QString, QPoint> *tempMap = new QHash<QString, QPoint>();
    tempMap->insert("ACT_TemperatureC", QPoint(RoleIndexes::Temperature, lineVal(LINE_VALUES)));
    QHash<QString, QPoint> *humidityMap = new QHash<QString, QPoint>();
    humidityMap->insert("ACT_Humidity", QPoint(RoleIndexes::Humidity, lineVal(LINE_VALUES)));
    QHash<QString, QPoint> *pressureMap  = new QHash<QString, QPoint>();
    pressureMap->insert("ACT_AirPressure", QPoint(RoleIndexes::Pressure, lineVal(LINE_VALUES)));

    m_valueMapping.insert(static_cast<int>(Modules::BleModule1), tempMap);
    m_valueMapping.insert(static_cast<int>(Modules::BleModule1), humidityMap);
    m_valueMapping.insert(static_cast<int>(Modules::BleModule1), pressureMap);
}

QHash<int, QByteArray> TempHumidityPressureModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::Temperature, "Temperature");
    roles.insert(RoleIndexes::Humidity, "Humidity");
    roles.insert(RoleIndexes::Pressure, "Pressure");
    return roles;
}

void TempHumidityPressureModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    int columnRole = 0;
    double newValue = cData->newValue().toDouble();

    if(valueCoordiates == QPoint(RoleIndexes::Temperature, lineVal(LINE_VALUES)))
        columnRole = RoleIndexes::Temperature;
    else if(valueCoordiates == QPoint(RoleIndexes::Humidity, lineVal(LINE_VALUES)))
        columnRole = RoleIndexes::Humidity;
    else if(valueCoordiates == QPoint(RoleIndexes::Pressure, lineVal(LINE_VALUES)))
        columnRole = RoleIndexes::Pressure;

    if(columnRole > 0) {
        QModelIndex mIndex = index(lineVal(LINE_VALUES), 0);
        setData(mIndex, newValue, columnRole);
    }
    else
        TableEventItemModelBase::handleComponentChangeCoord(cData, valueCoordiates);

}
