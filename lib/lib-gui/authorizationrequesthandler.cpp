#include "authorizationrequesthandler.h"
#include <qcryptographichash.h>
#include <qdebug.h>
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
        appendToJsonFile(requestObject);
    }
}

void AuthorizationRequestHandler::appendToJsonFile(const QJsonObject &newObject)
{
    QJsonDocument doc;
    QFile file;
    QJsonArray array;

    if(!readFromJsonFile(file, doc, array)) return;

    array.append(newObject);

    writeToJsonFile(file, doc, array);
}

void AuthorizationRequestHandler::writeToJsonFile(QFile &file, QJsonDocument &doc, QJsonArray& array)
{
    // Write back to file
    file.resize(0); // Clear existing content
    doc.setArray(array);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
}

bool AuthorizationRequestHandler::readFromJsonFile(QFile &file, QJsonDocument &doc, QJsonArray& array)
{
    if(!filePreparation())
        qWarning("Error in file preparation");

    // Read existing JSON array
    file.setFileName(m_trustListPath);
    if (!file.open(QIODevice::ReadWrite)) {
        qWarning("Error reading trust file.");
        return false;
    }

    QByteArray jsonData = file.readAll();
    QJsonParseError parseError;

    doc = QJsonDocument::fromJson(jsonData, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return false;
    }

    // Get or create array
    if (!doc.isArray()) {
        // Handle case where file contains non-array data
        qWarning() << "File does not contain a JSON array";
        return false;
    }

    array = doc.array();

    return true;
}

void AuthorizationRequestHandler::deleteFromJsonFile(const QJsonObject &trust)
{
    QJsonDocument doc;
    QFile file;
    QJsonArray array;

    if(!readFromJsonFile(file, doc, array)) return;

    for(int i = array.size(); i-- > 0; )
        if(array[i] == trust)
            array.removeAt(i);

    writeToJsonFile(file, doc, array);
}

bool AuthorizationRequestHandler::filePreparation()
{
    QFile file(m_trustListPath);
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

void AuthorizationRequestHandler::deleteTrust(QJsonObject trust){
    deleteFromJsonFile(trust);
}
