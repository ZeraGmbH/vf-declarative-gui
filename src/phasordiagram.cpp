#include "phasordiagram.h"
#include "qnanolineargradient.h"

#include <QVector2D>

//used for atan2 and math constants like M_PI
#include <math.h>

// HelloItemPainter contains the painting code
class PhasorPainter : public QNanoQuickItemPainter
{
  bool m_gridVisible = true;
  bool m_circleVisible = true;
  bool m_currentVisible = true;
  PhasorDiagram::VectorView m_vectorView;
  PhasorDiagram::VectorMode m_vectorMode;
  QNanoColor m_gridColor;
  QNanoColor m_circleColor;
  float m_circleValue;
  float m_labelPhiOffset;
  float m_fromX=0;
  float m_fromY=0;
  float m_phiOrigin=0;
  float m_gridScale=1;
  float m_maxVoltage;
  float m_maxCurrent;



  QVector2D m_vector1;
  QVector2D m_vector2;
  QVector2D m_vector3;
  QVector2D m_vector4;
  QVector2D m_vector5;
  QVector2D m_vector6;

  QNanoColor m_vector1Color;
  QNanoColor m_vector2Color;
  QNanoColor m_vector3Color;
  QNanoColor m_vector4Color;
  QNanoColor m_vector5Color;
  QNanoColor m_vector6Color;

  QString m_vector1Label;
  QString m_vector2Label;
  QString m_vector3Label;
  QString m_vector4Label;
  QString m_vector5Label;
  QString m_vector6Label;

  QNanoFont m_defaultFont;

public:
  PhasorPainter() : m_defaultFont(QNanoFont(QNanoFont::DEFAULT_FONT_BOLD))
  {
    m_defaultFont.setPixelSize(20);
  }

  virtual ~PhasorPainter() override;

  float pixelScale(float t_base)
  {
    return std::min(height(), width())/t_base/2;
  }

  void drawLabel(QNanoPainter *t_painter, const QString &t_label, float t_vectorPhi, QNanoColor t_color, float t_scale=1, float t_labelPhiOffset=0)
  {
    float xOffset = t_label.length()*5;
    const float tmpPhi = t_vectorPhi - m_phiOrigin;
    float xPos = m_fromX - xOffset + t_scale * m_gridScale * m_circleValue * 1.2 * cos(tmpPhi + t_labelPhiOffset);
    float yPos = m_fromY + 5 + 0.9 * t_scale * m_gridScale * m_circleValue * 1.2 * sin(tmpPhi + t_labelPhiOffset);

    t_painter->setFillStyle(t_color);
    t_painter->setFont(m_defaultFont);
    //t_painter->moveTo(m_fromX, m_fromY);
    //sub-pixel antialiasing makes everything blurry so round the x/y values
    t_painter->fillText(t_label, round(xPos), round(yPos));
  }

  void drawArrowHead(QNanoPainter *t_painter, QVector2D t_vector, QNanoColor t_color, float t_maxValue)
  {
    t_painter->setLineWidth(1);
    float arrowHeadSize = 12.0f;

    const float tmpPhi = atan2(t_vector.y(), t_vector.x()) - m_phiOrigin;
    const float tmpToX = m_fromX + pixelScale(t_maxValue) * t_vector.length() * cos(tmpPhi);
    const float tmpToY = m_fromY + pixelScale(t_maxValue) * t_vector.length() * sin(tmpPhi);

    const float angle = atan2(tmpToY - m_fromY , tmpToX - m_fromX);
    t_painter->beginPath();
    t_painter->moveTo(tmpToX, tmpToY);
    t_painter->lineTo(tmpToX - arrowHeadSize * cos(angle - M_PI / 6), tmpToY - arrowHeadSize * sin(angle - M_PI / 6));
    t_painter->lineTo(tmpToX - arrowHeadSize * cos(angle + M_PI / 6), tmpToY - arrowHeadSize * sin(angle + M_PI / 6));
    t_painter->lineTo(tmpToX, tmpToY);
    t_painter->closePath();
    t_painter->setFillStyle(t_color);
    t_painter->fill();
    t_painter->setStrokeStyle(t_color);
    t_painter->stroke();
  }

