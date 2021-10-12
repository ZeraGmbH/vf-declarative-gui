#include "declarativejsonitem.h"
#include <QObject>

DeclarativeJsonItem::DeclarativeJsonItem(QObject *parent) :
    QQmlPropertyMap(this, parent)
{
    connect(this, &DeclarativeJsonItem::valueChanged, this, &DeclarativeJsonItem::onChildChangedValue);
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

const int &DeclarativeJsonItem::changedValueCount()
{
    return m_changeValueCount;
}

void DeclarativeJsonItem::onChildChangedValue(const QString &key, const QVariant &value)
{
    Q_UNUSED(key)
    Q_UNUSED(value)
    // Consider object changed as soon as child values change
    childChangedObject();
}

void DeclarativeJsonItem::childChangedObject()
{
    ++m_changeValueCount;
    emit notifyQMLChangedValueCount(); // QML property notification
    DeclarativeJsonItem* my_parent = qobject_cast<DeclarativeJsonItem*>(parent());
    if(my_parent) {
        my_parent->childChangedObject();
    }
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
            if(oldValue.type() != QVariant::Invalid) { // re-create?
                QVariant convertedNewVal = iter.value().toVariant();
                if(convertedNewVal.convert(oldValue.type())) {
                    if(convertedNewVal != oldValue) {
                        qmlPropMap->insert(iter.key(), convertedNewVal);
                        // QQmlPropertyMap takes care for the QML side of but does not
                        // emit valueChanged, if C++ side changes values. To keep our
                        // change count up to date we have to take care ourselves
                        qmlPropMap->childChangedObject();
                    }
                }
                else {
                    qCritical("createPropertyMapRecursive: Datatype mismatch key %s", qPrintable(iter.key()));
                }
            }
            else { // 1st create
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
                qCritical("savePropertyMapRecursive: Datatype mismatch key %s", qPrintable(iter.key()));
            }
        }
    }
}

void DeclarativeJsonItem::setJson(const QJsonObject &jsonObject)
{
    m_jsonObject = jsonObject;
}
