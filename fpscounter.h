#ifndef FPSTEXT_H
#define FPSTEXT_H

#include <QQuickPaintedItem>
#include <QElapsedTimer>
#include <QQueue>

/**
 * @brief Does NOT calculate average FPS
 */
class FPSCounter : public QQuickPaintedItem
{
  Q_OBJECT
  Q_PROPERTY(float currentFPS READ fps NOTIFY fpsChanged)
  Q_PROPERTY(int fpsEnabled READ fpsEnabled WRITE setFpsEnabled NOTIFY fpsEnabledChanged)

public:
  FPSCounter(QQuickItem *t_parent = 0);
  ~FPSCounter();

  void paint(QPainter *t_painter) override;
  int fpsEnabled() const;
  float fps() const;

public slots:
  void setFpsEnabled(int t_fpsEnabled);

signals:
  void fpsEnabledChanged(int t_fpsEnabled);
  void fpsChanged(float t_currentFPS);

private:
  void recalculateFPS();
  QElapsedTimer *m_time = 0;
  float m_currentFPS = 0.0;
  int m_fpsEnabled = 0;
  int m_frameCount = 0;
  QQueue<float> m_fpsQueue;
};

#endif // FPSTEXT_H
