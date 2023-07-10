#ifndef TEST_ROWAUTOSCALER_H
#define TEST_ROWAUTOSCALER_H

#include <QObject>

class test_rowautoscaler : public QObject
{
    Q_OBJECT
private slots:
    void scale0();
    void scale1();
    void scale1001();
    void scale0Point1();
    void scale0Point001();
    void scale0Point00099();
    void scale1e6();
    void scaleHysteresisAt1000();
    //void scaleHysteresis1000to0Point1();
    void scaleHysteresisHigLow();

};

#endif // TEST_ROWAUTOSCALER_H
