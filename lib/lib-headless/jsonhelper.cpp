#include "jsonhelper.h"
#include <QDateTime>

JsonHelper::JsonHelper(QObject *parent)
    : QObject{parent}
{
}

qint64 JsonHelper::convertTimestampToMs(QString dateTime)
{
    return QDateTime::fromString(dateTime, "dd-MM-yyyy hh:mm:ss.zzz").toMSecsSinceEpoch();
}

QStringList JsonHelper::getComponents(QJsonObject json)
{
    QStringList componentList;
    if(!json.isEmpty()) {
        const QStringList entities = json.keys();
        for (const QString &entity : entities) {
            QJsonObject components = json[entity].toObject();
            componentList.append(components.keys());
        }
    }
    return componentList;
}

double JsonHelper::getValue(QJsonObject json, QString component)
{
    double value = 0.0;
    if(!json.isEmpty()) {
        const QStringList entities = json.keys();
        for (const QString &entity : entities) {
            QJsonObject components = json[entity].toObject();
            const QStringList componentNames = components.keys();
            for(const QString &componentName : componentNames) {
                if(component == componentName)
                    value = components[component].toDouble();
            }
        }
    }
    return value;
}

QVariant JsonHelper::findLastElementOfCompo(QList<QVariant> actVal, QString compoName)
{
    if(!actVal.isEmpty()) {
        for(int i = 0; i < actVal.size(); i++) {
            QVariantMap map = actVal[i].toMap();
            if(map.value("y") == compoName)
                return map.value("x");
        }
    }
    return "0";
}
