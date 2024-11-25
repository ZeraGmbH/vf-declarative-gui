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
    double maxAbsVal = 0.0;
    for(auto valColumnRole : roleIdxSingleValues) {
        if(m_unscaledColumnValues.contains(valColumnRole)) {
            double absVal = fabs(m_unscaledColumnValues[valColumnRole].toDouble());
            if(absVal > maxAbsVal)
                maxAbsVal = absVal;
        }
    }
    const TSingleScaleResult res = scaleSingleVal(maxAbsVal);
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

RowAutoScaler::TSingleScaleResult RowAutoScaler::scaleSingleVal(double val)
{
    double absVal = fabs(val);
    TSingleScaleResult singleResult;
    if(scaleSingleValForPrefix(absVal, 1e15, "P", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e12, "T", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e9, "G", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e6, "M", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e3, "k", singleResult))
        return singleResult;
    if(scaleSingleValForPrefix(absVal, 1e0, "", singleResult))
        return singleResult;
    setScale(1e-3, "m", singleResult);
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

