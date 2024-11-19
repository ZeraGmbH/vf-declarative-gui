#include "axisautoscaler.h"
#include <cmath>

AxisAutoScaler::AxisAutoScaler(QObject *parent)
    :QObject{parent}
{}

void AxisAutoScaler::reset(double minValue, double maxValue)
{
    m_minValue = minValue;
    m_maxValue = maxValue;
}

void AxisAutoScaler::scaleToNewActualValue(double actualValue)
{
    m_minValue = actualValue < m_minValue ? actualValue : m_minValue;
    m_maxValue = actualValue > m_maxValue ? actualValue : m_maxValue;
}

int AxisAutoScaler::getRoundedMinValue()
{
    return floor(m_minValue/ 10) * 10;
}

int AxisAutoScaler::getRoundedMaxValue()
{
    return ceil(m_maxValue/ 10) * 10;
}
