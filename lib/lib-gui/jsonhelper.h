#ifndef JSONHELPER_H
#define JSONHELPER_H

#include <QJsonObject>
#include <QObject>

class JsonHelper : public QObject
{
    Q_OBJECT
public:
    explicit JsonHelper(QObject *parent = nullptr);
    Q_INVOKABLE qint64 convertTimestampToMs(QString dateTime);
    Q_INVOKABLE QStringList getComponents(QJsonObject json, qint64 date);
    Q_INVOKABLE QString getValue(QJsonObject json, qint64 date, QString component);
};

#endif // JSONHELPER_H
