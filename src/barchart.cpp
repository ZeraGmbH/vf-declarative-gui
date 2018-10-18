#include "barchart.h"

#include <QTimer>

#include <qwt_plot_renderer.h>
#include <qwt_plot_canvas.h>
#include <qwt_plot_barchart.h>
#include <qwt_column_symbol.h>
#include <qwt_plot_layout.h>
#include <qwt_legend.h>
#include <qwt_scale_draw.h>
#include <qwt_scale_engine.h>
#include <qwt_plot.h>
#include <qwt_scale_widget.h>
#include <qwt_text.h>
#include <qwt_plot_marker.h>

#include "bardata.h"
#include "cbar.h"
#include "barscaledraw.h"
#include "sidescaledraw.h"

BarChart::BarChart(QQuickItem *parent):
  QQuickPaintedItem(parent),
  refreshTimer(new QTimer(this)),
  valuesTimer(new QTimer(this)),
  canvas(new QwtPlotCanvas()),
  plot(new QwtPlot()),
  m_barDataLeft(new BarData()),
  m_minValueLeftAxis(1.0),
  m_barDataRight(new BarData()),
  m_minValueRightAxis(1.0)
{
  connect(this, SIGNAL(heightChanged()), this, SLOT(onHeightChanged()));
  connect(this, SIGNAL(widthChanged()), this, SLOT(onWidthChanged()));
  connect(this, SIGNAL(bottomLabelsEnabledChanged(QStringList)), this, SLOT(onLabelsChanged(QStringList)));

  connect(refreshTimer, SIGNAL(timeout()), this, SLOT(onRefreshTimeout()));
  connect(valuesTimer, SIGNAL(timeout()), this, SLOT(onExternValuesChangedTimeout()));

  plot->setAttribute(Qt::WA_NoSystemBackground);
  plot->setAutoFillBackground(true);

  canvas->setLineWidth(1);
  canvas->setFrameStyle(QFrame::Box | QFrame::Plain);
  canvas->setBorderRadius(0);

  plot->setAxisScaleDraw(QwtPlot::yLeft, new SideScaleDraw()); //cleaned up by the plot
  plot->setAxisScaleDraw(QwtPlot::yRight, new SideScaleDraw()); //cleaned up by the plot
  plot->setAxisScaleDraw(QwtPlot::xBottom, new BarScaleDraw()); //cleaned up by the plot

  plot->setCanvas(canvas);

  m_barDataLeft->attach(plot);
  m_barDataLeft->setYAxis(QwtPlot::yLeft);
  m_barDataLeft->setMargin(0);
  m_barDataLeft->setLayoutPolicy(BarData::AutoAdjustSamples);

  m_barDataRight->attach(plot);
  m_barDataRight->setYAxis(QwtPlot::yRight);
  m_barDataRight->setMargin(0);
  m_barDataRight->setLayoutPolicy(BarData::AutoAdjustSamples);

  plot->setAutoReplot(true);

  //plot->setAxisScaleEngine(QwtPlot::yLeft, new QwtLogScaleEngine);
  //plot->setAxisScale(QwtPlot::yLeft, 1, 10000);

  // marker
  m_upperLimitMarker = new QwtPlotMarker();
  m_upperLimitMarker->setValue( 0.0, 0.0 );
  m_upperLimitMarker->setLineStyle( QwtPlotMarker::HLine );
  m_upperLimitMarker->setLabelAlignment( Qt::AlignRight | Qt::AlignBottom );
  m_upperLimitMarker->setLinePen( Qt::red, 0, Qt::DashLine );
  m_upperLimitMarker->setVisible(false);
  m_upperLimitMarker->attach(plot);

  m_lowerLimitMarker = new QwtPlotMarker();
  m_lowerLimitMarker->setValue( 0.0, 0.0 );
  m_lowerLimitMarker->setLineStyle( QwtPlotMarker::HLine );
  m_lowerLimitMarker->setLabelAlignment( Qt::AlignRight | Qt::AlignBottom );
  m_lowerLimitMarker->setLinePen( Qt::red, 0, Qt::DashLine );
  m_lowerLimitMarker->setVisible(false);
  m_lowerLimitMarker->attach(plot);

  m_centerMarker = new QwtPlotMarker();
  m_centerMarker->setValue( 0.0, 0.0 );
  m_centerMarker->setLineStyle( QwtPlotMarker::HLine );
  m_centerMarker->setLabelAlignment( Qt::AlignRight | Qt::AlignBottom );
  m_centerMarker->setLinePen( Qt::gray, 0, Qt::DashLine );
  m_centerMarker->setVisible(false);
  m_centerMarker->attach(plot);
}

