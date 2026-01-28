#include "test_draw_charts.h"
#include "chartwindow.h"
#include <svgfuzzycompare.h>
#include <testloghelpers.h>
#include <QTest>

QTEST_MAIN(test_draw_charts)

void test_draw_charts::emptyChart()
{
    const QString fileBase = QString(QTest::currentTestFunction()) + ".svg";
    QString dumpFile = "/home/a.kaouissi/data/git-projects/zera-metaproject/vf-declarative-gui/lib/lib-headless/energy-graphs/tests/test-data/" + fileBase;

    ChartWindow window;
    window.resize(1200, 800);
    QCOMPARE(window.getLeftSeries()->count(), 0);
    QCOMPARE(window.getRightSeries()->count(), 0);

    window.show();
    window.saveSvg(dumpFile);

    QString dumped = TestLogHelpers::loadFile(dumpFile);
    QString expected = TestLogHelpers::loadFile(":/" + fileBase);
    SvgFuzzyCompare compare;
    bool ok = compare.compareXml(dumped, expected);
    if(!ok)
        TestLogHelpers::compareAndLogOnDiff(expected, dumped);
    QVERIFY(ok);
}

void test_draw_charts::chartFilled()
{
    const QString fileBase = QString(QTest::currentTestFunction()) + ".svg";
    QString dumpFile = "/home/a.kaouissi/data/git-projects/zera-metaproject/vf-declarative-gui/lib/lib-headless/energy-graphs/tests/test-data/" + fileBase;

    ChartWindow window;
    window.resize(1200, 800);
    QCOMPARE(window.getLeftSeries()->count(), 0);
    QCOMPARE(window.getRightSeries()->count(), 0);
    window.appendLeftPoint(0.0, 2.0);
    window.appendLeftPoint(10.0, 3.0);

    window.appendRightPoint(0.0, 1.0);
    window.appendRightPoint(10.0, 7.0);

    window.show();
    window.saveSvg(dumpFile);

    QString dumped = TestLogHelpers::loadFile(dumpFile);
    QString expected = TestLogHelpers::loadFile(":/" + fileBase);
    SvgFuzzyCompare compare;
    bool ok = compare.compareXml(dumped, expected);
    if(!ok)
        TestLogHelpers::compareAndLogOnDiff(expected, dumped);
    QVERIFY(ok);
}

void test_draw_charts::scaleAxes()
{
    const QString fileBase = QString(QTest::currentTestFunction()) + ".svg";
    QString dumpFile = "/home/a.kaouissi/data/git-projects/zera-metaproject/vf-declarative-gui/lib/lib-headless/energy-graphs/tests/test-data/" + fileBase;

    ChartWindow window;
    window.resize(1200, 800);
    window.appendLeftPoint(0.0, 2000.0);
    window.appendLeftPoint(10.0, 3000.0);

    // window.appendRightPoint(0.0, 1.0);
    // window.appendRightPoint(10.0, 7.0);

    window.show();
    window.saveSvg(dumpFile);

    QString dumped = TestLogHelpers::loadFile(dumpFile);
    QString expected = TestLogHelpers::loadFile(":/" + fileBase);
    SvgFuzzyCompare compare;
    bool ok = compare.compareXml(dumped, expected);
    if(!ok)
        TestLogHelpers::compareAndLogOnDiff(expected, dumped);
    QVERIFY(ok);

}

