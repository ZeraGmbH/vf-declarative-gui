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
    QStringList orderedList = wrapper.getOrderedPackageList(wrapper.searchForPackages(":/media"));
    QVERIFY(orderedList[0].contains("/zera-updater.zup"));
    QVERIFY(orderedList.last().contains("/com5003-mt310s2.zup"));
}
