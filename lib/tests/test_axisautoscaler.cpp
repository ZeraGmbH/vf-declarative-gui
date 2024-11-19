#include "test_axisautoscaler.h"
#include "axisautoscaler.h"
#include <QTest>

QTEST_MAIN(test_axisautoscaler)

void test_axisautoscaler::scaleMax()
{
    AxisAutoScaler axisScaler;
    QCOMPARE(axisScaler.getRoundedMinValue(), 0);//initial value
    QCOMPARE(axisScaler.getRoundedMaxValue(), 0);//initial value
    axisScaler.scaleToNewActualValue(27.5);
    QCOMPARE(axisScaler.getRoundedMinValue(), 0);
    QCOMPARE(axisScaler.getRoundedMaxValue(), 30);
}

void test_axisautoscaler::scaleMin()
{
    AxisAutoScaler axisScaler;
    QCOMPARE(axisScaler.getRoundedMinValue(), 0);//initial value
    QCOMPARE(axisScaler.getRoundedMaxValue(), 0);//initial value
    axisScaler.scaleToNewActualValue(-15.5);
    QCOMPARE(axisScaler.getRoundedMinValue(), -20);
    QCOMPARE(axisScaler.getRoundedMaxValue(), 0);
}

void test_axisautoscaler::resetScaling()
{
    AxisAutoScaler axisScaler;
    axisScaler.reset(25.5, 105.0);
    QCOMPARE(axisScaler.getRoundedMinValue(), 20);
    QCOMPARE(axisScaler.getRoundedMaxValue(), 110);
}
