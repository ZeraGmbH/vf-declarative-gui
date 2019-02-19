#include "barscaledraw.h"

#include <qwt_text.h>

BarScaleDraw::BarScaleDraw() : QwtScaleDraw()
{
}

BarScaleDraw::BarScaleDraw(Qt::Orientation t_orientation, const QStringList &t_labels) : QwtScaleDraw(),
  m_labels(t_labels)
{
  setTickLength(QwtScaleDiv::MinorTick, 0);
  setTickLength(QwtScaleDiv::MediumTick, 0);
  setTickLength(QwtScaleDiv::MajorTick, 2);
  enableComponent(QwtScaleDraw::Backbone, false);

  if(t_labels.isEmpty()) //nothing to display so disable the fallback
  {
    //enableComponent(QwtScaleDraw::Backbone, false);
    enableComponent(QwtScaleDraw::Ticks, false);
    enableComponent(QwtScaleDraw::Labels, false);
  }

  if (t_orientation == Qt::Vertical)
  {
    setLabelRotation(-60.0);
  }
  else
  {
    setLabelRotation(-20.0);
  }

  setLabelAlignment(Qt::AlignLeft | Qt::AlignVCenter);
}

void BarScaleDraw::setColor(QColor t_color)
{
  m_textColor=t_color;
}

QwtText BarScaleDraw::label(double t_value) const
{
  QwtText lbl;
  const int index = qRound(t_value);
  if(index >= 0 && m_labels.count()>index)
  {
    lbl = m_labels.at(index);
  }
  else
  {
    lbl = QwtText (QString::number(t_value));
  }
  lbl.setColor(m_textColor);
  return lbl;
}
