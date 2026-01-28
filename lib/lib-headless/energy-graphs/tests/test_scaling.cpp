#include "test_scaling.h"
#include "axisscaler.h"
#include <QTest>

QTEST_MAIN(test_scaling)

void test_scaling::scalePositiveValues()
{
    AxisScaler scaler;
    scaler.scaleAxis(0.807);
    QCOMPARE(scaler.getMinValue(), 0);
    QCOMPARE(scaler.getMaxValue(), 1);

    scaler.scaleAxis(3.51);
    QCOMPARE(scaler.getMinValue(), 0);
    QCOMPARE(scaler.getMaxValue(), 10);

    scaler.scaleAxis(12.56);
    QCOMPARE(scaler.getMinValue(), 0);
    QCOMPARE(scaler.getMaxValue(), 20);

    scaler.scaleAxis(586);
    QCOMPARE(scaler.getMinValue(), 0);
    QCOMPARE(scaler.getMaxValue(), 600);
}

void test_scaling::scaleNegativeValues()
{
    AxisScaler scaler;
    scaler.scaleAxis(-0.2);
    QCOMPARE(scaler.getMinValue(), -1);
    QCOMPARE(scaler.getMaxValue(), 0);

    scaler.scaleAxis(-5.24);
    QCOMPARE(scaler.getMinValue(), -10);
    QCOMPARE(scaler.getMaxValue(), 0);

    scaler.scaleAxis(-11.55);
    QCOMPARE(scaler.getMinValue(), -20);
    QCOMPARE(scaler.getMaxValue(), 0);

    scaler.scaleAxis(-452);
    QCOMPARE(scaler.getMinValue(), -500);
    QCOMPARE(scaler.getMaxValue(), 0);
}

void test_scaling::scalePositiveNegativeValues()
{
    AxisScaler scaler;
    scaler.scaleAxis(0.1);
    QCOMPARE(scaler.getMinValue(), 0);
    QCOMPARE(scaler.getMaxValue(), 1);

    scaler.scaleAxis(-5);
    QCOMPARE(scaler.getMinValue(), -10);
    QCOMPARE(scaler.getMaxValue(), 1);

    scaler.scaleAxis(12);
    QCOMPARE(scaler.getMinValue(), -10);
    QCOMPARE(scaler.getMaxValue(), 20);

    scaler.scaleAxis(158);
    QCOMPARE(scaler.getMinValue(), -10);
    QCOMPARE(scaler.getMaxValue(), 200);

    scaler.scaleAxis(3);
    QCOMPARE(scaler.getMinValue(), -10);
    QCOMPARE(scaler.getMaxValue(), 200);

    scaler.scaleAxis(-4);
    QCOMPARE(scaler.getMinValue(), -10);
    QCOMPARE(scaler.getMaxValue(), 200);

    scaler.reset();
    QCOMPARE(scaler.getMinValue(), 0);
    QCOMPARE(scaler.getMaxValue(), 0);
}
