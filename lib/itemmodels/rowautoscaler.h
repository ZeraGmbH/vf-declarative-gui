#ifndef ROWAUTOSCALER_H
#define ROWAUTOSCALER_H

#include <QVariant>

class RowAutoScaler
{
public:
    RowAutoScaler();
    void setUnscaledValue(int columnRole, QVariant value);
    struct TRowScaleResult
    {
        QString scaledUnit;
        QHash<int, QVariant> scaledColumnValues;
    };
    TRowScaleResult scaleRow(QString baseUnit, QList<int> roleIdxSingleValues);
    struct TSingleScaleResult
    {
        double scaleFactor = 1.0;
        QString unitPrefix;
    };
    TSingleScaleResult scaleSingleVal(double absVal);
private:
    bool scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &result);
    QHash<int, QVariant> m_unscaledColumnValues;
};

#endif // ROWAUTOSCALER_H
