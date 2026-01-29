#ifndef AXISSETTER_H
#define AXISSETTER_H

#include <QObject>
#include <QtCharts/QValueAxis>

using namespace QtCharts;

class AxisSetter : public QObject
{
    Q_OBJECT
public:
    explicit AxisSetter(QObject *parent = nullptr);

    Q_PROPERTY(QValueAxis* axis WRITE setAxis READ getAxis FINAL)
    Q_PROPERTY(double min READ getMin WRITE setMin NOTIFY minChanged FINAL)
    Q_PROPERTY(double max READ getMax WRITE setMax NOTIFY maxChanged FINAL)
    Q_PROPERTY(bool isXaxis WRITE setXAxis READ isXAxis FINAL)
    Q_PROPERTY(QString unitPrefix READ getPrefix NOTIFY prefixChanged FINAL)
    Q_PROPERTY(double scale READ getScale NOTIFY scaleChanged FINAL)

    void setAxis(QValueAxis *axis);
    QValueAxis *getAxis();

    void setMin(double min);
    double getMin();

    void setXAxis(bool isXaxis);
    bool isXAxis();

    void setMax(double max);
    double getMax();

    Q_INVOKABLE double getScale();
    QString getPrefix();

    void scaleAxis(double max);

signals :
    void minChanged(double min);
    void maxChanged(double max);
    void prefixChanged(QString unitPrefix);
    void scaleChanged(double scale);

private slots:

private:
    QValueAxis *m_axis;
    bool m_isXaxis;
    double m_min;
    double m_max;
    double m_scale = 1.0;
    QString m_unitPrefix = "";
};

#endif // AXISSETTER_H
