#include "sidescaledraw.h"

#include <qwt_text.h>

SideScaleDraw::SideScaleDraw() : QwtScaleDraw()
{
}

void SideScaleDraw::setColor(QColor t_arg)
{
  m_textColor=t_arg;
}

QwtText SideScaleDraw::label(double t_value) const
{
  QwtText lbl = QwtText (QString::number(t_value));
  lbl.setColor(m_textColor);
  return lbl;
}
