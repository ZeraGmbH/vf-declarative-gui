#include "rowautoscaler.h"

RowAutoScaler::RowAutoScaler()
{
}

void RowAutoScaler::setUnscaledValue(int columnRole, QVariant newValue)
{
    m_unscaledColumnValues[columnRole] = newValue;
}

RowAutoScaler::TScaleResult RowAutoScaler::doScale(QString baseUnit)
{
    TScaleResult result;
    // no scale yet
    result.scaledUnit = baseUnit;
    for(auto iter = m_unscaledColumnValues.constBegin(); iter != m_unscaledColumnValues.constEnd(); ++iter) {
        int columnRow = iter.key();
        QVariant unscaledValue = iter.value();

        result.scaledColumnValues[columnRow] = unscaledValue;
    }
    return result;
}
