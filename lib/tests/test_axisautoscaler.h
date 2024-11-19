#ifndef TEST_AXISAUTOSCALER_H
#define TEST_AXISAUTOSCALER_H

#include <QObject>

class test_axisautoscaler : public QObject
{
    Q_OBJECT
private slots:
    void scaleMax();
    void scaleMin();
    void resetScaling();
};

#endif // TEST_AXISAUTOSCALER_H
