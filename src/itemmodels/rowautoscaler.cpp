#include "rowautoscaler.h"

RowAutoScaler::RowAutoScaler()
{
}

void RowAutoScaler::setUnscaledValue(int columnRole, QVariant newValue)
{
    m_unscaledColumnValues[columnRole] = newValue;
}

void RowAutoScaler::doScale(QString baseUnit, QString &scaledUnit, QHash<int, QVariant> &scaledColumnValues)
{
    // no scale yet
    scaledUnit = "k" + baseUnit;
    for(auto iter = m_unscaledColumnValues.constBegin(); iter != m_unscaledColumnValues.constEnd(); ++iter) {
        int columnRow = iter.key();
        QVariant unscaledValue = iter.value();

        scaledColumnValues[columnRow] = unscaledValue;
    }
}
