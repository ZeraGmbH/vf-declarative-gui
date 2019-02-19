#ifndef HPWBARCHART_H
#define HPWBARCHART_H

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
class HpwBarChart : public QQuickPaintedItem
{
  Q_OBJECT
  Q_DISABLE_COPY(HpwBarChart)

  Q_PROPERTY(bool bottomLabelsEnabled READ bottomLabels WRITE useBottomLabels NOTIFY labelsChanged)
  Q_PROPERTY(bool legendEnabled READ legendEnabled WRITE setLegendEnabled)
  Q_PROPERTY(QColor borderColor READ borderColor WRITE setborderColor NOTIFY borderColorChanged)
  Q_PROPERTY(QColor color READ bgColor WRITE setBgColor NOTIFY bgColorChanged)
  Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor)

  Q_PROPERTY(QString chartTitle READ chartTitle WRITE setChartTitle)

  //left axis
  Q_PROPERTY(double maxValueLeftAxis READ maxValueLeftAxis WRITE setMaxValueLeftAxis)
  Q_PROPERTY(double minValueLeftAxis READ minValueLeftAxis WRITE setMinValueLeftAxis)
  Q_PROPERTY(QColor colorLeftAxis READ colorLeftAxis WRITE setColorLeftAxis)
  Q_PROPERTY(QString titleLeftAxis READ titleLeftAxis WRITE setTitleLeftAxis)

  Q_PROPERTY(QList<double> pValueList READ fooDummy WRITE setPValues) //writeonly
  Q_PROPERTY(QList<double> qValueList READ fooDummy WRITE setQValues) //writeonly
  Q_PROPERTY(QList<double> sValueList READ fooDummy WRITE setSValues) //writeonly

public:
  HpwBarChart(QQuickItem *t_parent = 0);
  ~HpwBarChart();


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
  QList<double> fooDummy() const { return QList<double>(); }

  //left axis
  double maxValueLeftAxis() const;
  double minValueLeftAxis() const;
  QColor colorLeftAxis() const;
  QString titleLeftAxis() const;

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
  void setMaxValueLeftAxis(double t_maxValue);
  void setMinValueLeftAxis(double t_minValue);
  void setColorLeftAxis(QColor t_color);
  void setTitleLeftAxis(QString t_title);

  //PQS values
  void setPValues(QList<double> t_pValues);
  void setQValues(QList<double> t_qValues);
  void setSValues(QList<double> t_sValues);

signals:
  void bgColorChanged(QColor t_backgroundColor);
  void borderColorChanged(QColor t_borderColor);
  void labelsChanged(QStringList t_labelsEnabled);

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
  BarData *m_barDataLeft;
  double m_maxValueLeftAxis;
  double m_minValueLeftAxis;
  QList<double> m_pValues;
  QList<double> m_qValues;
  QList<double> m_sValues;
  QColor m_colorLeftAxis;
  int m_leftBarCount;
};

#endif // HPWBARCHART_H
