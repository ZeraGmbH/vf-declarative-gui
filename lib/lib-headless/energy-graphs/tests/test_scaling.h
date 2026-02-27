#ifndef TEST_SCALING_H
#define TEST_SCALING_H

#include <QObject>

class test_scaling : public QObject
{
    Q_OBJECT
private slots:
    void scalePositiveValues();
    void scaleNegativeValues();
    void scalePositiveNegativeValues();

};

#endif // TEST_SCALING_H
