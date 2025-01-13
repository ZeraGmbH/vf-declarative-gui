#ifndef SINGLEVALUESCALER_H
#define SINGLEVALUESCALER_H

#include <QObject>

class SingleValueScaler : public QObject
{
    Q_OBJECT
public:
    static constexpr double HYSTERESIS = 0.01;
    SingleValueScaler(QObject *parent = nullptr);
    Q_INVOKABLE void scaleSingleValForQML(double val);
    Q_INVOKABLE double getScaleFactor();
    Q_INVOKABLE QString getUnitPrefix();

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
    double m_scaleFactor = 1.0;
    QString m_unitPrefix;
};

#endif // SINGLEVALUESCALER_H
