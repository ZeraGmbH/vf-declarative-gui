#include "authorizationrequesthandler.h"
#include <qcryptographichash.h>
#include <qdebug.h>
#include <qfileinfo.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qjsonobject.h>

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

void AuthorizationRequestHandler::finishRequest(const bool &accepted, QVariant requestObject)
{
    if(accepted) {
        appendToJsonFile(m_trustListPath, requestObject.toJsonObject());
    }
}

bool AuthorizationRequestHandler::appendToJsonFile(const QString &filePath, const QJsonObject &newObject)
{
    // 1. Read existing JSON array
    QFile file(filePath);
    if (!file.open(QIODevice::ReadWrite)) {
        qWarning() << "Failed to open file:" << file.errorString();
        return false;
    }

    QByteArray jsonData = file.readAll();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return false;
    }

    // 2. Get or create array
    QJsonArray array;
    if (doc.isArray()) {
        array = doc.array();
    } else {
        // Handle case where file contains non-array data
        qWarning() << "File does not contain a JSON array";
        return false;
    }

    // 3. Append new object
    array.append(newObject);

    // 4. Write back to file
    file.resize(0); // Clear existing content
    doc.setArray(array);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();

    return true;
}
