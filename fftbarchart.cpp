#include "fftbarchart.h"

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

#include "bardata.h"
#include "barscaledraw.h"

FftBarChart::FftBarChart(QQuickItem *t_parent):
  QQuickPaintedItem(t_parent),
  m_refreshTimer(new QTimer(this)),
  m_valuesTimer(new QTimer(this)),
  m_canvas(new QwtPlotCanvas()),
  m_plot(new QwtPlot()),
  m_barDataLeft(new BarData()),
  m_minValueLeftAxis(1.0),
  m_leftBarCount(0),
  m_barDataRight(new BarData()),
  m_minValueRightAxis(1.0)
{
  connect(this, SIGNAL(heightChanged()), this, SLOT(onHeightChanged()));
  connect(this, SIGNAL(widthChanged()), this, SLOT(onWidthChanged()));
  connect(this, SIGNAL(labelsChanged(QStringList)), this, SLOT(onLabelsChanged(QStringList)));

  connect(m_refreshTimer, SIGNAL(timeout()), this, SLOT(onRefreshTimeout()));
  connect(m_valuesTimer, SIGNAL(timeout()), this, SLOT(onExternValuesChangedTimeout()));

  m_plot->setAttribute(Qt::WA_NoSystemBackground);
  m_plot->setAutoFillBackground(true);

  m_canvas->setLineWidth(1);
  m_canvas->setFrameStyle(QFrame::NoFrame);

  m_plot->setAxisScaleDraw(QwtPlot::yLeft, new BarScaleDraw());
  m_plot->setAxisScaleDraw(QwtPlot::yRight, new BarScaleDraw());
  m_plot->setAxisScaleDraw(QwtPlot::xBottom, new BarScaleDraw());

  m_plot->setCanvas(m_canvas);

  m_barDataLeft->attach(m_plot);
  m_barDataLeft->setYAxis(QwtPlot::yLeft);

  m_barDataRight->attach(m_plot);
  m_barDataRight->setYAxis(QwtPlot::yRight);

  m_plot->setAutoReplot(true);
}

FftBarChart::~FftBarChart()
{
  delete m_canvas;
  delete m_plot;
}

bool FftBarChart::bottomLabels() const
{
  return m_bottomLabelsEnabled;
}

bool FftBarChart::legendEnabled() const
{
  return m_legendEnabled;
}

QColor FftBarChart::bgColor() const
{
  return m_bgColor;
}

QColor FftBarChart::borderColor() const
{
  return m_borderColor;
}

QColor FftBarChart::textColor() const
{
  return m_textColor;
}

QString FftBarChart::chartTitle() const
{
  return m_chartTitle;
}

void FftBarChart::componentComplete()
{
  onRefreshTimeout();
}

void FftBarChart::paint(QPainter *t_painter)
{
  //painter->setRenderHints(QPainter::Antialiasing, true);
  m_plot->render(t_painter);
}



bool FftBarChart::logScaleLeftAxis() const
{
  return m_logScaleLeftAxis;
}

double FftBarChart::maxValueLeftAxis() const
{
  return m_maxValueLeftAxis;
}

double FftBarChart::minValueLeftAxis() const
{
  return m_minValueLeftAxis;
}

QColor FftBarChart::colorLeftAxis() const
{
  return m_colorLeftAxis;
}

QString FftBarChart::titleLeftAxis() const
{
  return m_plot->axisTitle(QwtPlot::yLeft).text();
}

bool FftBarChart::logScaleRightAxis() const
{
  return m_logScaleRightAxis;
}

double FftBarChart::maxValueRightAxis() const
{
  return m_maxValueRightAxis;
}

double FftBarChart::minValueRightAxis() const
{
  return m_minValueRightAxis;
}

QColor FftBarChart::colorRightAxis() const
{
  return m_colorRightAxis;
}

bool FftBarChart::rightAxisEnabled() const
{
  return m_plot->axisEnabled(QwtPlot::yRight);
}

QString FftBarChart::titleRightAxis() const
{
  return m_plot->axisTitle(QwtPlot::yLeft).text();
}

void FftBarChart::onExternValuesChanged()
{
  if(!m_valuesTimer->isActive())
    m_valuesTimer->start(100);
}

