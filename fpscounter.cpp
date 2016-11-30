#include "fpscounter.h"

#include <QDateTime>
#include <QBrush>
#include <QPainter>

FPSCounter::FPSCounter(QQuickItem *t_parent): QQuickPaintedItem(t_parent)
{
  m_time = new QElapsedTimer();
  m_time->start();
  setFlag(QQuickItem::ItemHasContents);
  m_fpsEnabled = qgetenv("QML_SHOW_FRAMERATE").toInt();
  qDebug() << "FPS_ENABLED:" << m_fpsEnabled;
}

FPSCounter::~FPSCounter()
{
  delete m_time;
}

void FPSCounter::paint(QPainter *t_painter)
{
  Q_UNUSED(t_painter);
  if(m_fpsEnabled>0)
  {
    recalculateFPS();
    update();
  }
}

int FPSCounter::fpsEnabled() const
{
  return m_fpsEnabled;
}

float FPSCounter::fps()const
{
  return m_currentFPS;
}

void FPSCounter::setFpsEnabled(int t_fpsEnabled)
{
  if (m_fpsEnabled == t_fpsEnabled)
    return;

  m_time->restart();
  update();

  m_fpsEnabled = t_fpsEnabled;
  emit fpsEnabledChanged(t_fpsEnabled);
}

void FPSCounter::recalculateFPS()
{
  ++m_frameCount;
  m_fpsAverageList.enqueue(1000 / ((m_time->nsecsElapsed()+0.0000001) / 1000000));
  m_time->restart();
  if(m_fpsAverageList.count()>30)
  {
    m_fpsAverageList.dequeue();
  }
  m_currentFPS = m_fpsAverageList.head();
  foreach (float fpsLowest, m_fpsAverageList)
  {
    if(fpsLowest<m_currentFPS) //pessimistic calculation with high sensitivity for noncontiguous frame drops
    {
      m_currentFPS += fpsLowest;
      m_currentFPS /= 2;
    }
  }
  //qDebug()<< "FPS is " << m_currentFPS;
  if(m_frameCount>20)
  {
    emit fpsChanged(m_currentFPS);
    m_frameCount = 0;
  }
}