BarChart::~BarChart()
{
}

bool BarChart::bottomLabelsEnabled() const
{
  return m_bottomLabelsEnabled;
}

bool BarChart::legendEnabled() const
{
  return m_legendEnabled;
}

bool BarChart::markersEnabled() const
{
  return m_markersEnabled;
}

QColor BarChart::bgColor() const
{
  return m_bgColor;
}

QColor BarChart::borderColor() const
{
  return m_borderColor;
}

QColor BarChart::textColor() const
{
  return m_textColor;
}

QString BarChart::chartTitle() const
{
  return m_chartTitle;
}

void BarChart::setMarkers(double t_lowerLimit, double t_upperLimit)
{
  m_lowerLimitMarker->setValue(0.0, t_lowerLimit);
  m_upperLimitMarker->setValue(0.0, t_upperLimit);
  m_centerMarker->setValue(0.0, (t_lowerLimit+t_upperLimit)/2);
}

void BarChart::componentComplete()
{
  onRefreshTimeout();
}

void BarChart::paint(QPainter *t_painter)
{
  //t_painter->setRenderHints(QPainter::Antialiasing, true);
  plot->render(t_painter);
}

bool BarChart::leftAxisLogScale() const
{
  return m_logScaleLeftAxis;
}

double BarChart::leftAxisMaxValue() const
{
  return m_maxValueLeftAxis;
}

double BarChart::leftAxisMinValue() const
{
  return m_minValueLeftAxis;
}

QList<QVariant> BarChart::leftAxisBars() const
{
  return QList<QVariant>(m_valuesLeftAxis);
}

QColor BarChart::leftAxisColor() const
{
  return m_colorLeftAxis;
}

QString BarChart::leftAxisTitle() const
{
  return plot->axisTitle(QwtPlot::yLeft).text();
}

QString BarChart::leftScaleTransform() const
{
  Q_ASSERT(plot->axisScaleDraw(QwtPlot::yLeft) != nullptr);
  return static_cast<SideScaleDraw*>(plot->axisScaleDraw(QwtPlot::yLeft))->getTextTransform();
}

double BarChart::leftBaseline() const
{
  return m_barDataLeft->baseline();
}

bool BarChart::rightAxisLogScale() const
{
  return m_logScaleRightAxis;
}

double BarChart::rightAxisMaxValue() const
{
  return m_maxValueRightAxis;
}

double BarChart::rightAxisMinValue() const
{
  return m_minValueRightAxis;
}

QList<QVariant> BarChart::rightAxisBars() const
{
  return m_valuesRightAxis;
}

QColor BarChart::rightAxisColor() const
{
  return m_colorRightAxis;
}

bool BarChart::rightAxisEnabled() const
{
  return plot->axisEnabled(QwtPlot::yRight);
}

QString BarChart::rightAxisTitle() const
{
  return plot->axisTitle(QwtPlot::yLeft).text();
}

QString BarChart::rightScaleTransform() const
{
  Q_ASSERT(plot->axisScaleDraw(QwtPlot::yRight) != nullptr);
  return static_cast<SideScaleDraw*>(plot->axisScaleDraw(QwtPlot::yRight))->getTextTransform();
}

double BarChart::rightBaseline() const
{
  return m_barDataRight->baseline();
}

void BarChart::onExternValuesChanged()
{
  if(!valuesTimer->isActive())
    valuesTimer->start(100);
}

