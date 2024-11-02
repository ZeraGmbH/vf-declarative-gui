#include "jsonsettingsfile.h"
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QStandardPaths>
#include <QDebug>
#include <QSaveFile>
#include <QFileInfo>
#include <QTimer>

class JsonSettingsFilePrivate {

    JsonSettingsFilePrivate(JsonSettingsFile *t_qPtr) : q_ptr(t_qPtr) {}

    JsonSettingsFile *q_ptr;
    QString m_settingsFilePath;

    QJsonObject m_dataHolder;

    QTimer m_transactionTimer;
    bool m_autoWriteBackEnabled=false;

    Q_DECLARE_PUBLIC(JsonSettingsFile)
};

JsonSettingsFile::JsonSettingsFile(QObject *t_parent) :
    QObject(t_parent),
    d_ptr(new JsonSettingsFilePrivate(this))
{
    d_ptr->m_transactionTimer.setSingleShot(false);

    // to avoid save storms when multiple options are saved in short time
    // (e.g on first start setting all defaults) we (re)start a timer
    connect(this,&JsonSettingsFile::settingsSaveRequest,[this]() {
        if(d_ptr->m_autoWriteBackEnabled) {
            d_ptr->m_transactionTimer.start(500);
        }
    });
    connect(&d_ptr->m_transactionTimer,&QTimer::timeout,[this]() {
        if(d_ptr->m_autoWriteBackEnabled) {
            d_ptr->m_transactionTimer.stop();
            saveToFile(getCurrentFilePath(), true);
        }
    });
}

JsonSettingsFile *JsonSettingsFile::s_globalSettings = nullptr;

JsonSettingsFile *JsonSettingsFile::getInstance()
{
    if(s_globalSettings == nullptr) {
        s_globalSettings = new JsonSettingsFile();
    }
    return s_globalSettings;
}

bool JsonSettingsFile::loadFromStandardLocation(const QString &fileName)
{
    return loadFromFile(QString("%1/%2").arg(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)).arg(fileName));
}

bool JsonSettingsFile::loadFromFile(const QString &t_filePath)
{
    Q_D(JsonSettingsFile);
    bool retVal = false;
    QFile settingsFile;
    settingsFile.setFileName(t_filePath);
    if(settingsFile.exists() && settingsFile.open(QFile::ReadOnly)) {
        d->m_settingsFilePath = t_filePath;
        QJsonParseError err;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(settingsFile.readAll(), &err);
        if(err.error == QJsonParseError::NoError) {
            d->m_dataHolder = jsonDoc.object();
            retVal = true;
        }
        else
            qWarning() << "Error reading settings file:" << err.errorString();
        settingsFile.close();
    }
    else
        qWarning() << "Settings file does not exists:" << t_filePath;
    return retVal;
}

void JsonSettingsFile::saveToFile(const QString &t_filePath, bool t_overwrite)
{
    Q_D(JsonSettingsFile);
    QFileInfo fInfo;
    QSaveFile settingsFile;
    fInfo.setFile(t_filePath);
    settingsFile.setFileName(t_filePath);
    if((t_filePath.isEmpty() == false) && (!fInfo.exists() || t_overwrite) && settingsFile.open(QFile::WriteOnly)) {
        QJsonDocument jsonDoc;
        jsonDoc.setObject(d->m_dataHolder);
        settingsFile.write(jsonDoc.toJson());
        settingsFile.commit();
    }
}

QString JsonSettingsFile::getCurrentFilePath()
{
    Q_D(JsonSettingsFile);
    return d->m_settingsFilePath;
}

bool JsonSettingsFile::hasOption(const QString &key)
{
    Q_D(JsonSettingsFile);
    bool retVal=false;
    if(d->m_dataHolder.value(key) != QJsonValue::Undefined)
        retVal = true;
    return retVal;
}

QString JsonSettingsFile::getOption(const QString &key, const QString &valueDefault)
{
    Q_D(JsonSettingsFile);
    QString retVal;
    if(hasOption(key))
        retVal = d->m_dataHolder.value(key).toString();
    else {
        if(d->m_settingsFilePath.isEmpty() == false) {
            d->m_dataHolder.insert(key, valueDefault);
            emit settingsSaveRequest(this);
            retVal = valueDefault;
        }
    }
    return retVal;
}

bool JsonSettingsFile::setOption(const QString &key, const QString &value)
{
    Q_D(JsonSettingsFile);
    bool retVal = false;
    if(!hasOption(key) || d->m_dataHolder.value(key).toString() != value) {
        d->m_dataHolder.insert(key, value);
        retVal=true;
        emit settingsSaveRequest(this);
    }
    return retVal;
}

void JsonSettingsFile::setAutoWriteBackEnabled(bool autoWriteBackEnabled)
{
    if(d_ptr->m_autoWriteBackEnabled != autoWriteBackEnabled)
        d_ptr->m_autoWriteBackEnabled=autoWriteBackEnabled;
}
