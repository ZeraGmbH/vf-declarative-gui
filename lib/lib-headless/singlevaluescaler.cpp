#include "singlevaluescaler.h"
#include <math.h>

SingleValueScaler::SingleValueScaler(QObject *parent)
    : QObject{parent}
{
}

bool SingleValueScaler::scaleSingleValForQML(double val)
{
    double absVal = fabs(val);
    TSingleScaleResult singleResult;
    if(scaleSingleValForPrefix(absVal, 1e15, "P", singleResult))
        return true;
    if(scaleSingleValForPrefix(absVal, 1e12, "T", singleResult))
        return true;
    if(scaleSingleValForPrefix(absVal, 1e9, "G", singleResult))
        return true;
    if(scaleSingleValForPrefix(absVal, 1e6, "M", singleResult))
        return true;
    if(scaleSingleValForPrefix(absVal, 1e3, "k", singleResult))
        return true;
    if(scaleSingleValForPrefix(absVal, 1e0, "", singleResult))
        return true;
    setScale(1e-3, "m", singleResult);
    return false;
}

SingleValueScaler::TSingleScaleResult SingleValueScaler::scaleSingleVal(double val)
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

void SingleValueScaler::setScaleFactor(double scaleFactor)
{
    m_scaleFactor = scaleFactor;
    emit scaleFactorChanged();
}

double SingleValueScaler::getScaleFactor()
{
    return m_scaleFactor;
}

void SingleValueScaler::setUnitPrefix(QString unitPrefix)
{
    m_unitPrefix = unitPrefix;
    emit unitPrefixChanged();
}

QString SingleValueScaler::getUnitPrefix()
{
    return m_unitPrefix;
}

void SingleValueScaler::setScale(double limit, QString limitPrefix, TSingleScaleResult &singleResult)
{
    singleResult.scaleFactor = 1/limit;
    m_hysteresisValue = limit * HYSTERESIS;
    singleResult.unitPrefix = limitPrefix;
    setScaleFactor(1/limit);
    setUnitPrefix(limitPrefix);
}

bool SingleValueScaler::scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &singleResult)
{
    if(absVal >= limit-m_hysteresisValue) {
        setScale(limit, limitPrefix, singleResult);
        return true;
    }
    return false;
}
