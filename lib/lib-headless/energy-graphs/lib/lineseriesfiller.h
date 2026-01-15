#ifndef LINESERIESFILLER_H
#define LINESERIESFILLER_H

#include <QObject>
#include <QtCharts/QLineSeries>

class LineSeriesFiller : public QObject
{
    Q_OBJECT
public:
    explicit LineSeriesFiller(QObject *parent = nullptr);

    Q_PROPERTY(QObject* lineSeries WRITE setLineSeries FINAL)
    Q_PROPERTY(int entityId WRITE setEntityId FINAL)
    Q_PROPERTY(QString componentName WRITE setComponentName FINAL)

    void setLineSeries(QObject* lineSeries);
    void setEntityId(int entityId);
    void setComponentName(QString componentName);

private slots:
    void onNewValuesAdded(int startIdx, int postEndIdx);
    void onClearedValues();

private:
    QtCharts::QLineSeries *m_lineSeries;
    int m_entityId;
    QString m_componentName;
};

#endif // LINESERIESFILLER_H
