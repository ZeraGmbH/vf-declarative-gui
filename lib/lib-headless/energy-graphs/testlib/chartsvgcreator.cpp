#include "chartsvgcreator.h"
#include <QtSvg/QSvgGenerator>
#include <QtWidgets/QVBoxLayout>
#include <QGraphicsLayout>

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

    m_chart->setPlotArea(QRectF(50, 50, 1100, 700));


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
    // QTransform t;
    // t.translate(0, 1);
    // m_chartView->chart()->setTransform(t, false);

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
    // // Ensure no previous transformations are hanging around
    // painter.setWorldTransform(QTransform());
    // // QTransform t;
    // // t.translate(0, 1);
    // m_chartView->chart()->setGeometry(0, 0, svgSize.width(), svgSize.height());

    // // Render the chart directly instead of the View
    // m_chartView->chart()->paint(&painter, nullptr, nullptr);
    // //painter.setTransform(t, false);
    // m_chartView->resize(svgSize);

    // // t.setMatrix(1,0,0,1,0,1,1,1,1);
    // // QTransform currentMatrix = painter.worldTransform();


    QSvgGenerator generator;
    generator.setFileName(svgPath);
    generator.setSize(svgSize);
    generator.setResolution(96);
    generator.setViewBox(QRect(0, 0, svgSize.width(), svgSize.height()));
    generator.setTitle(QStringLiteral("Chart SVG"));
    generator.setDescription(QStringLiteral("QChart rendered to SVG"));

    m_chartView->chart()->setMargins(QMargins(0, 0, 0, 0));

    m_chartView->chart()->layout()->invalidate();
    m_chartView->chart()->layout()->activate();
    m_chartView->setBackgroundBrush(Qt::NoBrush);

    m_chartView->setContentsMargins(0, 0, 0, 0);
    m_chartView->chart()->setMargins(QMargins(0, 0, 0, 0));
    m_chartView->chart()->setTransform(QTransform(), false);


    m_chartView->setAlignment(Qt::AlignLeft | Qt::AlignTop);
    m_chartView->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_chartView->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    m_chartView->setFrameShape(QFrame::NoFrame);
    m_chartView->setSceneRect(0, 0, svgSize.width(), svgSize.height());
    m_chartView->chart()->setTitle(""); // Even a space " " can cause an offset
    m_chartView->chart()->legend()->hide();
    m_chartView->resize(svgSize);

    m_chartView->chart()->setMargins(QMargins(0, 0, 0, 0));
    if (m_chartView->chart()->layout()) {
        m_chartView->chart()->layout()->setContentsMargins(0, 0, 0, 0);
    }

    QPainter painter(&generator);
    painter.setFont(getLabelFont());
    painter.setRenderHint(QPainter::Antialiasing);

    QRectF rect(1, 0, svgSize.width(), svgSize.height());
    m_chartView->render(&painter, rect, rect.toRect());

    painter.end();

    // painter.setViewport(0, 0, svgSize.width(), svgSize.height());
    // painter.setWindow(0, 0, svgSize.width(), svgSize.height());

    // QRectF targetRect(0, 0, svgSize.width(), svgSize.height());
    // QRect sourceRect(0, 0, svgSize.width(), svgSize.height());

    // m_chartView->render(&painter, targetRect, sourceRect);

}

QFont ChartSvgCreator::getLabelFont()
{
    QFont defaultFont;
    defaultFont.setPointSizeF(12);
    defaultFont.setFamily("Sans");
    defaultFont.setFixedPitch(true);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    defaultFont.setWeight(QFont::Medium);
#else
    defaultFont.setWeight(QFont::Weight(570)); // Mimic Qt5
#endif
    defaultFont.setKerning(false);
    return defaultFont;
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

    QFont fixedFont("Sans");
    fixedFont.setPixelSize(12);
    fixedFont.setFixedPitch(true);
    axis->getAxis()->setLabelsFont(fixedFont);
    axis->getAxis()->setTitleText(titleText);
    axis->getAxis()->setTickCount(5);
    axis->getAxis()->setLabelFormat("%.1f");
    axis->getAxis()->setLabelsAngle(0);
    axis->getAxis()->setTitleVisible(false);
    // axis->getAxis()->setLabelsPadding(0);
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
