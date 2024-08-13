#include "jsonhelper.h"
#include <QDateTime>

JsonHelper::JsonHelper(QObject *parent)
    : QObject{parent}
{}

qint64 JsonHelper::convertTimestampToMs(QString dateTime)
{
    return QDateTime::fromString(dateTime, "dd-MM-yyyy hh:mm:ss.zzz").toMSecsSinceEpoch();
}

QStringList JsonHelper::getComponents(QJsonObject json, qint64 date)
{
    QStringList componentList;
    QString strDateTime = QDateTime::fromMSecsSinceEpoch(date).toString("dd-MM-yyyy hh:mm:ss.zzz");
    if(!json.isEmpty()) {
        QJsonObject dataWithoutTime = json.value(strDateTime).toObject();
        QStringList list = dataWithoutTime.keys();
        for (const QString &entity : list) {
            QJsonObject components = dataWithoutTime[entity].toObject();
            componentList.append(components.keys());
        }
    }
    return componentList;
}

QString JsonHelper::getValue(QJsonObject json, qint64 date, QString component)
{
    QString value;
    QString strDateTime = QDateTime::fromMSecsSinceEpoch(date).toString("dd-MM-yyyy hh:mm:ss.zzz");
    if(!json.isEmpty()) {
        QJsonObject dataWithoutTime = json.value(strDateTime).toObject();
        for (const QString &entity : dataWithoutTime.keys()) {
            QJsonObject components = dataWithoutTime[entity].toObject();
            for(const QString componentName : components.keys()) {
                if(component == componentName)
                    value = components[component].toString();
            }
        }
    }
    return value;
}

QVariant JsonHelper::findLastElementOfCompo(QList<QVariant> actVal, QString compoName)
{
    if(!actVal.isEmpty()) {
        for(auto iter = actVal.cend()-1; iter != actVal.cbegin(); --iter) {
            QVariantMap map = iter->toMap();
            if(map.value("y") == compoName)
                return map.value("x");
        }
    }
    return "0";
}