void FftBarChart::onHeightChanged()
{
  if(contentsBoundingRect().height()>0)
  {
    m_plot->setFixedHeight(contentsBoundingRect().height());
  }
  else
  {
    m_plot->setFixedHeight(0);
  }
  refreshPlot();
}

void FftBarChart::onWidthChanged()
{
  if(contentsBoundingRect().width()>0)
  {
    m_plot->setFixedWidth(contentsBoundingRect().width());
  }
  else
  {
    m_plot->setFixedWidth(0);
  }
  refreshPlot();
}

void FftBarChart::setBgColor(QColor t_backgroundColor)
{
  if (m_bgColor != t_backgroundColor) {
    QPalette p = m_plot->palette();
    p.setColor(QPalette::Window, t_backgroundColor);
    m_canvas->setPalette(p);
    m_bgColor = t_backgroundColor;
    emit bgColorChanged(t_backgroundColor);
  }
}

void FftBarChart::setborderColor(QColor t_borderColor)
{
  if (m_borderColor != t_borderColor) {
    m_borderColor = t_borderColor;

    /// @todo Broken TBD
    emit borderColorChanged(t_borderColor);
  }
}

void FftBarChart::useBottomLabels(bool t_labelsEnabled)
{
  m_bottomLabelsEnabled=t_labelsEnabled;
  if(t_labelsEnabled)
  {
    m_plot->setAxisScaleDraw(QwtPlot::xBottom, new BarScaleDraw(Qt::Vertical, m_bottomLabels));
    m_plot->setAxisMaxMajor(QwtPlot::xBottom, m_bottomLabels.count());
    refreshPlot();
  }
  else
  {
    m_bottomLabels.clear();
    m_plot->setAxisScaleDraw(QwtPlot::xBottom, new BarScaleDraw());
    refreshPlot();
  }
}

void FftBarChart::setChartTitle(QString t_chartTitle)
{
  if (m_chartTitle != t_chartTitle) {
    m_chartTitle = t_chartTitle;
    m_plot->setTitle(t_chartTitle);
  }
}

void FftBarChart::setLegendEnabled(bool t_legendEnabled)
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
      m_plot->insertLegend(tmpLegend);
    }
    else
    {
      m_plot->insertLegend(NULL);
    }
    refreshPlot();
  }
  m_legendEnabled=t_legendEnabled;
}

void FftBarChart::setTextColor(QColor t_textColor)
{

  if(t_textColor != m_textColor)
  {
    BarScaleDraw *tmpScaleX;
    QPalette tmpPa;
    tmpPa.setColor(QPalette::Text, t_textColor);
    tmpPa.setColor(QPalette::WindowText, t_textColor);
    tmpPa.setColor(QPalette::Window, Qt::transparent);
    tmpPa.setColor(QPalette::Base, Qt::transparent);

    m_plot->setPalette(tmpPa);

    if(m_plot->legend())
    {
      m_plot->legend()->setPalette(tmpPa);
    }

    //plot->axisWidget(QwtPlot::yLeft)->setPalette(tmpPa);
    m_plot->axisWidget(QwtPlot::xBottom)->setPalette(tmpPa);

    tmpScaleX=new BarScaleDraw();
    tmpScaleX->setColor(t_textColor);

    //tmpScaleY=new BarScaleDraw();
    //tmpScaleY->setColor(arg);

    ///todo check if this is necessary since the palette was set previously
    m_plot->setAxisScaleDraw(QwtPlot::xBottom, tmpScaleX);

    labelsChanged(m_bottomLabels);

    refreshPlot();
  }

  m_textColor = t_textColor;
}

void FftBarChart::setLogScaleLeftAxis(bool t_useLogScale)
{
  if(t_useLogScale!=m_logScaleLeftAxis)
  {
    m_logScaleLeftAxis = t_useLogScale;
    if(t_useLogScale)
    {
      m_plot->setAxisScaleEngine(QwtPlot::yLeft, new QwtLogScaleEngine);
    }
    else
    {
      m_plot->setAxisScaleEngine(QwtPlot::yLeft, new QwtLinearScaleEngine);
    }
    m_plot->setAxisScale(QwtPlot::yLeft, m_minValueLeftAxis, m_maxValueLeftAxis);
    m_barDataLeft->setBaseline(m_minValueLeftAxis/10);
    //calculate optimised scale min/max
    setMaxValueLeftAxis(m_maxValueLeftAxis);
    setMinValueLeftAxis(m_minValueLeftAxis);
    refreshPlot();
  }
}

