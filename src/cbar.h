#ifndef CBAR_H
#define CBAR_H

#include <QQuickItem>
#include <QColor>
#include <QString>

class cBar : public QQuickItem
{
  Q_OBJECT
  Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
  Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
  Q_PROPERTY(double value READ value WRITE setValue NOTIFY valueChanged)

public:
  explicit cBar(QQuickItem *t_parent = 0);
  QColor color() const;
  QString title() const;
  double value() const;

signals:
  void colorChanged(QColor t_color);
  void titleChanged(QString t_title);
  void valueChanged(double t_value);

public slots:
  void setColor(QColor t_color);
  void setTitle(QString t_title);
  void setValue(double t_value);

private:
  QColor m_color;
  QString m_title;
  double m_value;

};

#endif // CBAR_H
