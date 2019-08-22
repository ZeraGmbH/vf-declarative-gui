#ifndef PHASORDIAGRAM_H
#define PHASORDIAGRAM_H

#include "qnanoquickitem.h"
#include "qnanoquickitempainter.h"

/**
 * @brief Paints the phasor diagram (VectorModulePage.qml)
 */
class PhasorDiagram: public QNanoQuickItem
{
  Q_OBJECT

public:
  explicit PhasorDiagram(QQuickItem *t_parent = nullptr);

  enum class VectorView : int
  {
    VIEW_STAR = 0,
    VIEW_TRIANGLE = 1,
    VIEW_THREE_PHASE = 2
  };
  Q_ENUM(VectorView)

  enum class VectorMode : int {
    DIN410 = 0,
    IEC387 = 1
  };
  Q_ENUM(VectorMode)

  QNANO_PROPERTY(float, m_fromX, fromX, setFromX)
  QNANO_PROPERTY(float, m_fromY, fromY, setFromY)
  QNANO_PROPERTY(float, m_phiOrigin, phiOrigin, setPhiOrigin)
  QNANO_PROPERTY(float, m_gridScale, gridScale, setGridScale)
  QNANO_PROPERTY(float, m_maxVoltage, maxVoltage, setMaxVoltage)
  QNANO_PROPERTY(float, m_maxCurrent, maxCurrent, setMaxCurrent)
  QNANO_PROPERTY(VectorView, m_vectorView, vectorView, setVectorView)
  QNANO_PROPERTY(VectorMode, m_vectorMode, vectorMode, setVectorMode)
  QNANO_PROPERTY(bool, m_currentVisible, currentVisible, setCurrentVisible)
  QNANO_PROPERTY(float, m_maxValueVoltage, maxValueVoltage, setMaxValueVoltage)
  QNANO_PROPERTY(float, m_maxValueCurrent, maxValueCurrent, setMaxValueCurrent)
  QNANO_PROPERTY(bool, m_gridVisible, gridVisible, setGridVisible)
  QNANO_PROPERTY(QColor, m_gridColor, gridColor, setGridColor)
  QNANO_PROPERTY(bool, m_circleVisible, circleVisible, setCircleVisible)
  QNANO_PROPERTY(QColor, m_circleColor, circleColor, setCircleColor)
  QNANO_PROPERTY(float, m_circleValue, circleValue, setCircleValue)
  QNANO_PROPERTY(float, m_labelPhiOffset, labelPhiOffset, setLabelPhiOffset)

  QNANO_PROPERTY(QList<double>, m_vector1Data, vector1Data, setVector1Data)
  QNANO_PROPERTY(QList<double>, m_vector2Data, vector2Data, setVector2Data)
  QNANO_PROPERTY(QList<double>, m_vector3Data, vector3Data, setVector3Data)
  QNANO_PROPERTY(QList<double>, m_vector4Data, vector4Data, setVector4Data)
  QNANO_PROPERTY(QList<double>, m_vector5Data, vector5Data, setVector5Data)
  QNANO_PROPERTY(QList<double>, m_vector6Data, vector6Data, setVector6Data)

  QNANO_PROPERTY(QColor, m_vector1Color, vector1Color, setVector1Color)
  QNANO_PROPERTY(QColor, m_vector2Color, vector2Color, setVector2Color)
  QNANO_PROPERTY(QColor, m_vector3Color, vector3Color, setVector3Color)
  QNANO_PROPERTY(QColor, m_vector4Color, vector4Color, setVector4Color)
  QNANO_PROPERTY(QColor, m_vector5Color, vector5Color, setVector5Color)
  QNANO_PROPERTY(QColor, m_vector6Color, vector6Color, setVector6Color)

  QNANO_PROPERTY(QString, m_vector1Label, vector1Label, setVector1Label)
  QNANO_PROPERTY(QString, m_vector2Label, vector2Label, setVector2Label)
  QNANO_PROPERTY(QString, m_vector3Label, vector3Label, setVector3Label)
  QNANO_PROPERTY(QString, m_vector4Label, vector4Label, setVector4Label)
  QNANO_PROPERTY(QString, m_vector5Label, vector5Label, setVector5Label)
  QNANO_PROPERTY(QString, m_vector6Label, vector6Label, setVector6Label)


  // Reimplement
  QNanoQuickItemPainter *createItemPainter() const override;
};

#endif // PHASORDIAGRAM_H
