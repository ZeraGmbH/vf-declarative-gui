#ifndef AXISAUTOSCALER_H
#define AXISAUTOSCALER_H

#include <QObject>

class AxisAutoScaler : public QObject
{
    Q_OBJECT
public:
    explicit AxisAutoScaler(QObject *parent = nullptr);
    Q_INVOKABLE void reset(double minValue, double maxValue);
    Q_INVOKABLE void scaleToNewActualValue(double actualValue);
    Q_INVOKABLE int getRoundedMinValue();
    Q_INVOKABLE int getRoundedMaxValue();

private:
    double m_minValue = 0.0;
    double m_maxValue = 0.0;
};

#endif // AXISAUTOSCALER_H
