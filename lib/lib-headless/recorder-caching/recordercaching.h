#ifndef RECORDERCACHING_H
#define RECORDERCACHING_H

#include <QJsonObject>
#include <QObject>
#include <QMap>
#include <QList>

class RecorderCaching : public QObject
{
    Q_OBJECT
public:
    explicit RecorderCaching(QObject *parent = nullptr);
    static RecorderCaching *getInstance();

    Q_PROPERTY(QJsonObject recordedValues READ getRecordedValues NOTIFY newValuesRecorded)
    Q_PROPERTY(qint64 firstTimestamp READ getFirstTimestamp)

    Q_INVOKABLE void appendRecordedValues(const QJsonObject &newRecordedValues);
    Q_INVOKABLE QJsonObject getValues(int startIdx, int endIdx);
    Q_INVOKABLE void clearCashe();

    QJsonObject getRecordedValues();
    qint64 getFirstTimestamp();
    static QString getDateTimeConvertStr();
    static QDateTime getDateTime(const QString &timeStamp);

signals:
    void newValuesRecorded();
    void sigNewValuesAdded(int startIdx, int endIdx);

private:
    static RecorderCaching *instance;

    typedef QMap<QString /*componentname*/, double /*value*/> SingleEntityData;
    typedef QMap<int /*entityId*/, SingleEntityData> EntitiesData;

    struct TimestampData {
        QDateTime timeStamp;
        EntitiesData entitiesData;
    };
    QList<TimestampData> m_cache;
};

#endif // RECORDERCACHING_H
