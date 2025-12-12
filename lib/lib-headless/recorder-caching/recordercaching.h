#ifndef RECORDERCACHING_H
#define RECORDERCACHING_H

#include <QJsonObject>
#include <QObject>

class RecorderCaching : public QObject
{
    Q_OBJECT
public:
    explicit RecorderCaching(QObject *parent = nullptr);
    static RecorderCaching *getInstance();

    Q_PROPERTY(QJsonObject recordedValues READ getRecordedValues NOTIFY newValuesRecorded)
    Q_PROPERTY(qint64 firstTimestamp READ getFirstTimestamp)

    Q_INVOKABLE void setRecordedValues(QJsonObject newRecordedValues);
    Q_INVOKABLE void clearCashe();

    QJsonObject getRecordedValues();
    qint64 getFirstTimestamp();

signals:
    void newValuesRecorded();

private:
    static RecorderCaching *instance;
    QJsonObject m_recordedObject;

};

#endif // RECORDERCACHING_H