  void drawVectorLine(QNanoPainter *t_painter, QVector2D t_vector, QNanoColor t_color, float t_maxValue)
  {
    t_painter->setLineWidth(1);

    const float tmpPhi = atan2(t_vector.y(), t_vector.x()) - m_phiOrigin;
    const float tmpX = m_fromX + pixelScale(t_maxValue) * t_vector.length() * cos(tmpPhi);
    const float tmpY = m_fromY + pixelScale(t_maxValue) * t_vector.length() * sin(tmpPhi);
    t_painter->beginPath();
    t_painter->moveTo(m_fromX, m_fromY);
    t_painter->lineTo(tmpX, tmpY);
    t_painter->closePath();
    t_painter->setStrokeStyle(t_color);
    t_painter->stroke();
  }

  void drawVoltageArrows(QNanoPainter *t_painter, float t_factor=1)
  {
    t_painter->setLineWidth(1);
    //the font size is magically changed to a smaller size (from within the library)
    //it is unaffected by Qt::AA_DisableHighDpiScaling, some sort of mad dpi scaling voodoo?!?
    m_defaultFont.setPixelSize(20);

    drawArrowHead(t_painter, m_vector1, m_vector1Color, m_maxVoltage * t_factor);
    drawVectorLine(t_painter, m_vector1, m_vector1Color, m_maxVoltage * t_factor);
    if(m_vector1Label.isEmpty() == false && m_vector1.length() > m_maxVoltage * t_factor / 10)
    {
      drawLabel(t_painter, m_vector1Label, atan2(m_vector1.y(), m_vector1.x()), m_vector1Color);
    }

    drawArrowHead(t_painter, m_vector2, m_vector2Color, m_maxVoltage * t_factor);
    drawVectorLine(t_painter, m_vector2, m_vector2Color, m_maxVoltage * t_factor);
    if(m_vector2Label.isEmpty() == false && m_vector2.length() > m_maxVoltage * t_factor / 10)
    {
      drawLabel(t_painter, m_vector2Label, atan2(m_vector2.y(), m_vector2.x()), m_vector2Color);
    }

    drawArrowHead(t_painter, m_vector3, m_vector3Color, m_maxVoltage * t_factor);
    drawVectorLine(t_painter, m_vector3, m_vector3Color, m_maxVoltage * t_factor);
    if(m_vector3Label.isEmpty() == false && m_vector3.length() > m_maxVoltage * t_factor / 10)
    {
      drawLabel(t_painter, m_vector3Label, atan2(m_vector3.y(), m_vector3.x()), m_vector3Color);
    }
  }

  void drawCurrentArrows(QNanoPainter *t_painter)
  {
    if(m_currentVisible)
    {
      t_painter->setLineWidth(1);

      drawVectorLine(t_painter, m_vector4, m_vector4Color, m_maxCurrent);
      drawArrowHead(t_painter, m_vector4, m_vector4Color, m_maxCurrent);
      if(m_vector4Label.isEmpty() == false && m_vector4.length() > m_maxCurrent / 10)
      {
        drawLabel(t_painter, m_vector4Label, atan2(m_vector4.y(), m_vector4.x()), m_vector4Color, 0.5, m_labelPhiOffset);
      }

      drawVectorLine(t_painter, m_vector5, m_vector5Color, m_maxCurrent);
      drawArrowHead(t_painter, m_vector5, m_vector5Color, m_maxCurrent);
      if(m_vector5Label.isEmpty() == false && m_vector5.length() > m_maxCurrent / 10)
      {
        drawLabel(t_painter, m_vector5Label, atan2(m_vector5.y(), m_vector5.x()), m_vector5Color, 0.5, m_labelPhiOffset);
      }

      drawVectorLine(t_painter, m_vector6, m_vector6Color, m_maxCurrent);
      drawArrowHead(t_painter, m_vector6, m_vector6Color, m_maxCurrent);
      if(m_vector6Label.isEmpty() == false && m_vector6.length() > m_maxCurrent / 10)
      {
        drawLabel(t_painter, m_vector6Label, atan2(m_vector6.y(), m_vector6.x()), m_vector6Color, 0.5, m_labelPhiOffset);
      }
    }
  }

