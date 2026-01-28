#ifndef TEST_DRAW_CHARTS_H
#define TEST_DRAW_CHARTS_H

#include <QObject>

class test_draw_charts : public QObject
{
    Q_OBJECT
private slots:
    void emptyChart();
    void chartFilled();
    void scaleAxes();
};

#endif // TEST_DRAW_CHARTS_H
