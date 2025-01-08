#ifndef ROWAUTOSCALER_H
#define ROWAUTOSCALER_H

#include <QVariant>
#include "singlevaluescaler.h"

class RowAutoScaler
{
public:
    static constexpr double HYSTERESIS = 0.01;
    RowAutoScaler();
    void setUnscaledValue(int columnRole, QVariant value);
    SingleValueScaler *getSingleValueScaler();
    struct TRowScaleResult
    {
        QString scaledUnit;
        QHash<int, QVariant> scaledColumnValues;
    };
    TRowScaleResult scaleRow(QString baseUnit, QList<int> roleIdxSingleValues);
private:
    QHash<int, QVariant> m_unscaledColumnValues;
    SingleValueScaler *m_singleValueScaler;
};

#endif // ROWAUTOSCALER_H
