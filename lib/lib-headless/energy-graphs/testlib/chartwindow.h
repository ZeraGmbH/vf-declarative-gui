#ifndef CHARTWINDOW_H
#define CHARTWINDOW_H

#include <QMainWindow>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QPushButton>
#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QValueAxis>
#include <QtSvg/QSvgGenerator>
#include <QFileDialog>
#include <QPainter>
#include "axisscaler.h"
#include "axissetter.h"

using namespace QtCharts;

class ChartWindow : public QMainWindow
{
    Q_OBJECT
public:
    ChartWindow(QWidget *parent = nullptr);
    void appendLeftPoint(qreal x, qreal y);
    void appendRightPoint(qreal x, qreal y);

    QLineSeries *getLeftSeries() const;
    QLineSeries *getRightSeries() const;
    void saveSvg(QString svgPath);

private slots:
    void scaleLineSeriesAxis(QtCharts::QLineSeries *lineSeries, AxisSetter *axisY, AxisScaler *scaler, int index);

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

#endif // CHARTWINDOW_H