void BarChart::onHeightChanged()
{
  if(contentsBoundingRect().height()>0)
  {
    plot->setFixedHeight(contentsBoundingRect().height());
  }
  else
  {
    plot->setFixedHeight(0);
  }
  refreshPlot();
}

void BarChart::onWidthChanged()
{
  if(contentsBoundingRect().width()>0)
  {
    plot->setFixedWidth(contentsBoundingRect().width());
  }
  else
  {
    plot->setFixedWidth(0);
  }
  refreshPlot();
}

void BarChart::setBgColor(QColor t_bgColor)
{
  if (m_bgColor != t_bgColor)
  {
    QPalette p = plot->palette();
    p.setColor(QPalette::Window, t_bgColor);
    canvas->setPalette(p);
    m_bgColor = t_bgColor;
    emit bgColorChanged(t_bgColor);
  }
}

void BarChart::setborderColor(QColor t_borderColor)
{
  if (m_borderColor != t_borderColor)
  {
    m_borderColor = t_borderColor;

    /// @todo Broken TBD
    emit borderColorChanged(t_borderColor);
  }
}

void BarChart::setBottomLabelsEnabled(bool t_bottomLabelsEnabled)
{
  m_bottomLabelsEnabled=t_bottomLabelsEnabled;
  if(t_bottomLabelsEnabled)
  {
    plot->setAxisScaleDraw(QwtPlot::xBottom, new BarScaleDraw(Qt::Vertical, m_bottomLabels));
    plot->setAxisMaxMajor(QwtPlot::xBottom, m_bottomLabels.count());
    refreshPlot();
  }
  else
  {
    m_bottomLabels.clear();
    plot->setAxisScaleDraw(QwtPlot::xBottom, new BarScaleDraw());
    refreshPlot();
  }
  plot->enableAxis(QwtPlot::xBottom, t_bottomLabelsEnabled);
}

void BarChart::setChartTitle(QString t_chartTitle)
{
  if (m_chartTitle != t_chartTitle)
  {
    m_chartTitle = t_chartTitle;
    plot->setTitle(t_chartTitle);
  }
}

void BarChart::setLegendEnabled(bool t_legendEnabled)
{
  if(t_legendEnabled!=m_legendEnabled)
  {
    if(t_legendEnabled)
    {
      QwtLegend *tmpLegend = new QwtLegend();
      QPalette tmpPa;
      tmpPa.setColor(QPalette::Text, t_legendEnabled);
      tmpPa.setColor(QPalette::WindowText, t_legendEnabled);
      tmpPa.setColor(QPalette::Window, Qt::transparent);
      tmpPa.setColor(QPalette::Base, Qt::transparent);

      tmpLegend->setPalette(tmpPa);
      plot->insertLegend(tmpLegend);
    }
    else
    {
      plot->insertLegend(NULL);
    }
    refreshPlot();
  }
  m_legendEnabled=t_legendEnabled;
}

void BarChart::setMarkersEnabled(bool t_markersEnabled)
{
  m_markersEnabled = t_markersEnabled;
  m_lowerLimitMarker->setVisible(t_markersEnabled);
  m_upperLimitMarker->setVisible(t_markersEnabled);
  m_centerMarker->setVisible(t_markersEnabled);
}

void BarChart::setTextColor(QColor t_textColor)
{

  if(t_textColor != m_textColor)
  {
    QPalette tmpPa;
    tmpPa.setColor(QPalette::Text, t_textColor);
    tmpPa.setColor(QPalette::WindowText, t_textColor);
    tmpPa.setColor(QPalette::Window, Qt::transparent);
    tmpPa.setColor(QPalette::Base, Qt::transparent);

    plot->setPalette(tmpPa);

    if(plot->legend())
    {
      plot->legend()->setPalette(tmpPa);
    }

    //plot->axisWidget(QwtPlot::yLeft)->setPalette(tmpPa);
    plot->axisWidget(QwtPlot::xBottom)->setPalette(tmpPa);

    //tmpScaleY=new BarScaleDraw();
    //tmpScaleY->setColor(arg);

    bottomLabelsEnabledChanged(m_bottomLabels);

    refreshPlot();
  }

  m_textColor = t_textColor;
}

