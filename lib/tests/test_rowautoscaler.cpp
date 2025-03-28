#include "test_rowautoscaler.h"
#include "rowautoscaler.h"
#include <QTest>

QTEST_MAIN(test_rowautoscaler)

void test_rowautoscaler::scale0()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(0.0);
    QCOMPARE(res.unitPrefix, "m");
    QCOMPARE(res.scaleFactor, 1e3);
}

void test_rowautoscaler::scale1()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(1.0);
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1.0);
}

void test_rowautoscaler::scale999()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(999);
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1.0);
}

void test_rowautoscaler::scale1001()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(1001);
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);
}

void test_rowautoscaler::scale1001Negative()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(-1001);
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);
}

void test_rowautoscaler::scale999999()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(999999);
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);
}

void test_rowautoscaler::scale1000001()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(1000001);
    QCOMPARE(res.unitPrefix, "M");
    QCOMPARE(res.scaleFactor, 1e-6);
}

void test_rowautoscaler::scale1e9plusOne()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(1e9+1);
    QCOMPARE(res.unitPrefix, "G");
    QCOMPARE(res.scaleFactor, 1e-9);
}

void test_rowautoscaler::scaleHysteresisAt1000()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res;

    res = scaler.scaleSingleVal(1);
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1);

    res = scaler.scaleSingleVal(1000 * (1-RowAutoScaler::HYSTERESIS));
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1);

    res = scaler.scaleSingleVal(1000);
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);

    res = scaler.scaleSingleVal(1000 * (1-RowAutoScaler::HYSTERESIS));
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);

    res = scaler.scaleSingleVal(1000 * (1-2*RowAutoScaler::HYSTERESIS));
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1);

    res = scaler.scaleSingleVal(1000 * (1-RowAutoScaler::HYSTERESIS));
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1);
}

/*void test_rowautoscaler::scaleHysteresis1000to0Point1()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res;

    res = scaler.scaleSingleVal(1000);
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);

    res = scaler.scaleSingleVal(0.1);
    QCOMPARE(res.unitPrefix, "m");
    QCOMPARE(res.scaleFactor, 1e3);
}*/

void test_rowautoscaler::scaleHysteresisHigLow()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res;

    res = scaler.scaleSingleVal(1000);
    QCOMPARE(res.unitPrefix, "k");
    QCOMPARE(res.scaleFactor, 1e-3);

    res = scaler.scaleSingleVal(0.1);
    QCOMPARE(res.unitPrefix, "");
    QCOMPARE(res.scaleFactor, 1);

    res = scaler.scaleSingleVal(0.1);
    QCOMPARE(res.unitPrefix, "m");
    QCOMPARE(res.scaleFactor, 1e3);
}

void test_rowautoscaler::scale0Point1()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(0.1);
    QCOMPARE(res.unitPrefix, "m");
    QCOMPARE(res.scaleFactor, 1e3);
}

void test_rowautoscaler::scale0Point001()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(0.001);
    QCOMPARE(res.unitPrefix, "m");
    QCOMPARE(res.scaleFactor, 1e3);
}

void test_rowautoscaler::scale0Point00099()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(0.00099);
    QCOMPARE(res.unitPrefix, "m");
    QCOMPARE(res.scaleFactor, 1e3);
}

void test_rowautoscaler::scale1e6()
{
    RowAutoScaler scaler;
    SingleValueScaler::TSingleScaleResult res = scaler.scaleSingleVal(1e6);
    QCOMPARE(res.unitPrefix, "M");
    QCOMPARE(res.scaleFactor, 1e-6);
}