  void drawTriangle(QNanoPainter *t_painter)
  {
    t_painter->setLineWidth(1);

    //Scale vectors and convert to x/y
    //v1
    const float v1Phi = atan2(m_vector1.y(), m_vector1.x()) - m_phiOrigin;
    const float v1X = m_fromX + m_gridScale * m_vector1.length() * cos(v1Phi);
    const float v1Y = m_fromY + m_gridScale * m_vector1.length() * sin(v1Phi);

    //v2
    const float v2Phi = atan2(m_vector2.y(), m_vector2.x()) - m_phiOrigin;
    const float v2X = m_fromX + m_gridScale * m_vector2.length() * cos(v2Phi);
    const float v2Y = m_fromY + m_gridScale * m_vector2.length() * sin(v2Phi);

    //v3
    const float v3Phi = atan2(m_vector3.y(), m_vector3.x()) - m_phiOrigin;
    const float v3X = m_fromX + m_gridScale * m_vector3.length() * cos(v3Phi);
    const float v3Y = m_fromY + m_gridScale * m_vector3.length() * sin(v3Phi);

    //Gradients
    //v1->v2
    QNanoLinearGradient grd1 = QNanoLinearGradient(v1X, v1Y, v2X, v2Y);
    grd1.setStartColor(m_vector1Color);
    grd1.setEndColor(m_vector2Color);

    //v2->v3
    QNanoLinearGradient grd2 = QNanoLinearGradient(v2X, v2Y, v3X, v3Y);
    grd2.setStartColor(m_vector2Color);
    grd2.setEndColor(m_vector3Color);

    //v3->v1
    QNanoLinearGradient grd3 = QNanoLinearGradient(v3X, v3Y, v1X, v1Y);
    grd3.setStartColor(m_vector3Color);
    grd3.setEndColor(m_vector1Color);

    //--Draw--//////////////////////// v1 -> v2
    t_painter->beginPath();
    t_painter->moveTo(v1X, v1Y);
    t_painter->lineTo(v2X, v2Y);
    t_painter->closePath();
    t_painter->setStrokeStyle(grd1);
    t_painter->stroke();

    //--Draw--//////////////////////// v2 -> v3
    t_painter->beginPath();
    t_painter->moveTo(v2X, v2Y);
    t_painter->lineTo(v3X, v3Y);
    t_painter->closePath();
    t_painter->setStrokeStyle(grd2);
    t_painter->stroke();


    //--Draw--//////////////////////// v3 -> v1
    t_painter->beginPath();
    t_painter->moveTo(v3X, v3Y);
    t_painter->lineTo(v1X, v1Y);
    t_painter->closePath();
    t_painter->setStrokeStyle(grd3);
    t_painter->stroke();

    if(m_vector1Label.isEmpty() == false && m_vector1.length() > m_maxVoltage / 10)
    {
      drawLabel(t_painter, m_vector1Label, atan2(m_vector1.y(), m_vector1.x()), m_vector1Color);
    }

    if(m_vector2Label.isEmpty() == false && m_vector2.length() > m_maxVoltage / 10)
    {
      drawLabel(t_painter, m_vector2Label, atan2(m_vector2.y(), m_vector2.x()), m_vector2Color);
    }

    if(m_vector3Label.isEmpty() == false && m_vector3.length() > m_maxVoltage / 10)
    {
      drawLabel(t_painter, m_vector3Label, atan2(m_vector3.y(), m_vector3.x()), m_vector3Color);
    }
  }

  void drawGridAndCircle(QNanoPainter *t_painter)
  {
    t_painter->setLineWidth(1);

    //grid
    if(m_gridVisible)
    {
      t_painter->setStrokeStyle(m_gridColor);

      //x axis
      t_painter->beginPath();
      t_painter->moveTo(m_fromX - m_maxVoltage * m_gridScale, m_fromY);
      t_painter->lineTo(m_fromX + m_maxVoltage * m_gridScale, m_fromY);
      t_painter->closePath();
      t_painter->stroke();

      //y axis
      t_painter->beginPath();
      t_painter->moveTo(m_fromX, m_fromY - m_maxVoltage * m_gridScale);
      t_painter->lineTo(m_fromX, m_fromY + m_maxVoltage * m_gridScale);
      t_painter->closePath();
      t_painter->stroke();
    }

    //circle
    if(m_circleVisible)
    {
      t_painter->setStrokeStyle(m_circleColor);
      t_painter->beginPath();
      t_painter->arc(m_fromX, m_fromY, m_gridScale * m_circleValue, 0.0f, M_PI*2.0);
      t_painter->closePath();
      t_painter->stroke();
    }
  }



