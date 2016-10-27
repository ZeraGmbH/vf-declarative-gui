#ifndef CBARCHART_H
#define CBARCHART_H

#include <QQuickPaintedItem>
#include <QList>
#include <QColor>
#include <QString>

class QwtPlot;
class BarData;
class QwtPlotCanvas;

QT_BEGIN_NAMESPACE
class QTimer;
QT_END_NAMESPACE

/**
 * @todo Replace with Qt Quick Charts once the perfomance is above mediocre
 */
class BarChart : public QQuickPaintedItem
{
  Q_OBJECT
  Q_DISABLE_COPY(BarChart)

  Q_PROPERTY(bool bottomLabelsEnabled READ bottomLabelsEnabled WRITE setBottomLabelsEnabled NOTIFY bottomLabelsEnabledChanged)
  Q_PROPERTY(bool legendEnabled READ legendEnabled WRITE setLegendEnabled)
  Q_PROPERTY(QColor borderColor READ borderColor WRITE setborderColor NOTIFY borderColorChanged)
  Q_PROPERTY(QColor color READ bgColor WRITE setBgColor NOTIFY bgColorChanged)
  Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor)

  Q_PROPERTY(QString chartTitle READ chartTitle WRITE setChartTitle)

  //left axis
  Q_PROPERTY(bool leftAxisLogScale READ leftAxisLogScale WRITE setLeftAxisLogScaleEnabled)
  Q_PROPERTY(QList<QVariant> leftAxisBars READ leftAxisBars WRITE setLeftAxisBars NOTIFY leftAxisBarsChanged)
  Q_PROPERTY(double leftAxisMaxValue READ leftAxisMaxValue WRITE setLeftAxisMaxValue)
  Q_PROPERTY(double leftAxisMinValue READ leftAxisMinValue WRITE setLeftAxisMinValue)
  Q_PROPERTY(QColor leftAxisColor READ leftAxisColor WRITE setLeftAxisColor)
  Q_PROPERTY(QString leftAxisTitle READ leftAxisTitle WRITE setLeftAxisTitle)

  //right axis
  Q_PROPERTY(bool rightAxisLogScale READ rightAxisLogScale WRITE setRightAxisLogScaleEnabled)
  Q_PROPERTY(QList<QVariant> rightAxisBars READ rightAxisBars WRITE setRightAxisBars NOTIFY rightAxisBarsChanged)
  Q_PROPERTY(double rightAxisMaxValue READ rightAxisMaxValue WRITE setRightAxisMaxValue)
  Q_PROPERTY(double rightAxisMinValue READ rightAxisMinValue WRITE setRightAxisMinValue)
  Q_PROPERTY(QColor rightAxisColor READ rightAxisColor WRITE setRightAxisColor)
  Q_PROPERTY(bool rightAxisEnabled READ rightAxisEnabled WRITE setRightAxisEnabled)
  Q_PROPERTY(QString rightAxisTitle READ rightAxisTitle WRITE setRightAxisTitle)

public:
  BarChart(QQuickItem *parent = 0);
  ~BarChart();


  bool bottomLabelsEnabled() const;
  bool legendEnabled() const;

  QColor bgColor() const;
  QColor borderColor() const;
  QColor textColor() const;
  QString chartTitle() const;

  // QQmlParserStatus interface
  void componentComplete() Q_DECL_OVERRIDE;
  void paint(QPainter *t_painter) Q_DECL_OVERRIDE;

  /**
    * @b redeclared to prevent calling QQuickItem::classBegin()
    */
  void classBegin() Q_DECL_OVERRIDE {}

  //left axis
  bool leftAxisLogScale() const;
  double leftAxisMaxValue() const;
  double leftAxisMinValue() const;
  QList<QVariant> leftAxisBars() const;
  QColor leftAxisColor() const;
  QString leftAxisTitle() const;

  //right axis
  bool rightAxisLogScale() const;
  double rightAxisMaxValue() const;
  double rightAxisMinValue() const;
  QList<QVariant> rightAxisBars() const;
  QColor rightAxisColor() const;
  bool rightAxisEnabled() const;
  QString rightAxisTitle() const;

public slots:
  void onExternValuesChanged();
  void onHeightChanged();
  void onWidthChanged();
  void setBgColor(QColor t_bgColor);
  void setborderColor(QColor t_borderColor);
  void setBottomLabelsEnabled(bool t_bottomLabelsEnabled);
  void setChartTitle(QString t_chartTitle);
  void setLegendEnabled(bool t_legendEnabled);
  void setTextColor(QColor t_textColor);

  //left axis
  void setLeftAxisLogScaleEnabled(bool t_leftAxisLogScaleEnabled);
  void setLeftAxisMaxValue(double t_leftAxisMaxValue);
  void setLeftAxisMinValue(double t_leftAxisMinValue);
  void setLeftAxisBars(QList<QVariant> t_leftAxisValues);
  void setLeftAxisColor(QColor t_leftAxisColor);
  void setLeftAxisTitle(QString t_leftAxisTitle);

  //right axis
  void setRightAxisLogScaleEnabled(bool t_rightAxisLogScaleEnabled);
  void setRightAxisMaxValue(double t_rightAxisMaxValue);
  void setRightAxisMinValue(double t_rightAxisMinValue);
  void setRightAxisBars(QList<QVariant> t_rightAxisValues);
  void setRightAxisColor(QColor t_rightAxisColor);
  void setRightAxisEnabled(bool t_rightAxisEnabled);
  void setRightAxisTitle(QString t_rightAxisTitle);

signals:
  void bgColorChanged(QColor t_bgColor);
  void borderColorChanged(QColor t_borderColor);
  void bottomLabelsEnabledChanged(QStringList t_labelList);
  void maxValueLeftAxisChanged(double t_maxValueLeftAxis);
  void leftAxisBarsChanged(QList<QVariant> t_valuesLeftAxis);
  void rightAxisBarsChanged(QList<QVariant> t_valuesRightAxis);

private slots:
  void onExternValuesChangedTimeout();
  void onLabelsChanged(QStringList t_labelList);
  void onRefreshTimeout();
  void refreshPlot();

protected:


private:
  bool m_bottomLabelsEnabled;
  bool m_legendEnabled;

  QColor m_bgColor;
  QColor m_borderColor;
  QColor m_textColor;
  QStringList m_bottomLabels;
  QString m_chartTitle;
  QTimer *refreshTimer;
  QTimer *valuesTimer;
  QwtPlotCanvas *canvas;
  QwtPlot *plot;

  //left axis
  bool m_logScaleLeftAxis;
  BarData *barDataLeft;
  double m_maxValueLeftAxis=1000;
  double m_minValueLeftAxis=0.001;
  QList<QVariant> m_valuesLeftAxis;

  //right axis
  bool m_logScaleRightAxis;
  BarData *barDataRight;
  double m_maxValueRightAxis;
  double m_minValueRightAxis;
  QList<QVariant> m_valuesRightAxis;

  QColor m_colorLeftAxis;
  QColor m_colorRightAxis;
};

#endif // CBARCHART_H

