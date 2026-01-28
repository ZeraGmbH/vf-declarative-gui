#include "test_draw_charts.h"
#include "chartsvgcreator.h"
#include <svgfuzzycompare.h>
#include <testloghelpers.h>
#include <QTest>

QTEST_MAIN(test_draw_charts)

void test_draw_charts::emptyChart()
{
    const QString fileBase = QString(QTest::currentTestFunction()) + ".svg";
    QString dumpFile = QString(TEST_SVG_FILE_PATH) + fileBase;

    ChartSvgCreator window;
    QCOMPARE(window.getLeftSeries()->count(), 0);
    QCOMPARE(window.getRightSeries()->count(), 0);

    window.show();
    window.saveSvg(dumpFile);

    QString dumped = TestLogHelpers::loadFile(dumpFile);
    QString expected = TestLogHelpers::loadFile(":/chartSvgs/" + fileBase);
    SvgFuzzyCompare compare;
    bool ok = compare.compareXml(dumped, expected);
    if(!ok)
        TestLogHelpers::compareAndLogOnDiff(expected, dumped);
    QVERIFY(ok);
}

void test_draw_charts::chartFilled()
{
    const QString fileBase = QString(QTest::currentTestFunction()) + ".svg";
    QString dumpFile = QString(TEST_SVG_FILE_PATH) + fileBase;

    ChartSvgCreator window;
    QCOMPARE(window.getLeftSeries()->count(), 0);
    QCOMPARE(window.getRightSeries()->count(), 0);
    window.appendLeftPoint(0, 2);
    window.appendLeftPoint(5, 7.3);
    window.appendLeftPoint(10, 3);

    window.appendRightPoint(0, 1);
    window.appendRightPoint(6, 8);
    window.appendRightPoint(10, 7);

    window.show();
    window.saveSvg(dumpFile);

    QString dumped = TestLogHelpers::loadFile(dumpFile);
    QString expected = TestLogHelpers::loadFile(":/chartSvgs/" + fileBase);
    SvgFuzzyCompare compare;
    bool ok = compare.compareXml(dumped, expected);
    if(!ok)
        TestLogHelpers::compareAndLogOnDiff(expected, dumped);
    QVERIFY(ok);
}

void test_draw_charts::scaleAxes()
{
    const QString fileBase = QString(QTest::currentTestFunction()) + ".svg";
    QString dumpFile = QString(TEST_SVG_FILE_PATH) + fileBase;

    ChartSvgCreator window;
    window.appendLeftPoint(0, 2000);
    window.appendLeftPoint(5, 1500);
    window.appendLeftPoint(10, 3000);

    window.appendRightPoint(0, 0.3);
    window.appendRightPoint(1, 0.5);
    window.appendRightPoint(10, 0.9);

    window.show();
    window.saveSvg(dumpFile);

    QString dumped = TestLogHelpers::loadFile(dumpFile);
    QString expected = TestLogHelpers::loadFile(":/chartSvgs/" + fileBase);
    SvgFuzzyCompare compare;
    bool ok = compare.compareXml(dumped, expected);
    if(!ok)
        TestLogHelpers::compareAndLogOnDiff(expected, dumped);
    QVERIFY(ok);

}

