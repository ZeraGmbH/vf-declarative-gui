#ifndef SIDESCALEDRAW_H
#define SIDESCALEDRAW_H
#include <qwt_scale_draw.h>
#include <QColor>
#include <QStringList>

class SideScaleDraw : public QwtScaleDraw
{
public:
  SideScaleDraw();

  void setColor(QColor t_arg);

  //QwtScaleDraw interface
  virtual QwtText label(double t_value) const override;

private:
  QColor m_textColor;
};

#endif // SIDESCALEDRAW_H
