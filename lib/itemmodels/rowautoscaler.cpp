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

RowAutoScaler::TSingleScaleResult RowAutoScaler::scaleSingleVal(double absVal)
{
    TSingleScaleResult res;
    if(absVal > 1) {
        if(scaleSingleValForPrefix(absVal, 1e9, "G", res))
            return res;
        if(scaleSingleValForPrefix(absVal, 1e6, "M", res))
            return res;
        if(scaleSingleValForPrefix(absVal, 1e3, "k", res))
            return res;
    }
    if(scaleSingleValForPrefix(absVal, 1e0, "", res))
        return res;
    if(scaleSingleValForPrefix(absVal, 1e-3, "m", res))
        return res;
    if(scaleSingleValForPrefix(absVal, 1e-6, "µ", res))
        return res;
    if(scaleSingleValForPrefix(absVal, 1e-9, "n", res))
        return res;
    return res;
}

bool RowAutoScaler::scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &result)
{
    if(absVal > limit) {
        result.scaleFactor = 1/limit;
        result.unitPrefix = limitPrefix;
        return true;
    }
    return false;
}

