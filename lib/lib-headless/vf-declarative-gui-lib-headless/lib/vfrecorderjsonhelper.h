#ifndef VFRECORDERJSONHELPER_H
#define VFRECORDERJSONHELPER_H

#include <QJsonObject>
#include <QVariant>
#include <QObject>

class VfRecorderJsonHelper : public QObject
{
    Q_OBJECT
public:
    explicit VfRecorderJsonHelper(QObject *parent = nullptr);
    Q_INVOKABLE qint64 convertTimestampToMs(const QString &dateTime);
    Q_INVOKABLE QStringList getComponents(QJsonObject json);
    Q_INVOKABLE double getValue(QJsonObject json, const QString &component);
    Q_INVOKABLE QVariant findLastElementOfCompo(const QList<QVariant> &actVal, const QString &compoName);
};

#endif // VFRECORDERJSONHELPER_H
