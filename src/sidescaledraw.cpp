#include "sidescaledraw.h"

#include <qwt_text.h>

SideScaleDraw::SideScaleDraw() : QwtScaleDraw()
{
}

void SideScaleDraw::setColor(QColor t_arg)
{
  m_textColor=t_arg;
}

QString SideScaleDraw::getTextTransform() const
{
  return m_textTransform;
}

void SideScaleDraw::setTextTransform(const QString &t_textTransform)
{
  m_textTransform = t_textTransform;
}

QwtText SideScaleDraw::label(double t_value) const
{
  QwtText lbl = QwtText (m_textTransform.arg(t_value));
  lbl.setColor(m_textColor);
  return lbl;
}