  // QNanoQuickItemPainter interface
protected:
  void paint(QNanoPainter *t_painter) override
  {
    drawGridAndCircle(t_painter);

    switch(m_vectorView)
    {
      case PhasorDiagram::VectorView::VIEW_STAR:
      {
        drawVoltageArrows(t_painter);
        drawCurrentArrows(t_painter);
        break;
      }
      case PhasorDiagram::VectorView::VIEW_TRIANGLE:
      {
        drawTriangle(t_painter);
        drawCurrentArrows(t_painter);
        break;
      }
      case PhasorDiagram::VectorView::VIEW_THREE_PHASE:
      {
        drawVoltageArrows(t_painter, sqrt(3.0f)); //concatenated voltage
        drawCurrentArrows(t_painter);
        break;
      }
    }
  }

  void synchronize(QNanoQuickItem *t_item) override
  {
    PhasorDiagram *realItem  = static_cast<PhasorDiagram *>(t_item);
    Q_ASSERT(realItem != nullptr);

    m_fromX = realItem->fromX();
    m_fromY = realItem->fromY();
    m_phiOrigin = realItem->phiOrigin();
    m_gridScale = realItem->gridScale();
    m_maxVoltage = realItem->maxVoltage();
    m_maxCurrent = realItem->maxCurrent();
    m_currentVisible = realItem->currentVisible();
    m_vectorView = realItem->vectorView();
    m_vectorMode = realItem->vectorMode();
    m_gridVisible = realItem->gridVisible();
    m_gridColor = QNanoColor::fromQColor(realItem->gridColor());
    m_circleVisible = realItem->circleVisible();
    m_circleColor = QNanoColor::fromQColor(realItem->circleColor());
    m_circleValue = realItem->circleValue();
    m_labelPhiOffset = realItem->labelPhiOffset();

    m_vector1Color = QNanoColor::fromQColor(realItem->vector1Color());
    m_vector2Color = QNanoColor::fromQColor(realItem->vector2Color());
    m_vector3Color = QNanoColor::fromQColor(realItem->vector3Color());
    m_vector4Color = QNanoColor::fromQColor(realItem->vector4Color());
    m_vector5Color = QNanoColor::fromQColor(realItem->vector5Color());
    m_vector6Color = QNanoColor::fromQColor(realItem->vector6Color());

    m_vector1Label = realItem->vector1Label();
    m_vector2Label = realItem->vector2Label();
    m_vector3Label = realItem->vector3Label();
    m_vector4Label = realItem->vector4Label();
    m_vector5Label = realItem->vector5Label();
    m_vector6Label = realItem->vector6Label();

    QList<double> tmpData = realItem->vector1Data();
    if(tmpData.length() > 1)
    {
      m_vector1 = QVector2D(tmpData.at(0), tmpData.at(1));
    }
    tmpData = realItem->vector2Data();
    if(tmpData.length() > 1)
    {
      m_vector2 = QVector2D(tmpData.at(0), tmpData.at(1));
    }
    tmpData = realItem->vector3Data();
    if(tmpData.length() > 1)
    {
      m_vector3 = QVector2D(tmpData.at(0), tmpData.at(1));
    }
    tmpData = realItem->vector4Data();
    if(tmpData.length() > 1)
    {
      m_vector4 = QVector2D(tmpData.at(0), tmpData.at(1));
    }
    tmpData = realItem->vector5Data();
    if(tmpData.length() > 1)
    {
      m_vector5 = QVector2D(tmpData.at(0), tmpData.at(1));
    }
    tmpData = realItem->vector6Data();
    if(tmpData.length() > 1)
    {
      m_vector6 = QVector2D(tmpData.at(0), tmpData.at(1));
    }
  }
};

PhasorPainter::~PhasorPainter() {}

PhasorDiagram::PhasorDiagram(QQuickItem *t_parent) : QNanoQuickItem(t_parent)
{
}

QNanoQuickItemPainter *PhasorDiagram::createItemPainter() const
{
  // Create painter for this item
  return new PhasorPainter();
}
