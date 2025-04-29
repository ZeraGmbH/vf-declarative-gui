#ifndef AUTHORIZATIONREQUESTHANDLER_H
#define AUTHORIZATIONREQUESTHANDLER_H

#include <QObject>

class AuthorizationRequestHandler : public QObject
{
    Q_OBJECT
public:
    explicit AuthorizationRequestHandler(QObject *parent = nullptr);

    Q_INVOKABLE QString computeHashString(const QString &input);
};

#endif // AUTHORIZATIONREQUESTHANDLER_H
