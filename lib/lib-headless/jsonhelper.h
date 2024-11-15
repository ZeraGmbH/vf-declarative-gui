#ifndef JSONHELPER_H
#define JSONHELPER_H

#include <QJsonObject>
#include <QVariant>
#include <QObject>

class JsonHelper : public QObject
{
    Q_OBJECT
public:
    explicit JsonHelper(QObject *parent = nullptr);
    Q_INVOKABLE qint64 convertTimestampToMs(QString dateTime);
    Q_INVOKABLE QStringList getComponents(QJsonObject json, qint64 date);
    Q_INVOKABLE double getValue(QJsonObject json, qint64 date, QString component);
    Q_INVOKABLE QVariant findLastElementOfCompo(QList<QVariant> actVal, QString compoName);
};

#endif // JSONHELPER_H
