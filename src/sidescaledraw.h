#ifndef SIDESCALEDRAW_H
#define SIDESCALEDRAW_H
#include <qwt_scale_draw.h>
#include <QColor>
#include <QStringList>

class SideScaleDraw : public QwtScaleDraw
{
public:
  SideScaleDraw(bool t_enabled=true);

  void setColor(QColor t_arg);

  QString getTextTransform() const;
  void setTextTransform(const QString &t_textTransform);

  //QwtScaleDraw interface
  virtual QwtText label(double t_value) const override;

private:
  QColor m_textColor;
  ///@b used as m_textTransform.arg(t_value) in label()
  QString m_textTransform="%1";
};

#endif // SIDESCALEDRAW_H
