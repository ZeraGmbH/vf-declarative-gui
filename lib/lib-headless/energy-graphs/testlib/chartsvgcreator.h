#ifndef CHARTSVGCREATOR_H
#define CHARTSVGCREATOR_H

#include "axisscaler.h"
#include "axissetter.h"
#include <QWidget>
#include <QtCharts/QLineSeries>
#include <QtCharts/QChartView>

class ChartSvgCreator : public QWidget
{
    Q_OBJECT
public:
    explicit ChartSvgCreator(QWidget *parent = nullptr);

    void appendLeftPoint(qreal x, qreal y);
    void appendRightPoint(qreal x, qreal y);

    QLineSeries *getLeftSeries() const;
    QLineSeries *getRightSeries() const;
    void saveSvg(QString svgPath);

private slots:
    void scaleLineSeriesAndAxis(QtCharts::QLineSeries *lineSeries, AxisSetter *axisY, AxisScaler *scaler, int index);

private:
    void createLineSeries();
    AxisSetter* createAxis(QString titleText);
    void scaleLineSeries(QtCharts::QLineSeries *series, double scale, int index);

    QChart *m_chart = nullptr;
    QChartView *m_chartView = nullptr;

    QLineSeries *m_leftSeries = nullptr;
    QLineSeries *m_rightSeries = nullptr;
    QValueAxis *m_axisX;
    AxisScaler m_rightScaler;
    AxisScaler m_leftScaler;
};

#endif // CHARTSVGCREATOR_H
