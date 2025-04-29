#ifndef AUTHORIZATIONREQUESTHANDLER_H
#define AUTHORIZATIONREQUESTHANDLER_H

#include <QObject>
#include <QVariant>

class AuthorizationRequestHandler : public QObject
{
    Q_OBJECT
public:
    explicit AuthorizationRequestHandler(QObject *parent = nullptr);

    Q_INVOKABLE QString computeHashString(const QString &input);
    Q_INVOKABLE void finishRequest(const bool& accepted, QVariant requestObject);

private:
    bool appendToJsonFile(const QString& filePath, const QJsonObject &newObject);
    const QString m_trustListPath = "/opt/websam-vein-api/authorize/trustlist.json";
};

#endif // AUTHORIZATIONREQUESTHANDLER_H
