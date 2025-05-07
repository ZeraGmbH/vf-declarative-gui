#ifndef AUTHORIZATIONREQUESTHANDLER_H
#define AUTHORIZATIONREQUESTHANDLER_H

#include <QObject>
#include <QVariant>
#include <QJsonObject>
#include <QFile>

class AuthorizationRequestHandler : public QObject
{
    Q_OBJECT
public:
    explicit AuthorizationRequestHandler(QObject *parent = nullptr);

    Q_INVOKABLE QString computeHashString(const QString &type, const QString &input);
    Q_INVOKABLE void finishRequest(const bool& accepted, QJsonObject requestObject);
    Q_INVOKABLE void deleteTrust(QJsonObject trust);

private:
    bool readFromJsonFile(QFile &file, QJsonDocument &doc, QJsonArray& array);
    void writeToJsonFile(QFile &file, QJsonDocument &doc, QJsonArray& array);
    void appendToJsonFile(const QJsonObject &newObject);
    void deleteFromJsonFile(const QJsonObject &trust);
    bool filePreparation();

    const QString m_trustListPath = "/opt/websam-vein-api/authorize/trustlist.json";
};

#endif // AUTHORIZATIONREQUESTHANDLER_H
