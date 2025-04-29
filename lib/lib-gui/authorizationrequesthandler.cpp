#include "authorizationrequesthandler.h"
#include <qcryptographichash.h>

AuthorizationRequestHandler::AuthorizationRequestHandler(QObject *parent)
    : QObject{parent}
{}

QString AuthorizationRequestHandler::computeHashString(const QString &input)
{
    QByteArray hash = QCryptographicHash::hash(input.toUtf8(), QCryptographicHash::Sha256);
    QString hashHex(hash.toHex());
    QString shortened = hashHex.left(16) + hashHex.right(16);

    // Insert colons every 2 characters
    QString formatted;
    for (int i = 0; i < shortened.size(); i += 2) {
        if (!formatted.isEmpty()) {
            formatted += ":";
        }
        formatted += shortened.mid(i, 2);
    }
    return formatted;
}
