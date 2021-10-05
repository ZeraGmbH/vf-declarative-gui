#ifndef DECLARATIVEJSONITEM_H
#define DECLARATIVEJSONITEM_H

#include <QQmlPropertyMap>
#include <QJsonObject>

class DeclarativeJsonItem : public QQmlPropertyMap
{
    Q_OBJECT
public:
    DeclarativeJsonItem(QObject *parent = nullptr);
    Q_INVOKABLE void fromJson(const QJsonObject &jsonObject);
    Q_INVOKABLE QJsonObject toJson();
private:
    void createPropertyMapRecursive(DeclarativeJsonItem* qmlPropMap, const QJsonObject &jsonObject);
    void savePropertyMapRecursive(DeclarativeJsonItem *qmlPropMap, QJsonObject &jsonObject);
    void setJson(const QJsonObject &jsonObject);
    QJsonObject m_jsonObject;
};

#endif // DECLARATIVEJSONITEM_H
