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
    Q_INVOKABLE qint64 convertTimestampToMs(QString dateTime);
    Q_INVOKABLE QStringList getComponents(QJsonObject json);
    Q_INVOKABLE double getValue(QJsonObject json, QString component);
    Q_INVOKABLE QVariant findLastElementOfCompo(QList<QVariant> actVal, QString compoName);
};

#endif // VFRECORDERJSONHELPER_H
