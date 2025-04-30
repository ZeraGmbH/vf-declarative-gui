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

void AuthorizationRequestHandler::finishRequest(const bool &accepted, QJsonObject requestObject)
{
    if(accepted) {
        appendToJsonFile(m_trustListPath, requestObject);
    }
}

bool AuthorizationRequestHandler::appendToJsonFile(const QString &filePath, const QJsonObject &newObject)
{
    if(!filePreparation(filePath))
        qWarning("Error in file preparation");

    // Read existing JSON array
    QFile file(filePath);
    if (!file.open(QIODevice::ReadWrite)) {
        qWarning("Error reading trust file.");
        return false;
    }

    QByteArray jsonData = file.readAll();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return false;
    }

    // Get or create array
    QJsonArray array;
    if (doc.isArray()) {
        array = doc.array();
    } else {
        // Handle case where file contains non-array data
        qWarning() << "File does not contain a JSON array";
        return false;
    }
    array.append(newObject);

    // Write back to file
    file.resize(0); // Clear existing content
    doc.setArray(array);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();

    return true;
}

bool AuthorizationRequestHandler::filePreparation(const QString &filePath)
{
    QFile file(filePath);
    if(!file.exists()) {
        qInfo("Trust file does not exist. Try to create it.");
        if (file.open(QIODevice::ReadWrite)) {
            QTextStream out(&file);
            out << "[]\n";
            file.close();
        }
        else
        {
            qWarning() << "Failed to open file:" << file.errorString();
            return false;
        }
    }
    return true;
}
