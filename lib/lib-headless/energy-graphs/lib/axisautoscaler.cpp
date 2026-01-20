#include "axisautoscaler.h"
#include <cmath>

AxisAutoScaler::AxisAutoScaler(QObject *parent)
    :QObject{parent}
{}

void AxisAutoScaler::reset(double minValue, double maxValue)
{
    m_minValue = minValue;
    m_maxValue = maxValue;
    calculateMargin();
}

void AxisAutoScaler::scaleToNewActualValue(double actualValue)
{
    m_minValue = actualValue < m_minValue ? actualValue : m_minValue;
    m_maxValue = actualValue > m_maxValue ? actualValue : m_maxValue;
    calculateMargin();
}

int AxisAutoScaler::roundDownward(double value)
{
    return floor(value/ 10) * 10;
}

int AxisAutoScaler::roundUpward(double value)
{
    return ceil(value/ 10) * 10;
}

int AxisAutoScaler::getPowerRoundedMinValueWithMargin()
{
    return roundDownward(m_minValue)- (m_margin);
}

int AxisAutoScaler::getRoundedMaxValueWithMargin()
{
    return roundUpward(m_maxValue) + (m_margin);
}

int AxisAutoScaler::getUIRoundedMinValueWithMargin()
{
    int min = roundDownward(m_minValue)- (m_margin);
    if(min < 0)
        return 0;
    return min;
}

void AxisAutoScaler::calculateMargin()
{
    //margin is calculated with rounded min/max
    m_margin = ((roundUpward(m_maxValue) - roundDownward(m_minValue)) / 4) / 2;
}