void BarChart::setLeftAxisLogScaleEnabled(bool t_leftAxisLogScaleEnabled)
{
  if(t_leftAxisLogScaleEnabled!=m_logScaleLeftAxis)
  {
    m_logScaleLeftAxis = t_leftAxisLogScaleEnabled;
    if(t_leftAxisLogScaleEnabled)
    {
      plot->setAxisScaleEngine(QwtPlot::yLeft, new QwtLogScaleEngine);
    }
    else
    {
      plot->setAxisScaleEngine(QwtPlot::yLeft, new QwtLinearScaleEngine);
    }
    plot->setAxisScale(QwtPlot::yLeft, m_minValueLeftAxis, m_maxValueLeftAxis);
    //calculate optimised scale min/max
    setLeftAxisMaxValue(m_maxValueLeftAxis);
    setLeftAxisMinValue(m_minValueLeftAxis);
    refreshPlot();
  }
}

void BarChart::setLeftAxisMaxValue(double t_leftAxisMaxValue)
{
  Q_ASSERT(std::isnan(t_leftAxisMaxValue) == false);
  double tmpScale=1;
  if(m_logScaleLeftAxis)
  {
    Q_ASSERT(t_leftAxisMaxValue != std::numeric_limits<double>::infinity());
    while(tmpScale<t_leftAxisMaxValue)
    {
      tmpScale=tmpScale*10;
    }
  }
  else
  {
    tmpScale=t_leftAxisMaxValue;
  }
  plot->setAxisScale(QwtPlot::yLeft, m_minValueLeftAxis, tmpScale);
  m_maxValueLeftAxis = t_leftAxisMaxValue;
  refreshPlot();
}

void BarChart::setLeftAxisMinValue(double t_leftAxisMinValue)
{
  Q_ASSERT(std::isnan(t_leftAxisMinValue) == false);
  m_minValueLeftAxis = t_leftAxisMinValue;
  double tmpScale=1;
  if(m_logScaleLeftAxis)
  {
    while(t_leftAxisMinValue != 0 && tmpScale>t_leftAxisMinValue)
    {
      tmpScale=tmpScale/10;
    }
    m_barDataLeft->setBaseline(m_minValueLeftAxis/10);
  }
  else
  {
    tmpScale=t_leftAxisMinValue;
  }
  plot->setAxisScale(QwtPlot::yLeft, tmpScale, m_maxValueLeftAxis);

  refreshPlot();
}

void BarChart::setLeftAxisBars(QList<QVariant> t_leftAxisValues)
{
  QVector< double > samples;
  m_barDataLeft->clearData();
  if (m_valuesLeftAxis != t_leftAxisValues)
  {
    foreach (QVariant tmpVar, t_leftAxisValues)
    {
      cBar *myBar=qvariant_cast<cBar*>(tmpVar);
      if(myBar)
      {
        samples += myBar->value();
        m_barDataLeft->addData(myBar->color(), myBar->title());
        // value order may have changed,
        disconnect(myBar, SIGNAL(colorChanged(QColor)), this, SLOT(onExternValuesChanged()));
        disconnect(myBar, SIGNAL(valueChanged(double)), this, SLOT(onExternValuesChanged()));
        disconnect(myBar, SIGNAL(titleChanged(QString)), this, SLOT(onExternValuesChanged()));

        connect(myBar, SIGNAL(colorChanged(QColor)), this, SLOT(onExternValuesChanged()));
        connect(myBar, SIGNAL(valueChanged(double)), this, SLOT(onExternValuesChanged()));
        connect(myBar, SIGNAL(titleChanged(QString)), this, SLOT(onExternValuesChanged()));
      }
    }
  }
  else
  {
    foreach (QVariant tmpVar, t_leftAxisValues)
    {
      cBar *myBar=qvariant_cast<cBar*>(tmpVar);
      if(myBar)
      {
        samples += myBar->value();
        m_barDataLeft->addData(myBar->color(), myBar->title());
      }
    }
  }
  m_barDataLeft->setSamples(samples);
  if(m_legendEnabled)
    plot->insertLegend(new QwtLegend());

  m_valuesLeftAxis = t_leftAxisValues;
  bottomLabelsEnabledChanged(m_barDataLeft->getTitles());
  emit leftAxisBarsChanged(t_leftAxisValues);
}

