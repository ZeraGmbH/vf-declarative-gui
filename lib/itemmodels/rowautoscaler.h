#ifndef ROWAUTOSCALER_H
#define ROWAUTOSCALER_H

#include <QVariant>

class RowAutoScaler
{
public:
    static constexpr double HYSTERESIS = 0.01;
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
    void setScale(double limit, QString limitPrefix, TSingleScaleResult &singleResult);
    bool scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &result);
    QHash<int, QVariant> m_unscaledColumnValues;
    double m_hysteresisValue = 0.0;
    QString m_LastPrefix;
};

#endif // ROWAUTOSCALER_H
