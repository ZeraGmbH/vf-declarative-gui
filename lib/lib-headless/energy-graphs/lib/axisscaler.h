#ifndef AXISSCALER_H
#define AXISSCALER_H

#include <QObject>

class AxisScaler : public QObject
{
    Q_OBJECT
public:
    explicit AxisScaler(QObject *parent = nullptr);

    Q_INVOKABLE void reset();
    Q_INVOKABLE void scaleValue(double value);
    Q_INVOKABLE int getMinValue();
    Q_INVOKABLE int getMaxValue();

private:
    void scalePositiveValue(double value);
    void scaleNegativeValue(double value);

    int m_minValue = 0;
    int m_maxValue = 0;
};

#endif // AXISSCALER_H
