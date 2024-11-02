#include "qmlfileio.h"
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>
#include <QDebug>
#include <QDir>
#include <QJsonObject>

QmlFileIO::QmlFileIO(QObject *parent) : QObject(parent)
{
    m_mountWatcher.create("/etc/mtab", QString(USB_STICK_PATH));
    connect(&m_mountWatcher, &vfFiles::MountWatcherEntryBase::sigMountsChanged,
            this, &QmlFileIO::onMountPathsChanged);
}

QString QmlFileIO::readTextFile(const QString &fileName)
{
    QFile textFile(fileName);
    QString retVal;
    if(checkFile(textFile) && textFile.open(QFile::ReadOnly | QFile::Text)) {
        QTextStream textStream(&textFile);
        retVal = textStream.readAll();
        textFile.close();
    }
    return retVal;
}

bool QmlFileIO::writeTextFile(const QString &fileName, const QString &content, bool overwrite, bool truncate)
{
    QFile textFile(fileName);
    bool retVal = false;
    if(textFile.exists() == false || overwrite == true) {
        bool fileIsOpen = false;
        if(truncate == true)
            fileIsOpen = textFile.open(QFile::WriteOnly);
        else
            fileIsOpen = textFile.open(QFile::Append);

        if(fileIsOpen == true) {
            retVal = true;
            QTextStream textStream(&textFile);
            textStream << content;
            textFile.close();
        }
        else
            qWarning() << "QmlFileIO: Error opening file:" << fileName << "error:" << textFile.errorString();
    }
    else
        qWarning() << "QmlFileIO: Skipped writing existing file because of missing override flag" << fileName;

    return retVal;
}

QVariant QmlFileIO::readJsonFile(const QString &fileName)
{
    QFile jsonFile(fileName);
    QVariant retVal;
    if(checkFile(jsonFile)) {
        if(jsonFile.open(QFile::ReadOnly)) {
            QJsonParseError errorObj;
            QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFile.readAll(), &errorObj);
            if(errorObj.error == QJsonParseError::NoError) {
                if(jsonDoc.isObject())
                    retVal = jsonDoc.object().toVariantMap();
                else if(jsonDoc.isArray())
                    retVal = jsonDoc.array().toVariantList();
            }
            else
                qWarning() << "QmlFileIO: Error parsing JSON file:" << fileName << "error:" << errorObj.errorString();
        }
        else
            qWarning() << "QmlFileIO: Error opening file:" << fileName << "error:" << jsonFile.errorString();
    }

    return retVal;
}

bool QmlFileIO::writeJsonFile(const QString &fileName, const QVariant &content, bool overwrite)
{
    bool retVal = false;
    QFile jsonFile(fileName);
    QJsonDocument jsonDoc;
    if(jsonFile.exists() == false || overwrite == true) {
        bool dataIsValid = false;

        if(content.type() == QVariant::Map) {
            QJsonObject jsonObj = QJsonObject::fromVariantMap(content.toMap());
            jsonDoc.setObject(jsonObj);
            dataIsValid = true;
        }
        else if(content.type() == QVariant::List) {
            QJsonArray jsonArray = QJsonArray::fromVariantList(content.toList());
            jsonDoc.setArray(jsonArray);
            dataIsValid = true;
        }
        else
            qWarning() << "QmlFileIO: Expected list or object type to write JSON document:" << fileName << "instead provided type is:" << content.typeName();

        if(jsonFile.open(QFile::WriteOnly) && dataIsValid == true) {
            jsonFile.write(jsonDoc.toJson(QJsonDocument::Indented));
            jsonFile.close();
            retVal = true;
        }
        else
            qWarning() << "QmlFileIO: Error opening file:" << fileName << "error:" << jsonFile.errorString();
    }
    else
        qWarning() << "QmlFileIO: Skipped writing existing file because of missing override flag" << fileName;

    return retVal;
}

QmlFileIO *QmlFileIO::getInstance()
{
    if(!s_instance)
        s_instance = new QmlFileIO;
    return s_instance;
}

bool QmlFileIO::checkFile(const QFile &file)
{
    bool retVal = false;
    if(file.exists()) {
        QFileInfo fInfo(file);
        const qint64 fileSize = fInfo.size();
        if(fileSize > 0 && fileSize < UINT32_MAX)  //sanity check
            retVal = true;
        else
            qWarning() << "QmlFileIO: Only files with 0 < size < 4GB are supported:" << file.fileName() << "has:" << fileSize << "bytes";
    }
    else
        qWarning() << "QmlFileIO: File can not be read:" << file.fileName();

    return retVal;
}

const QStringList &QmlFileIO::mountedPaths() const
{
    return m_mountedPaths;
}

void QmlFileIO::onMountPathsChanged(QStringList mountPaths)
{
    m_mountedPaths = mountPaths;
    emit sigMountedPathsChanged();
}

bool QmlFileIO::getWritingLogsToUsb() const
{
    return m_writingLogsToUsb;
}

bool QmlFileIO::getLastWriteLogsOk() const
{
    return m_lastWriteLogsOk;
}


bool QmlFileIO::startWriteJournalctlOnUsb(QVariant versionMap, QString serverIp)
{
    if(m_mountedPaths.size()) {
        QJsonDocument jsonDoc(QJsonObject::fromVariantMap(versionMap.toMap()));
        QByteArray jsonData = jsonDoc.toJson(QJsonDocument::Indented);
        QString jsonPath("/tmp/zenux-version.json");
        QFile jsonFile(jsonPath);
        if(jsonFile.open(QFile::WriteOnly)) {
            jsonFile.write(jsonData);
            jsonFile.close();
        }
        else
            jsonPath = ""; // service accepts empty version parameter

        m_simpleCmdIoClient = std::make_unique<SimpleCmdIoClient>(serverIp, 5000, 90000);
        connect(m_simpleCmdIoClient.get(), &SimpleCmdIoClient::sigCmdFinish,
                this, &QmlFileIO::onSimpleCmdFinish);
        QString unescapedPath = m_mountedPaths[0].replace("\\040", " ");
        QString cmd = QString("SaveLogAndDumps,%1,%2").arg(unescapedPath, jsonPath);
        m_simpleCmdIoClient->startCmd(cmd);
        m_writingLogsToUsb = true;
        emit sigWritingLogsToUsbChanged();
        return true;
    }
    return false;
}

void QmlFileIO::onSimpleCmdFinish(bool ok)
{
    if(m_lastWriteLogsOk != ok) {
        m_lastWriteLogsOk = ok;
        emit sigLastWriteLogsOkChanged();
    }
    m_writingLogsToUsb = false;
    emit sigWritingLogsToUsbChanged();
}

QmlFileIO * QmlFileIO::s_instance = nullptr;
