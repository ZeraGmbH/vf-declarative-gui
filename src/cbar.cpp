#include "cbar.h"
#include <QDebug>

cBar::cBar(QQuickItem *t_parent) :
  QQuickItem(t_parent)
{
  m_color=QColor("white");
  m_value=0;
  m_title=QString();
}

QColor cBar::color() const
{
  return m_color;
}

QString cBar::title() const
{
  return m_title;
}

double cBar::value() const
{
  return m_value;
}

void cBar::setColor(QColor t_color)
{
  if (m_color != t_color)
  {
    m_color = t_color;
    emit colorChanged(t_color);
  }
}

void cBar::setTitle(QString t_title)
{
  if (m_title != t_title)
  {
    m_title = t_title;
    emit titleChanged(t_title);
  }
}

void cBar::setValue(double t_value)
{
  if (m_value != t_value)
  {
    m_value = t_value;
    emit valueChanged(t_value);
  }
}
