#ifndef SINGLEVALUESCALER_H
#define SINGLEVALUESCALER_H

#include <QObject>

class SingleValueScaler : public QObject
{
    Q_OBJECT
public:
    static constexpr double HYSTERESIS = 0.01;
    SingleValueScaler(QObject *parent = nullptr);
    Q_PROPERTY(double scaleFactor READ getScaleFactor NOTIFY scaleFactorChanged);
    Q_PROPERTY(QString unitPrefix READ getUnitPrefix NOTIFY unitPrefixChanged);
    Q_INVOKABLE bool scaleSingleValForQML(double val);

    void setScaleFactor(double scaleFactor);
    double getScaleFactor();
    void setUnitPrefix(QString unitPrefix);
    QString getUnitPrefix();

    struct TSingleScaleResult
    {
        double scaleFactor = 1.0;
        QString unitPrefix;
    };
    TSingleScaleResult scaleSingleVal(double val);
signals:
    void scaleFactorChanged();
    void unitPrefixChanged();
private:
    void setScale(double limit, QString limitPrefix, TSingleScaleResult &singleResult);
    bool scaleSingleValForPrefix(double absVal, double limit, QString limitPrefix, TSingleScaleResult &singleResult);
    double m_hysteresisValue = 0.0;
    double m_scaleFactor = 1.0;
    QString m_unitPrefix;
};

#endif // SINGLEVALUESCALER_H