void BarChart::setLeftAxisColor(QColor t_leftAxisColor)
{
  QPalette tmpPa;
  tmpPa.setColor(QPalette::Text, t_leftAxisColor);
  tmpPa.setColor(QPalette::WindowText, t_leftAxisColor);
  tmpPa.setColor(QPalette::Window, Qt::transparent);
  tmpPa.setColor(QPalette::Base, Qt::transparent);

  plot->axisWidget(QwtPlot::yLeft)->setPalette(tmpPa);
  m_colorLeftAxis = t_leftAxisColor;
}

void BarChart::setLeftAxisTitle(QString t_leftAxisTitle)
{
  plot->setAxisTitle(QwtPlot::yLeft, t_leftAxisTitle);
}

void BarChart::setLeftScaleTransform(const QString &t_leftAxisTransform)
{
  Q_ASSERT(plot->axisScaleDraw(QwtPlot::yLeft) != nullptr);
  static_cast<SideScaleDraw*>(plot->axisScaleDraw(QwtPlot::yLeft))->setTextTransform(t_leftAxisTransform);
}

void BarChart::setLeftBaseline(double t_leftBaseline)
{
  if(m_logScaleLeftAxis == false)
  {
    m_barDataLeft->setBaseline(t_leftBaseline);
  }
}

void BarChart::setRightAxisLogScaleEnabled(bool t_rightAxisLogScaleEnabled)
{
  if(t_rightAxisLogScaleEnabled!=m_logScaleRightAxis)
  {
    m_logScaleRightAxis = t_rightAxisLogScaleEnabled;
    if(t_rightAxisLogScaleEnabled)
    {
      plot->setAxisScaleEngine(QwtPlot::yRight, new QwtLogScaleEngine);
    }
    else
    {
      plot->setAxisScaleEngine(QwtPlot::yRight, new QwtLinearScaleEngine);
    }
    plot->setAxisScale(QwtPlot::yRight, m_minValueRightAxis, m_maxValueRightAxis);

    //calculate optimised scale min/max
    setRightAxisMaxValue(m_maxValueRightAxis);
    setRightAxisMinValue(m_minValueRightAxis);
    refreshPlot();
  }
}

void BarChart::setRightAxisMaxValue(double t_rightAxisMaxValue)
{
  Q_ASSERT(std::isnan(t_rightAxisMaxValue) == false);
  double tmpScale=1;
  if(m_logScaleRightAxis)
  {
    Q_ASSERT(t_rightAxisMaxValue != std::numeric_limits<double>::infinity());
    while(tmpScale<t_rightAxisMaxValue)
    {
      tmpScale=tmpScale*10;
    }
  }
  else
  {
    tmpScale=t_rightAxisMaxValue;
  }
  plot->setAxisScale(QwtPlot::yRight, m_minValueRightAxis, tmpScale);
  m_maxValueRightAxis = t_rightAxisMaxValue;
  refreshPlot();
}

void BarChart::setRightAxisMinValue(double t_rightAxisMinValue)
{
  Q_ASSERT(std::isnan(t_rightAxisMinValue) == false);
  double tmpScale=1;
  m_minValueRightAxis = t_rightAxisMinValue;
  if(m_logScaleRightAxis)
  {
    Q_ASSERT(t_rightAxisMinValue>0);
    while(tmpScale>t_rightAxisMinValue)
    {
      tmpScale=tmpScale/10;
    }
    m_barDataRight->setBaseline(m_minValueRightAxis/10);
  }
  else
  {
    tmpScale=t_rightAxisMinValue;
  }
  plot->setAxisScale(QwtPlot::yRight, tmpScale, m_maxValueRightAxis);
  refreshPlot();
}

