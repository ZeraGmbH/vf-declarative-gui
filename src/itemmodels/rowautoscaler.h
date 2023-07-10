#ifndef ROWAUTOSCALER_H
#define ROWAUTOSCALER_H

#include <QVariant>

class RowAutoScaler
{
public:
    RowAutoScaler();
    void setUnscaledValue(int columnRole, QVariant value);
    struct TScaleResult
    {
        QString scaledUnit;
        QHash<int, QVariant> scaledColumnValues;
    };
    TScaleResult doScale(QString baseUnit);
private:
    QHash<int, QVariant> m_unscaledColumnValues;
};

#endif // ROWAUTOSCALER_H
