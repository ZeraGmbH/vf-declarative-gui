#ifndef SINGLEVALUESCALER_H
#define SINGLEVALUESCALER_H

#include <QObject>

class SingleValueScaler : public QObject
{
    Q_OBJECT
public:
    static constexpr double HYSTERESIS = 0.01;

    SingleValueScaler(QObject *parent = nullptr);
    struct TSingleScaleResult
    {
        double scaleFactor = 1.0;
        QString unitPrefix;
    };
    TSingleScaleResult scaleSingleVal(double val);
private:
    void setScale(double limit, QString limitPrefix, TSingleScaleResult &singleResult);
    bool scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &singleResult);
    double m_hysteresisValue = 0.0;
};

#endif // SINGLEVALUESCALER_H