void BarChart::setRightAxisBars(QList<QVariant> t_rightAxisValues)
{
  QVector< double > samples;
  m_barDataRight->clearData();
  if (m_valuesRightAxis != t_rightAxisValues)
  {
    foreach (QVariant tmpVar, t_rightAxisValues)
    {
      cBar *myBar=qvariant_cast<cBar*>(tmpVar);
      if(myBar)
      {
        samples += myBar->value();
        m_barDataRight->addData(myBar->color(), myBar->title());
        // value order may have changed,
        disconnect(myBar, SIGNAL(colorChanged(QColor)), this, SLOT(onExternValuesChanged()));
        disconnect(myBar, SIGNAL(valueChanged(double)), this, SLOT(onExternValuesChanged()));
        disconnect(myBar, SIGNAL(titleChanged(QString)), this, SLOT(onExternValuesChanged()));

        connect(myBar, SIGNAL(colorChanged(QColor)), this, SLOT(onExternValuesChanged()));
        connect(myBar, SIGNAL(valueChanged(double)), this, SLOT(onExternValuesChanged()));
        connect(myBar, SIGNAL(titleChanged(QString)), this, SLOT(onExternValuesChanged()));
      }
    }
  }
  else
  {
    foreach (QVariant tmpVar, t_rightAxisValues)
    {
      cBar *myBar=qvariant_cast<cBar*>(tmpVar);
      if(myBar)
      {
        samples += myBar->value();
        m_barDataRight->addData(myBar->color(), myBar->title());
      }
    }
  }

  m_barDataRight->setSamples(samples);
  if(m_legendEnabled)
    plot->insertLegend(new QwtLegend());

  m_valuesRightAxis = t_rightAxisValues;
  //labelsChanged(barDataRight->getTitles());
  emit rightAxisBarsChanged(t_rightAxisValues);
}

void BarChart::setRightAxisColor(QColor t_rightAxisColor)
{
  QPalette tmpPa;
  tmpPa.setColor(QPalette::Text, t_rightAxisColor);
  tmpPa.setColor(QPalette::WindowText, t_rightAxisColor);
  tmpPa.setColor(QPalette::Window, Qt::transparent);
  tmpPa.setColor(QPalette::Base, Qt::transparent);

  plot->axisWidget(QwtPlot::yRight)->setPalette(tmpPa);
  m_colorRightAxis = t_rightAxisColor;
}

void BarChart::setRightAxisEnabled(bool t_rightAxisEnabled)
{
  plot->enableAxis(QwtPlot::yRight, t_rightAxisEnabled);
}

void BarChart::setRightAxisTitle(QString t_rightAxisTitle)
{
  plot->setAxisTitle(QwtPlot::yRight, t_rightAxisTitle);
}

void BarChart::setRightScaleTransform(const QString &t_rightAxisTransform)
{
    Q_ASSERT(plot->axisScaleDraw(QwtPlot::yRight) != nullptr);
    static_cast<SideScaleDraw*>(plot->axisScaleDraw(QwtPlot::yRight))->setTextTransform(t_rightAxisTransform);
}

void BarChart::setRightBaseline(double t_rightBaseline)
{
  if(m_logScaleRightAxis == false)
  {
    m_barDataRight->setBaseline(t_rightBaseline);
  }
}

void BarChart::onExternValuesChangedTimeout()
{
  valuesTimer->stop();
  //this will reload the values, colors and titles of the cBar objects
  setLeftAxisBars(m_valuesLeftAxis);
  setRightAxisBars(m_valuesRightAxis);
}

void BarChart::onLabelsChanged(QStringList t_labelList)
{
  m_bottomLabels=t_labelList;
  setBottomLabelsEnabled(m_bottomLabelsEnabled);
  refreshPlot();
}

void BarChart::onRefreshTimeout()
{
  refreshTimer->stop();
  //qDebug("UPDATE");
  plot->updateGeometry();
  plot->updateAxes();
  plot->updateLegend();
  plot->updateLayout();
  plot->updateCanvasMargins();
  this->update();
}

void BarChart::refreshPlot()
{
  //when resizing is in progress it may not be suitable to refresh for every pixel changed in width or height
  if(!refreshTimer->isActive())
    refreshTimer->start(500);
}
