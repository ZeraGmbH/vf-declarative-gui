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

QString AuthorizationRequestHandler::computeHashString(const QString &type, const QString &input)
{
    QString hexDump;

    if(type == "Basic") {
        // Token is <user>:<hash of password> and we only show the user part.
        int split = input.indexOf(':');

        if(split >= 0)
            return input.left(split);
    }
    else if(type == "PublicKey") {
        // Token is a RSA public key PEM, WinSAM will display start and end of its SHA256 hash.
        QByteArray hash = QCryptographicHash::hash(input.toUtf8(), QCryptographicHash::Sha256);
        QString hashHex(hash.toHex());

        // Just clip off to simplify comparision by the end user.
        hexDump = hashHex.left(16) + hashHex.right(16);
    }
    else if(type == "Certificate" && (input.size() > 32) && (input.size() % 2) == 0) {
        // Token is a X509 cerificate hash as a sequence of hex numbers - again clip for readability.
        hexDump = input.left(16) + input.right(16);
    }

    if(hexDump.isEmpty())
        return type + "?";

    // Insert colons every 2 characters
    QString formatted;

    for (int i = 0; i < hexDump.size(); i += 2) {
        if (!formatted.isEmpty())
            formatted += ":";

        // WebSAM will lowercase as well so to help the end user a bit in comparison make this as well in the ZENUX UI.
        formatted += hexDump.mid(i, 2).toLower();
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
