#include "rowautoscaler.h"
#include <math.h>

RowAutoScaler::RowAutoScaler()
{
}

void RowAutoScaler::setUnscaledValue(int columnRole, QVariant newValue)
{
    m_unscaledColumnValues[columnRole] = newValue;
}

RowAutoScaler::TRowScaleResult RowAutoScaler::scaleRow(QString baseUnit, QList<int> roleIdxSingleValues)
{
    TRowScaleResult result;
    double maxAbsVal = 0.0;
    for(auto valColumnRole : roleIdxSingleValues) {
        if(m_unscaledColumnValues.contains(valColumnRole)) {
            double absVal = fabs(m_unscaledColumnValues[valColumnRole].toDouble());
            if(absVal > maxAbsVal)
                maxAbsVal = absVal;
        }
    }
    TSingleScaleResult res = scaleSingleVal(maxAbsVal);
    result.scaledUnit = res.unitPrefix + baseUnit;

    for(auto iter = m_unscaledColumnValues.constBegin(); iter != m_unscaledColumnValues.constEnd(); ++iter) {
        int columnRow = iter.key();
        double unscaledValue = iter.value().toDouble();
        double scaledValue = unscaledValue * res.scaleFactor;
        result.scaledColumnValues[columnRow] = scaledValue;
    }
    return result;
}

RowAutoScaler::TSingleScaleResult RowAutoScaler::scaleSingleVal(double val)
{
    TSingleScaleResult res;
    // no scale yet
    res.scaleFactor = 1;
    res.unitPrefix = "";
    return res;
}
