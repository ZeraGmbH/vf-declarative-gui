#ifndef ROWAUTOSCALER_H
#define ROWAUTOSCALER_H

#include <QVariant>

class RowAutoScaler
{
public:
    RowAutoScaler();
    void setUnscaledValue(int columnRole, QVariant value);
    void doScale(QString baseUnit, QString &scaledUnit, QHash<int, QVariant> &scaledColumnValues);
private:
    QHash<int, QVariant> m_unscaledColumnValues;
};

#endif // ROWAUTOSCALER_H
