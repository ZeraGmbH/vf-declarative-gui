#ifndef LINESERIESFILLER_H
#define LINESERIESFILLER_H

#include <QObject>
#include <QtCharts/QLineSeries>
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
using namespace QtCharts;
#endif

class LineSeriesFiller : public QObject
{
    Q_OBJECT
public:
    explicit LineSeriesFiller(QObject *parent = nullptr);

    Q_PROPERTY(QLineSeries* lineSeries WRITE setLineSeries READ getLineSeries FINAL)
    Q_PROPERTY(int entityId WRITE setEntityId READ getEntityId FINAL)
    Q_PROPERTY(QString componentName WRITE setComponentName READ getComponentName FINAL)

    void setLineSeries(QLineSeries* lineSeries);
    QLineSeries* getLineSeries() const;

    void setEntityId(int entityId);
    int getEntityId() const;

    void setComponentName(QString componentName);
    QString getComponentName() const;

private slots:
    void onNewValuesAdded(int startIdx, int postEndIdx);
    void onClearedValues();

private:
    QLineSeries *m_lineSeries;
    int m_entityId;
    QString m_componentName;
};

#endif // LINESERIESFILLER_H
