#include "declarativejsonitem.h"

DeclarativeJsonItem::DeclarativeJsonItem(QObject *parent) :
    QQmlPropertyMap(this, parent)
{

}


void DeclarativeJsonItem::fromJson(const QJsonObject &jsonObject)
{
    m_jsonObject = jsonObject;
    createPropertyMapRecursive(this, m_jsonObject);
}

QJsonObject DeclarativeJsonItem::toJson()
{
    savePropertyMapRecursive(this, m_jsonObject);
    return m_jsonObject;
}

QVariant DeclarativeJsonItem::updateValue(const QString &key, const QVariant &input)
{
    QVariant oldValue = value(key);
    if(oldValue.toJsonValue().type() != input.toJsonValue().type()) {
        qCritical("Trying to change JSON type of %s", qPrintable(key));
        return oldValue;
    }
    return input;
}

void DeclarativeJsonItem::createPropertyMapRecursive(DeclarativeJsonItem *qmlPropMap, const QJsonObject &jsonObject)
{
    for(QJsonObject::const_iterator iter=jsonObject.begin(); iter!=jsonObject.constEnd(); ++iter) {
        if(iter->isObject()) {
            // json sub
            QJsonObject subJsonObj(jsonObject.value(iter.key()).toObject());
            // qml map sub
            DeclarativeJsonItem* subQmlMap;
            if(!qmlPropMap->contains(iter.key())) { // we're here first time
                subQmlMap = new DeclarativeJsonItem(qmlPropMap);
                subQmlMap->setJson(subJsonObj); // make toJson work on sub qml
                qmlPropMap->insert(iter.key(), QVariant::fromValue(subQmlMap));
            }
            else {
                QVariant &subVariant = (*qmlPropMap)[iter.key()];
                subQmlMap = subVariant.value<DeclarativeJsonItem*>();
            }
            createPropertyMapRecursive(subQmlMap, subJsonObj);
        }
        else if(iter->isArray()) { // TODO?
            qWarning("createPropertyMapRecursive: JSON arrays are not supported (yet?)");
        }
        else {
            QVariant& oldValue = (*qmlPropMap)[iter.key()];
            if(oldValue.type() != QVariant::Invalid) {
                QVariant convertedNewVal = iter.value().toVariant();
                if(convertedNewVal.convert(oldValue.type())) {
                    if(convertedNewVal != oldValue) {
                        qmlPropMap->insert(iter.key(), convertedNewVal);
                    }
                }
                else {
                    qWarning("createPropertyMapRecursive: Datatype mismatch key %s", qPrintable(iter.key()));
                }
            }
            else {
                qmlPropMap->insert(iter.key(), iter.value().toVariant());
            }
        }
    }
}

void DeclarativeJsonItem::savePropertyMapRecursive(DeclarativeJsonItem *qmlPropMap, QJsonObject &jsonObject)
{
    for(QJsonObject::iterator iter=jsonObject.begin(); iter!=jsonObject.constEnd(); ++iter) {
        if(iter->isObject()) {
            // json sub
            QJsonObject subJsonObj(jsonObject.value(iter.key()).toObject());
            // qml map sub
            DeclarativeJsonItem* subQmlMap;
            if(!qmlPropMap->contains(iter.key())) { // we're here first time
                qWarning("Key %s not found in qml property map - was createPropertyMapRecursive run?", qPrintable(iter.key()));
                return;
            }
            else {
                QVariant &subVariant = (*qmlPropMap)[iter.key()];
                subQmlMap = subVariant.value<DeclarativeJsonItem*>();
            }
            savePropertyMapRecursive(subQmlMap, subJsonObj);
            jsonObject[iter.key()] = subJsonObj;
            subQmlMap->setJson(subJsonObj); // make toJson work on sub qml
        }
        else if(iter->isArray()) { // TODO?
            qWarning("savePropertyMapRecursive: JSON arrays are not supported (yet?)");
        }
        else {
            QVariant jsonOldVal = iter.value().toVariant();
            QVariant qmlNewValue = (*qmlPropMap)[iter.key()];
            if(qmlNewValue.convert(jsonOldVal.type())) {
                if(jsonOldVal != qmlNewValue) {
                    jsonObject[iter.key()] = qmlNewValue.toJsonValue();
                }
            }
            else {
                qWarning("savePropertyMapRecursive: Datatype mismatch key %s", qPrintable(iter.key()));
            }
        }
    }
}

void DeclarativeJsonItem::setJson(const QJsonObject &jsonObject)
{
    m_jsonObject = jsonObject;
}