void FftBarChart::setMaxValueLeftAxis(double t_maxValue)
{
  double tmpScale=1;
  if(m_logScaleLeftAxis)
  {
    while(tmpScale<t_maxValue)
    {
      tmpScale=tmpScale*10;
    }
  }
  else
  {
    tmpScale=t_maxValue;
  }
  m_plot->setAxisScale(QwtPlot::yLeft, m_minValueLeftAxis, tmpScale);
  m_maxValueLeftAxis = t_maxValue;
  refreshPlot();
}

void FftBarChart::setMinValueLeftAxis(double t_minValue)
{
  double tmpScale=1;
  if(m_logScaleLeftAxis)
  {
    while(tmpScale>t_minValue)
    {
      tmpScale=tmpScale/10;
    }
  }
  else
  {
    tmpScale=t_minValue;
  }
  m_plot->setAxisScale(QwtPlot::yLeft, tmpScale, m_maxValueLeftAxis);
  m_minValueLeftAxis = t_minValue;
  refreshPlot();
}

void FftBarChart::setColorLeftAxis(QColor t_color)
{
  QPalette tmpPa;
  tmpPa.setColor(QPalette::Text, t_color);
  tmpPa.setColor(QPalette::WindowText, t_color);
  tmpPa.setColor(QPalette::Window, Qt::transparent);
  tmpPa.setColor(QPalette::Base, Qt::transparent);

  m_plot->axisWidget(QwtPlot::yLeft)->setPalette(tmpPa);
  m_colorLeftAxis = t_color;
  //refresh bars
  onLeftBarCountChanged(m_leftBarCount);
}

void FftBarChart::setTitleLeftAxis(QString t_title)
{
  m_plot->setAxisTitle(QwtPlot::yLeft, t_title);
}

void FftBarChart::setLogScaleRightAxis(bool t_useLogScale)
{
  if(t_useLogScale!=m_logScaleRightAxis)
  {
    m_logScaleRightAxis = t_useLogScale;
    if(t_useLogScale)
    {
      m_plot->setAxisScaleEngine(QwtPlot::yRight, new QwtLogScaleEngine);
    }
    else
    {
      m_plot->setAxisScaleEngine(QwtPlot::yRight, new QwtLinearScaleEngine);
    }
    m_plot->setAxisScale(QwtPlot::yRight, m_minValueRightAxis, m_maxValueRightAxis);
    m_barDataRight->setBaseline(m_minValueRightAxis/10);
    //calculate optimised scale min/max
    setMaxValueRightAxis(m_maxValueRightAxis);
    setMinValueRightAxis(m_minValueRightAxis);
    refreshPlot();
  }
}

void FftBarChart::setMaxValueRightAxis(double t_maxValue)
{
  double tmpScale=1;
  if(m_logScaleRightAxis)
  {
    while(tmpScale<t_maxValue)
    {
      tmpScale=tmpScale*10;
    }
  }
  else
  {
    tmpScale=t_maxValue;
  }
  m_plot->setAxisScale(QwtPlot::yRight, m_minValueRightAxis, tmpScale);
  m_maxValueRightAxis = t_maxValue;
  refreshPlot();
}

void FftBarChart::setMinValueRightAxis(double t_minValue)
{
  double tmpScale=1;
  if(m_logScaleRightAxis)
  {
    while(tmpScale>t_minValue)
    {
      tmpScale=tmpScale/10;
    }
  }
  else
  {
    tmpScale=t_minValue;
  }
  m_plot->setAxisScale(QwtPlot::yRight, tmpScale, m_maxValueRightAxis);
  m_minValueRightAxis = t_minValue;
  refreshPlot();
}

