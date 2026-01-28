#include "axisscaler.h"
#include <QtMath>

AxisScaler::AxisScaler(QObject *parent)
    : QObject{parent}
{}

void AxisScaler::reset()
{
    m_minValue = 0;
    m_maxValue = 0;
}

void AxisScaler::scaleAxis(double value)
{
    if(value >= 0)
        scalePositiveValue(value);
    else
        scaleNegativeValue(value);
}

int AxisScaler::getMinValue()
{
    return m_minValue;
}

int AxisScaler::getMaxValue()
{
    return m_maxValue;
}

void AxisScaler::scalePositiveValue(double value)
{
    int newMax = m_maxValue;
    if (value < 1)
        newMax = 1;
    else if (value < 10)
        newMax = 10;
    else if (value < 100)
        newMax = qCeil(value / 10) * 10;
    else
        newMax = qCeil(value / 100) * 100;
    m_maxValue = qMax(m_maxValue, newMax);
}

void AxisScaler::scaleNegativeValue(double value)
{
    int newMin;
    if (value > -1)
        newMin = -1;
    else if (value > -10)
        newMin = -10;
    else if (value > -100)
        newMin = qFloor(value / 10) * 10;
    else
        newMin = qFloor(value / 100) * 100;
    m_minValue = qMin(m_minValue, newMin);
}

