#include "qmlappstarterforwebserver.h"

QmlAppStarterForWebserver::QmlAppStarterForWebserver(QObject *parent) : QObject(parent)
{
// ??? connect(&m_process, &QProcess::stateChanged, this, &QmlAppStarterForWebGL::processStateChanged);
//    connect(&m_process, &QProcess::errorOccurred, this, &QmlAppStarterForWebGL::processErrorOccured);
}


void QmlAppStarterForWebserver::registerQML()
{
    qmlRegisterType<QmlAppStarterForWebserver>("AppStarterForWebserver", 1, 0, "AppStarterForWebserver");
}

void QmlAppStarterForWebserver::registerQMLSingleton()
{
    // ASWS -> App Starter Web Server
    qmlRegisterSingletonType<QmlAppStarterForWebserver>("AppStarterForWebserverSingleton", 1, 0, "ASWS", QmlAppStarterForWebserver::getStaticInstance);
}


bool QmlAppStarterForWebserver::getRunning()
{
    return m_running;
}


int QmlAppStarterForWebserver::getPort()
{
    return m_port;
}

void QmlAppStarterForWebserver::setRunning(bool run)
{
    if (run && !m_running) {
        qWarning("Start Webserver");
        QStringList arguments = QStringList() << "-D" << "-f" << "/etc/lighttpd/lighttpd.conf";   // -d = do not daemonize
        m_process.start("lighttpd", arguments);
        m_running = true;
        emit runningChanged();  // wofür ???
    }
    else if (run && m_running)
        qWarning("Webserver is running, no restart possible");

    else if (!run && m_running) {
        qWarning("Stop Webserver");
        m_bIgnoreCrashEvent = true;
        m_process.kill();
        m_running = false;
        emit runningChanged();
    }
}

QmlAppStarterForWebserver* QmlAppStarterForWebserver::singletonInstance = nullptr;

QmlAppStarterForWebserver *QmlAppStarterForWebserver::getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
    Q_UNUSED(t_engine)
    Q_UNUSED(t_scriptEngine)
    if(!singletonInstance) {
        singletonInstance = new QmlAppStarterForWebserver();
    }
    return singletonInstance;
}
