#ifndef FFTBARCHART_H
#define FFTBARCHART_H

#include <QQuickPaintedItem>
#include <QList>
#include <QColor>
#include <QString>

class QwtPlot;
class BarData;
class QwtPlotCanvas;
class VeinEntity;


/**
 * @brief Zera specific crap class to display hyperstyled FFT bar charts
 * @todo Replace with Qt Quick Charts once the perfomance is above mediocre
 */
class FftBarChart : public QQuickPaintedItem
{
  Q_OBJECT
  Q_DISABLE_COPY(FftBarChart)

  Q_PROPERTY(bool bottomLabelsEnabled READ bottomLabels WRITE useBottomLabels NOTIFY labelsChanged)
  Q_PROPERTY(bool legendEnabled READ legendEnabled WRITE setLegendEnabled)
  Q_PROPERTY(QColor borderColor READ borderColor WRITE setborderColor NOTIFY borderColorChanged)
  Q_PROPERTY(QColor color READ bgColor WRITE setBgColor NOTIFY bgColorChanged)
  Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor)

  Q_PROPERTY(QString chartTitle READ chartTitle WRITE setChartTitle)

  //left axis
  Q_PROPERTY(bool logScaleLeftAxis READ logScaleLeftAxis WRITE setLogScaleLeftAxis)
  Q_PROPERTY(double maxValueLeftAxis READ maxValueLeftAxis WRITE setMaxValueLeftAxis)
  Q_PROPERTY(double minValueLeftAxis READ minValueLeftAxis WRITE setMinValueLeftAxis)
  Q_PROPERTY(QColor colorLeftAxis READ colorLeftAxis WRITE setColorLeftAxis)
  Q_PROPERTY(QString titleLeftAxis READ titleLeftAxis WRITE setTitleLeftAxis)
  Q_PROPERTY(QVariant leftValue READ fooDummy WRITE onLeftValueChanged) //writeonly

  //right axis
  Q_PROPERTY(bool logScaleRightAxis READ logScaleRightAxis WRITE setLogScaleRightAxis)
  Q_PROPERTY(double maxValueRightAxis READ maxValueRightAxis WRITE setMaxValueRightAxis)
  Q_PROPERTY(double minValueRightAxis READ minValueRightAxis WRITE setMinValueRightAxis)
  Q_PROPERTY(QColor colorRightAxis READ colorRightAxis WRITE setColorRightAxis)
  Q_PROPERTY(bool rightAxisEnabled READ rightAxisEnabled WRITE setRightAxisEnabled)
  Q_PROPERTY(QString titleRightAxis READ titleRightAxis WRITE setTitleRightAxis)
  Q_PROPERTY(QVariant rightValue READ fooDummy WRITE onRightValueChanged) //writeonly

public:
  FftBarChart(QQuickItem *t_parent = 0);
  ~FftBarChart();


  bool bottomLabels() const;
  bool legendEnabled() const;

  QColor bgColor() const;
  QColor borderColor() const;
  QColor textColor() const;
  QString chartTitle() const;

  // QQmlParserStatus interface
  void componentComplete() override;
  void paint(QPainter *t_painter) override;

  /**
    * @b redeclared to prevent calling QQuickItem::classBegin()
    */
  void classBegin() override {}

  //we really need support for writeonly properties
  QVariant fooDummy() const { return QVariant(); }

  //left axis
  bool logScaleLeftAxis() const;
  double maxValueLeftAxis() const;
  double minValueLeftAxis() const;
  QColor colorLeftAxis() const;
  QString titleLeftAxis() const;

  //right axis
  bool logScaleRightAxis() const;
  double maxValueRightAxis() const;
  double minValueRightAxis() const;
  QColor colorRightAxis() const;
  bool rightAxisEnabled() const;
  QString titleRightAxis() const;

public slots:
  void onExternValuesChanged();
  void onHeightChanged();
  void onWidthChanged();
  void setBgColor(QColor t_backgroundColor);
  void setborderColor(QColor t_borderColor);
  void useBottomLabels(bool t_labelsEnabled);
  void setChartTitle(QString t_chartTitle);
  void setLegendEnabled(bool t_legendEnabled);
  void setTextColor(QColor t_textColor);

  //left axis
  void setLogScaleLeftAxis(bool t_useLogScale);
  void setMaxValueLeftAxis(double t_maxValue);
  void setMinValueLeftAxis(double t_minValue);
  void setColorLeftAxis(QColor t_color);
  void setTitleLeftAxis(QString t_title);
  void onLeftValueChanged(QVariant t_leftValue);

  //right axis
  void setLogScaleRightAxis(bool t_useLogScale);
  void setMaxValueRightAxis(double t_maxValue);
  void setMinValueRightAxis(double t_minValue);
  void setColorRightAxis(QColor t_color);
  void setTitleRightAxis(QString t_title);
  void setRightAxisEnabled(bool t_rightAxisEnabled);
  void onRightValueChanged(QVariant t_rightValue);

signals:
  void bgColorChanged(QColor t_backgroundColor);
  void borderColorChanged(QColor t_borderColor);
  void labelsChanged(QStringList t_labelsEnabled);
  void maxValueLeftAxisChanged(double t_maxValueLeftAxis);
  void minValueChanged(double t_minValue);

private slots:
  void onExternValuesChangedTimeout();
  void onLabelsChanged(QStringList t_labels);
  void onRefreshTimeout();
  void refreshPlot();
  void onLeftBarCountChanged(int t_barCount);

private:
  bool m_bottomLabelsEnabled;
  bool m_legendEnabled;

  QColor m_bgColor;
  QColor m_borderColor;
  QColor m_textColor;
  QStringList m_bottomLabels;
  QString m_chartTitle;
  QTimer *m_refreshTimer;
  QTimer *m_valuesTimer;
  QwtPlotCanvas *m_canvas;
  QwtPlot *m_plot;

  //left axis
  bool m_logScaleLeftAxis = false;
  BarData *m_barDataLeft;
  double m_maxValueLeftAxis = 0.0;
  double m_minValueLeftAxis = 0.0;
  QList<qreal> m_valuesLeftAxis;
  QColor m_colorLeftAxis;
  int m_leftBarCount = 0;

  //right axis
  bool m_logScaleRightAxis = false;
  BarData *m_barDataRight;
  double m_maxValueRightAxis = 0.0;
  double m_minValueRightAxis = 0.0;
  QList<qreal> m_valuesRightAxis;
  QColor m_colorRightAxis;

};

#endif // FFTBARCHART_H
