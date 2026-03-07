#ifndef ROWAUTOSCALER_H
#define ROWAUTOSCALER_H

#include <QVariant>
#include "singlevaluescaler.h"

class RowAutoScaler
{
public:
    static constexpr double HYSTERESIS = 0.01;
    void setUnscaledValue(int columnRole, QVariant value);
    SingleValueScaler::TSingleScaleResult scaleSingleVal(double value);
    struct TRowScaleResult
    {
        QString scaledUnit;
        QHash<int, QVariant> scaledColumnValues;
    };
    TRowScaleResult scaleRow(const QString &baseUnit, const QList<int> &roleIdxSingleValues);
private:
    QHash<int, QVariant> m_unscaledColumnValues;
    SingleValueScaler m_singleValueScaler;
};

#endif // ROWAUTOSCALER_H
