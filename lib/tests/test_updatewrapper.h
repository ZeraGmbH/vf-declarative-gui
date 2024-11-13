#ifndef TEST_ROWAUTOSCALER_H
#define TEST_ROWAUTOSCALER_H

#include <QObject>

class test_updatewrapper : public QObject
{
    Q_OBJECT
private slots:
    void findUsb();
    void orderOfPackagesToBeInstalled();

};

#endif // TEST_ROWAUTOSCALER_H
