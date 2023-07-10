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
    TSingleScaleResult singleResult;
    if(scaleSingleValForPrefix(absVal, 1e9, "G", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e6, "M", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e3, "k", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e0, "", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e-3, "m", singleResult))
        return singleResult;
    setScale(1e-6, "µ", singleResult);
    return singleResult;
}

void RowAutoScaler::setScale(double limit, QString limitPrefix, TSingleScaleResult &singleResult)
{
    singleResult.scaleFactor = 1/limit;
    m_hysteresisValue = limit * HYSTERESIS;
    singleResult.unitPrefix = limitPrefix;
}

bool RowAutoScaler::scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &singleResult)
{
    if(absVal >= limit-m_hysteresisValue) {
        setScale(limit, limitPrefix, singleResult);
        return true;
    }
    return false;
}

