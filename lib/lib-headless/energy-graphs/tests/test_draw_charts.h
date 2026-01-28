#ifndef TEST_DRAW_CHARTS_H
#define TEST_DRAW_CHARTS_H

#include <QObject>

class test_draw_charts : public QObject
{
    Q_OBJECT
private slots:
    void emptyChart();
    void chartFilled();
    //test axisSetter/ append values 10 to 2000 then 100 check scaling and prefix
};

#endif // TEST_DRAW_CHARTS_H
