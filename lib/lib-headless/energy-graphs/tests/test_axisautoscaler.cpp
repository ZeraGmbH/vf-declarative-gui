#include "test_axisautoscaler.h"
#include "axisautoscaler.h"
#include <QTest>

QTEST_MAIN(test_axisautoscaler)

void test_axisautoscaler::scaleMax()
{
    AxisAutoScaler axisScaler;
    QCOMPARE(axisScaler.getPowerRoundedMinValueWithMargin(), 0);//initial value
    QCOMPARE(axisScaler.getUIRoundedMinValueWithMargin(), 0);//initial value
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 0);//initial value
    axisScaler.scaleToNewActualValue(27.5);
    QCOMPARE(axisScaler.getPowerRoundedMinValueWithMargin(), -3);
    QCOMPARE(axisScaler.getUIRoundedMinValueWithMargin(), 0);
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 33);
}

void test_axisautoscaler::scaleMin()
{
    AxisAutoScaler axisScaler;
    QCOMPARE(axisScaler.getPowerRoundedMinValueWithMargin(), 0);//initial value
    QCOMPARE(axisScaler.getUIRoundedMinValueWithMargin(), 0);//initial value
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 0);//initial value
    axisScaler.scaleToNewActualValue(-15.5);
    QCOMPARE(axisScaler.getPowerRoundedMinValueWithMargin(), -22);
    QCOMPARE(axisScaler.getUIRoundedMinValueWithMargin(), 0);
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 2);
}

void test_axisautoscaler::resetScaling()
{
    AxisAutoScaler axisScaler;
    axisScaler.reset(25.5, 105.0);
    QCOMPARE(axisScaler.getPowerRoundedMinValueWithMargin(), 9);
    QCOMPARE(axisScaler.getUIRoundedMinValueWithMargin(), 9);
    QCOMPARE(axisScaler.getRoundedMaxValueWithMargin(), 121);
}
