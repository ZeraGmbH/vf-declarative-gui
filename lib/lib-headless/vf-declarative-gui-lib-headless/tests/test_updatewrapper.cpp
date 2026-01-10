#include "test_updatewrapper.h"
#include "updatewrapper.h"
#include <QTest>

QTEST_MAIN(test_updatewrapper)

void test_updatewrapper::findUsb()
{
    UpdateWrapper wrapper;
    QCOMPARE(wrapper.searchForPackages(":/media"), ":/media/sda2");
}

void test_updatewrapper::orderOfPackagesToBeInstalled()
{
    UpdateWrapper wrapper;
    QStringList unorderdList = QStringList() << "com5003-mt310s2.zup" << "0500000001-licenses.zup" << "zera-updater.zup" << "wm1000i.zup";
    QStringList orderedList = wrapper.orderPackageList(unorderdList);
    QVERIFY(orderedList[0].contains("zera-updater.zup"));
    QVERIFY(orderedList.last().contains("com5003-mt310s2.zup"));
    QVERIFY(!orderedList.contains("wm1000i.zup"));

    unorderdList.clear();
    orderedList.clear();
    unorderdList = QStringList() << "com5003-mt310s2.zup" << "zera-updater.zup";
    orderedList = wrapper.orderPackageList(unorderdList);
    QCOMPARE(orderedList.length(), 2);
    QCOMPARE(orderedList[0],"zera-updater.zup");
    QCOMPARE(orderedList[1],"com5003-mt310s2.zup");

    unorderdList.clear();
    orderedList.clear();
    unorderdList = QStringList() << "foo.zup" << "bar.zup";
    orderedList = wrapper.orderPackageList(unorderdList);
    QCOMPARE(orderedList.length(), 2);
    QCOMPARE(orderedList[0],"foo.zup");
    QCOMPARE(orderedList[1],"bar.zup");
}
