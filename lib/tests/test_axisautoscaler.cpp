#include "test_axisautoscaler.h"
#include "axisautoscaler.h"
#include <QTest>

QTEST_MAIN(test_axisautoscaler)

void test_axisautoscaler::scaleMax()
{
    AxisAutoScaler axisScaler;
    QCOMPARE(axisScaler.getRoundedMinValueWithMargin(), 0);//initial value
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 0);//initial value
    axisScaler.scaleToNewActualValue(27.5);
    QCOMPARE(axisScaler.getRoundedMinValueWithMargin(), -10);
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 40);
}

void test_axisautoscaler::scaleMin()
{
    AxisAutoScaler axisScaler;
    QCOMPARE(axisScaler.getRoundedMinValueWithMargin(), 0);//initial value
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 0);//initial value
    axisScaler.scaleToNewActualValue(-15.5);
    QCOMPARE(axisScaler.getRoundedMinValueWithMargin(), -30);
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 10);
}

void test_axisautoscaler::resetScaling()
{
    AxisAutoScaler axisScaler;
    axisScaler.reset(25.5, 105.0);
    QCOMPARE(axisScaler.getRoundedMinValueWithMargin(), 0);
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 130);
}
