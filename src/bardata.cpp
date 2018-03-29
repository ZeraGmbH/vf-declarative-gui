#include "bardata.h"

#include <qwt_column_symbol.h>
#include <qwt_text.h>
#include <QPalette>

BarData::BarData()
{
  setLegendMode(QwtPlotBarChart::LegendBarTitles);
  setLegendIconSize(QSize(10, 14));
  setSpacing(4);
}

void BarData::addData(QColor t_color, const QString &t_title)
{
  m_colors += t_color;
  m_titles += t_title;
  itemChanged();
}

QwtColumnSymbol *BarData::specialSymbol(int t_sampleIndex, const QPointF &) const
{
  QwtColumnSymbol *symbol = new QwtColumnSymbol(QwtColumnSymbol::Box);
  symbol->setLineWidth(2);
  symbol->setFrameStyle(QwtColumnSymbol::Raised);

  QColor c(Qt::white);
  if (t_sampleIndex >= 0 && t_sampleIndex < m_colors.size())
  {
    c = m_colors.at(t_sampleIndex);
  }

  symbol->setPalette(QPalette(c));

  return symbol;
}

QwtText BarData::barTitle(int t_sampleIndex) const
{
  QwtText title;
  if (t_sampleIndex >= 0 && t_sampleIndex < m_titles.size())
  {
    title = m_titles.at(t_sampleIndex);
  }
  return title;
}

void BarData::clearData()
{
  //qDebug("CLEAR");
  m_colors.clear();
  m_titles.clear();
  dataChanged(); //not a signal, so no emit
}

QStringList BarData::getTitles()
{
  return m_titles;
}
