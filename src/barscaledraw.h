#ifndef BARSCALEDRAW_H
#define BARSCALEDRAW_H

#include <qwt_scale_draw.h>
#include <QColor>
#include <QStringList>

class BarScaleDraw : public QwtScaleDraw
{
public:
  BarScaleDraw();
  BarScaleDraw(Qt::Orientation t_orientation, const QStringList &t_labels);

  void setColor(QColor t_color);

  //QwtScaleDraw interface
  virtual QwtText label(double t_value) const override;

private:
  QColor m_textColor;
  QStringList m_labels;
};
#endif // BARSCALEDRAW_H
