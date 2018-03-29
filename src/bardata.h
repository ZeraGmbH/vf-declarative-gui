#ifndef BARDATA_H
#define BARDATA_H


#include <qwt_plot_barchart.h>
#include <QColor>
#include <QString>
#include <QList>

class BarData : public QwtPlotBarChart
{

public:
  BarData();
  void addData(QColor t_color, const QString &t_title);

  void clearData();

  QStringList getTitles();
  // QwtPlotBarChart interface
public:
  /// @todo optimisation is recommended, or find out why this is called constantly
  virtual QwtColumnSymbol *specialSymbol(int t_sampleIndex, const QPointF &) const Q_DECL_OVERRIDE;
  QwtText barTitle(int t_sampleIndex) const Q_DECL_OVERRIDE;



private:
  QList<QColor> m_colors;
  QList<QString> m_titles;
};
#endif // BARDATA_H
