#include "rowautoscaler.h"
#include <math.h>

RowAutoScaler::RowAutoScaler()
{
    m_singleValueScaler = new SingleValueScaler();
}

void RowAutoScaler::setUnscaledValue(int columnRole, QVariant newValue)
{
    m_unscaledColumnValues[columnRole] = newValue;
}

SingleValueScaler *RowAutoScaler::getSingleValueScaler()
{
    return m_singleValueScaler;
}

RowAutoScaler::TRowScaleResult RowAutoScaler::scaleRow(QString baseUnit, QList<int> roleIdxSingleValues)
{
    double maxAbsVal = 0.0;
    for(auto valColumnRole : roleIdxSingleValues) {
        if(m_unscaledColumnValues.contains(valColumnRole)) {
            double absVal = fabs(m_unscaledColumnValues[valColumnRole].toDouble());
            if(absVal > maxAbsVal)
                maxAbsVal = absVal;
        }
    }
    const SingleValueScaler::TSingleScaleResult res = getSingleValueScaler()->scaleSingleVal(maxAbsVal);
    TRowScaleResult result;
    result.scaledUnit = res.unitPrefix + baseUnit;

    for(auto iter = m_unscaledColumnValues.constBegin(); iter != m_unscaledColumnValues.constEnd(); ++iter) {
        const int columnRow = iter.key();
        const double unscaledValue = iter.value().toDouble();
        const double scaledValue = unscaledValue * res.scaleFactor;
        result.scaledColumnValues[columnRow] = scaledValue;
    }
    return result;
}


