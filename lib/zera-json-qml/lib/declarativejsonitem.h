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

    Q_PROPERTY(int changedValueCount READ changedValueCount NOTIFY notifyQMLChangedValueCount)
    const int &changedValueCount();

signals:
    void notifyQMLChangedValueCount();

private slots:
    void onChildChangedValue(const QString &key, const QVariant &value);

protected:
    virtual QVariant updateValue(const QString &key, const QVariant &input) override;

private:
    void createPropertyMapRecursive(DeclarativeJsonItem* qmlPropMap, const QJsonObject &jsonObject);
    void savePropertyMapRecursive(DeclarativeJsonItem *qmlPropMap, QJsonObject &jsonObject);
    void childChangedObject();
    void setJson(const QJsonObject &jsonObject);

    QJsonObject m_jsonObject;
    int m_changeValueCount = 0;
};

#endif // DECLARATIVEJSONITEM_H