void FftBarChart::setColorRightAxis(QColor t_color)
{
  QPalette tmpPa;
  tmpPa.setColor(QPalette::Text, t_color);
  tmpPa.setColor(QPalette::WindowText, t_color);
  tmpPa.setColor(QPalette::Window, Qt::transparent);
  tmpPa.setColor(QPalette::Base, Qt::transparent);

  m_plot->axisWidget(QwtPlot::yRight)->setPalette(tmpPa);
  m_colorRightAxis = t_color;
  //refresh bars
  onLeftBarCountChanged(m_leftBarCount);
}



void FftBarChart::setTitleRightAxis(QString t_title)
{
  m_plot->setAxisTitle(QwtPlot::yRight, t_title);
}

void FftBarChart::setRightAxisEnabled(bool t_rightAxisEnabled)
{
  m_plot->enableAxis(QwtPlot::yRight, t_rightAxisEnabled);
}

void FftBarChart::onExternValuesChangedTimeout()
{
  QVector<double> tmpSamples;
  int tmpLeftBarCount=0;
  const float tmpScaleFactor = m_maxValueLeftAxis/m_maxValueRightAxis;

  m_valuesTimer->stop();

  if(m_valuesLeftAxis.count()>0 && m_valuesLeftAxis.count() == m_valuesRightAxis.count())
  {
    //m_valuesLeftAxis is a list of mixed real and imaginary numbers
    //and m_valuesRightAxis needs to be mudballed into the samples
    tmpLeftBarCount = m_valuesLeftAxis.count();

    if(m_leftBarCount != tmpLeftBarCount)
    {
      m_leftBarCount = tmpLeftBarCount;
      onLeftBarCountChanged(m_leftBarCount);
    }


    for(int i=0; i<tmpLeftBarCount-1; i+=2)
    {
      QVector2D tmpVectorA, tmpVectorB;


      tmpVectorA.setX(m_valuesLeftAxis.at(i));
      tmpVectorA.setY(m_valuesLeftAxis.at(i+1));

      tmpSamples.append(tmpVectorA.length());

      tmpVectorB.setX(m_valuesRightAxis.at(i));
      tmpVectorB.setY(m_valuesRightAxis.at(i+1));

      //this is bullshit, but due to management decisions it is required
      tmpSamples.append(tmpVectorB.length()*tmpScaleFactor);
    }
    if(m_legendEnabled)
      m_plot->insertLegend(new QwtLegend());
    labelsChanged(m_barDataLeft->getTitles());
  }

  m_barDataLeft->setSamples(tmpSamples);
}

void FftBarChart::onLabelsChanged(QStringList t_labels)
{
  m_bottomLabels=t_labels;
  useBottomLabels(m_bottomLabelsEnabled);
  refreshPlot();
}

void FftBarChart::onRefreshTimeout()
{
  m_refreshTimer->stop();
  //qDebug("UPDATE");
  m_plot->updateGeometry();
  m_plot->updateAxes();
  m_plot->updateLegend();
  m_plot->updateLayout();
  m_plot->updateCanvasMargins();
  this->update();
}

void FftBarChart::refreshPlot()
{
  //when resizing is in progress it may not be suitable to refresh for every pixel changed in width or height
  if(!m_refreshTimer->isActive())
    m_refreshTimer->start(500);
}

void FftBarChart::onLeftValueChanged(QVariant t_leftValue)
{
  m_valuesLeftAxis = t_leftValue.value<QList<qreal>>();
  onExternValuesChanged();
}

void FftBarChart::onRightValueChanged(QVariant t_rightValue)
{
  m_valuesRightAxis = t_rightValue.value<QList<double>>();
  onExternValuesChanged();
}

void FftBarChart::onLeftBarCountChanged(int t_barCount)
{
  QString tmpBarTitle;

  m_barDataLeft->clearData();

  for(int i=0; i<t_barCount-1;)
  {
    if(i%2 == 0)
    {
      tmpBarTitle=QString::number(qAbs(i/2));
    }
    else
    {
      tmpBarTitle=QString();
    }
    m_barDataLeft->addData(m_colorLeftAxis, tmpBarTitle);
    m_barDataLeft->addData(m_colorRightAxis, QString(""));
    i+=2;
  }
}
