#include "axissetter.h"
#include "singlevaluescaler.h"

AxisSetter::AxisSetter(QObject *parent)
    : QObject{parent}
{
}

void AxisSetter::setAxis(QValueAxis *axis)
{
    m_axis = axis;
    if(m_axis) {
        m_axis->setMin(m_min);
        m_axis->setMax(m_max);
        scaleAxis(m_max);
    }
}

QValueAxis *AxisSetter::getAxis()
{
    return m_axis;
}

void AxisSetter::setMin(double min)
{
    if(m_min != min) {
        m_min = min;
        if (m_axis) {
            m_axis->setMin(min);
            emit minChanged(min);
        }
    }
}

double AxisSetter::getMin()
{
    return m_min;
}

void AxisSetter::setXAxis(bool isXaxis)
{
    m_isXaxis = isXaxis;
}

bool AxisSetter::isXAxis()
{
    return m_isXaxis;
}

void AxisSetter::setMax(double max)
{
    if(m_max != max) {
        m_max = max;
        if (m_axis) {
            m_axis->setMax(max);
            scaleAxis(max);
            emit maxChanged(max);
        }
    }
}

double AxisSetter::getMax()
{
    return m_max;
}

double AxisSetter::getScale()
{
    return m_scale;
}

QString AxisSetter::getPrefix()
{
    return m_unitPrefix;
}

void AxisSetter::scaleAxis(double max)
{
    //scale only Y-axes
    if(!m_isXaxis) {
        SingleValueScaler singleValueScaler;
        singleValueScaler.scaleSingleValForQML(max);
        m_scale = singleValueScaler.getScaleFactor();
        emit scaleChanged(m_scale);
        m_unitPrefix = singleValueScaler.getUnitPrefix();
        emit prefixChanged(m_unitPrefix);
    }
}
