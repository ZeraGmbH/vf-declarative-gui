#include "chartsvgcreator.h"
#include <QtSvg/QSvgGenerator>
#include <QtWidgets/QVBoxLayout>

ChartSvgCreator::ChartSvgCreator(QWidget *parent)
    : QWidget{parent}
{
    auto *central = new QWidget(this);
    auto *layout  = new QVBoxLayout(central);

    // Build chart and series
    createLineSeries();

    AxisSetter *axisYLeft = createAxis("U[V]");
    AxisSetter *axisYRight = createAxis("I[A]");
    AxisSetter *axisX = createAxis("t[s]");
    axisX->setMin(0);
    axisX->setMax(10);

    connect(axisYLeft, &AxisSetter::prefixChanged, this, [=](QString unitPrefix){
        axisYLeft->getAxis()->setTitleText("U[" + unitPrefix +"V]");
    });
    connect(axisYRight, &AxisSetter::prefixChanged, this, [=](QString unitPrefix){
        axisYRight->getAxis()->setTitleText("I[" + unitPrefix +"A]");
    });

    connect(m_leftSeries, &QLineSeries::pointAdded, &m_leftScaler, [=](int index) {
        scaleLineSeriesAndAxis(m_leftSeries, axisYLeft, &m_leftScaler, index);
    });

    connect(m_rightSeries, &QLineSeries::pointAdded, &m_rightScaler, [=](int index) {
        scaleLineSeriesAndAxis(m_rightSeries, axisYRight, &m_rightScaler, index);
    });

    m_chart = new QChart;
    m_chart->setTitle(QStringLiteral("Dual Y axis chart"));
    m_chart->addSeries(m_leftSeries);
    m_chart->addSeries(m_rightSeries);

    m_chart->addAxis(axisX->getAxis(), Qt::AlignBottom);
    m_chart->addAxis(axisYLeft->getAxis(), Qt::AlignLeft);
    m_chart->addAxis(axisYRight->getAxis(), Qt::AlignRight);

    // Attach series to axes
    m_leftSeries->attachAxis(axisX->getAxis());
    m_leftSeries->attachAxis(axisYLeft->getAxis());

    m_rightSeries->attachAxis(axisX->getAxis());
    m_rightSeries->attachAxis(axisYRight->getAxis());

    // (Optional) color axes to match series for clarity
    QPen penLeft(Qt::blue);
    m_leftSeries->setPen(penLeft);
    axisYLeft->getAxis()->setLinePenColor(penLeft.color());
    axisYLeft->getAxis()->setLabelsColor(penLeft.color());

    QPen penRight(Qt::red);
    m_rightSeries->setPen(penRight);
    axisYRight->getAxis()->setLinePenColor(penRight.color());
    axisYRight->getAxis()->setLabelsColor(penRight.color());

    m_chartView = new QChartView(m_chart);

    layout->addWidget(m_chartView);

    resize(600, 400);
}

void ChartSvgCreator::appendLeftPoint(qreal x, qreal y)
{
    m_leftSeries->append(x, y);
}

void ChartSvgCreator::appendRightPoint(qreal x, qreal y)
{
    m_rightSeries->append(x, y);
}

QLineSeries *ChartSvgCreator::getLeftSeries() const
{
    return m_leftSeries;
}

QLineSeries *ChartSvgCreator::getRightSeries() const
{
    return m_rightSeries;
}

void ChartSvgCreator::saveSvg(QString svgPath)
{
    if (svgPath.isEmpty())
        return;

    const QSize svgSize(1200, 800); // SVG logical size

    QSvgGenerator generator;
    generator.setFileName(svgPath);
    generator.setSize(svgSize);
    generator.setViewBox(QRect(QPoint(0, 0), svgSize));
    generator.setTitle(QStringLiteral("Chart SVG"));
    generator.setDescription(QStringLiteral("QChart rendered to SVG"));

    QPainter painter(&generator);
    painter.setRenderHint(QPainter::Antialiasing);

    m_chartView->resize(svgSize);

    m_chartView->render(&painter);
}

void ChartSvgCreator::scaleLineSeriesAndAxis(QLineSeries *lineSeries, AxisSetter *axisY, AxisScaler *scaler, int index)
{
    double value = lineSeries->at(index).y();
    scaler->scaleValue(value);
    axisY->scaleAxis(value);
    double scale = axisY->getScale();
    double max = scaler->getMaxValue();
    axisY->setMax(max * scale);
    double min = scaler->getMinValue();
    axisY->setMin(min * scale);
    scaleLineSeries(lineSeries, scale, index);
}

void ChartSvgCreator::createLineSeries()
{
    m_leftSeries = new QLineSeries(this);
    m_leftSeries->setName("Left axis data");
    m_rightSeries = new QLineSeries(this);
    m_rightSeries->setName("Right axis data");
}

AxisSetter *ChartSvgCreator::createAxis(QString titleText)
{
    AxisSetter *axis = new AxisSetter();
    axis->setAxis(new QValueAxis());
    axis->getAxis()->setTitleText(titleText);
    axis->getAxis()->setLabelFormat("%.1f");
    return axis;
}

void ChartSvgCreator::scaleLineSeries(QLineSeries *series, double scale, int index)
{
    if(series) {
        QPointF point = series->points().at(index);
        point.setY(point.y() * scale);
        series->replace(index, point);
    }
}
