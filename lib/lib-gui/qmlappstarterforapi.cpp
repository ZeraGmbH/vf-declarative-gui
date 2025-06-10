#include "qmlappstarterforapi.h"
#include <QFile>
#include <QTextStream>
#include <QSslCertificate>

QmlAppStarterForApi::QmlAppStarterForApi()
{
    connect(this, &QmlAppStarterForApi::initDone, this, &QmlAppStarterForApi::startApiProcess);
}

void QmlAppStarterForApi::registerQMLSingleton()
{
    // ASAPI
    qmlRegisterSingletonType<QmlAppStarterForApi>("AppStarterForApi", 1, 0, "ASAPI", QmlAppStarterForApi::getStaticInstance);
}

QmlAppStarterForApi* QmlAppStarterForApi::singletonInstance = nullptr;

QmlAppStarterForApi *QmlAppStarterForApi::getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
    Q_UNUSED(t_engine)
    Q_UNUSED(t_scriptEngine)
    if(!singletonInstance)
        singletonInstance = new QmlAppStarterForApi();
    return singletonInstance;
}

bool QmlAppStarterForApi::getRunning()
{
    return m_running;
}

void QmlAppStarterForApi::setRunning(bool running)
{
    if(running && !m_running) {
        qWarning("Start API access");
        startProcedure();
    }
    else if(!running && m_running) {
        qWarning("Stop API Access");
        #ifndef QT_DEBUG
        m_apiProcess.kill();
        #endif
        m_running = false;
        emit runningChanged();
    }
}

int QmlAppStarterForApi::getPort()
{
    return m_port;
}

void QmlAppStarterForApi::startProcedure()
{
#ifndef QT_DEBUG
    if(!QFile::exists(m_apiBinaryPath + "https.crt.pem") || !QFile::exists(m_apiBinaryPath + "https.prv.pem"))
    {
        QString hostname;
        QFile hostnameFile("/etc/hostname");
        if (hostnameFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&hostnameFile);
            hostname = in.readAll().trimmed();
            hostnameFile.close();
        }else{
            qWarning("Could not read hostname!");
            return;
        }

        connect(&m_certProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [&](int exitCode, QProcess::ExitStatus exitStatus) {
            Q_UNUSED(exitStatus)
            if (exitCode == 0)
                emit initDone();
            else
                qWarning("Certificates could not be created.");
        });
        QStringList arguments = QStringList() << "req" << "-x509" << "-newkey" << "rsa:2048"
                                              << "-keyout" << m_apiBinaryPath + "https.prv.pem"
                                              << "-out" << m_apiBinaryPath + "https.crt.pem"
                                              << "-sha256" << "-days" << "15000" << "-nodes" << "-subj"
                                              << "/C=DE/ST=North Rhine-Westphalia/L=Koenigswinter/O=Zera GmbH/OU=Software Development/CN=" + hostname + ".local"
                                              << "-addext" << "subjectAltName = DNS:" + hostname + ".local";
        m_certProcess.start("openssl", arguments);
    }
    else
#endif
        emit initDone();

}

void QmlAppStarterForApi::startApiProcess()
{
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("ASPNETCORE_HTTPS_PORTS", "8083");
    m_apiProcess.setProcessEnvironment(env);
    m_apiProcess.setWorkingDirectory(m_apiBinaryPath);
#ifndef QT_DEBUG
    m_apiProcess.start("VeinDevices");
#endif
    m_running = true;
    emit runningChanged();
}

QString QmlAppStarterForApi::calculateThumbnail(const QString &def){
    QString crtPath = m_apiBinaryPath + "https.crt.pem";

    QFile file(crtPath);

    if (!file.open(QIODevice::ReadOnly))
        return def;

    QByteArray pem = file.readAll();

    file.close();

    QSslCertificate cert(pem);
    QString digest(cert.digest(QCryptographicHash::Sha1).toHex());

    QString hash;

    for(int i = 0; i < digest.length(); i += 2)
        hash += ":" + digest.mid(i, 2);

    return hash.mid(1);
}
