#include "chartwindow.h"
#include "lineseriesfiller.h"
#include "axissetter.h"

ChartWindow::ChartWindow(QWidget *parent)
    : QMainWindow{parent}
{
    auto *central = new QWidget(this);
    auto *layout  = new QVBoxLayout(central);

    // Build chart and series
    createLineSeries();

    auto *axisYLeft = new QValueAxis;
    axisYLeft->setTitleText(QStringLiteral("Left Y"));
    axisYLeft->setLabelFormat("%.1f");
    axisYLeft->setTickCount(5);

    auto *axisYRight = new QValueAxis;
    axisYRight->setTitleText(QStringLiteral("Right Y"));
    axisYRight->setLabelFormat("%.1f");
    axisYRight->setTickCount(5);

    connect(m_leftSeries, &QLineSeries::pointAdded, &m_leftScaler, [=](int index) {
        double value = m_leftSeries->at(index).y();
        m_leftScaler.scaleAxis(value);
        axisYLeft->setMax(m_leftScaler.getMaxValue());
        axisYLeft->setMin(m_leftScaler.getMinValue());
    });

    connect(m_rightSeries, &QLineSeries::pointAdded, &m_rightScaler, [=](int index) {
        double value = m_rightSeries->at(index).y();
        m_rightScaler.scaleAxis(value);
        axisYRight->setMax(m_rightScaler.getMaxValue());
        axisYRight->setMin(m_rightScaler.getMinValue());
    });


    m_chart = new QChart;
    m_chart->setTitle(QStringLiteral("Dual Y axis chart"));
    m_chart->addSeries(m_leftSeries);
    m_chart->addSeries(m_rightSeries);

    // Shared X axis
    auto *axisX = new QValueAxis;
    axisX->setTitleText(QStringLiteral("X"));
    axisX->setTickCount(5);
    axisX->setLabelFormat("%.1f");
    m_chart->addAxis(axisX, Qt::AlignBottom);

    m_chart->addAxis(axisYLeft, Qt::AlignLeft);

    // Right Y axis
    m_chart->addAxis(axisYRight, Qt::AlignRight);

    // Attach series to axes
    m_leftSeries->attachAxis(axisX);
    m_leftSeries->attachAxis(axisYLeft);

    m_rightSeries->attachAxis(axisX);
    m_rightSeries->attachAxis(axisYRight);

    // (Optional) color axes to match series for clarity
    QPen penLeft(Qt::blue);
    m_leftSeries->setPen(penLeft);
    axisYLeft->setLinePenColor(penLeft.color());
    axisYLeft->setLabelsColor(penLeft.color());

    QPen penRight(Qt::red);
    m_rightSeries->setPen(penRight);
    axisYRight->setLinePenColor(penRight.color());
    axisYRight->setLabelsColor(penRight.color());

    m_chartView = new QChartView(m_chart);
    m_chartView->setRenderHint(QPainter::Antialiasing);

    layout->addWidget(m_chartView);

    setCentralWidget(central);
    resize(600, 400);
}

void ChartWindow::createLineSeries()
{
    m_leftSeries = new QLineSeries(this);
    m_leftSeries->setName("Left axis data");
    // LineSeriesFiller lineSeriesFiller;
    // lineSeriesFiller.setLineSeries(m_leftSeries);
    m_rightSeries = new QLineSeries(this);
    m_rightSeries->setName("Right axis data");
}

void ChartWindow::appendLeftPoint(qreal x, qreal y)
{
    m_leftSeries->append(x, y);
}

void ChartWindow::appendRightPoint(qreal x, qreal y)
{
    m_rightSeries->append(x, y);
}

QLineSeries *ChartWindow::getLeftSeries() const
{
    return m_leftSeries;
}

QLineSeries *ChartWindow::getRightSeries() const
{
    return m_rightSeries;
}

void ChartWindow::saveSvg(QString svgPath)
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

    // Render chart so it occupies the full SVG
    m_chartView->render(&painter);
}
