#include "qmlappstarterforwebgl.h"

QmlAppStarterForWebGL::QmlAppStarterForWebGL(QObject *parent) : QObject(parent)
{
    connect(&m_process, &QProcess::stateChanged, this, &QmlAppStarterForWebGL::processStateChanged);
    connect(&m_process, &QProcess::errorOccurred, this, &QmlAppStarterForWebGL::processErrorOccured);
}

void QmlAppStarterForWebGL::registerQML()
{
    qmlRegisterType<QmlAppStarterForWebGL>("AppStarterForWebGL", 1, 0, "AppStarterForWebGL");
}



void QmlAppStarterForWebGL::registerQMLSingleton()
{
    qmlRegisterSingletonType<QmlAppStarterForWebGL>("AppStarterForWebGLSingleton", 1, 0, "ASWGL", QmlAppStarterForWebGL::getStaticInstance);
}

QString QmlAppStarterForWebGL::applicationPath() const
{
    return m_applicationPath;
}

void QmlAppStarterForWebGL::setApplicationPath(const QString &applicationPath)
{
    if(m_applicationPath != applicationPath) {
        m_applicationPath = applicationPath;
        emit applicationPathChanged();
    }
}

QStringList QmlAppStarterForWebGL::additionalParams() const
{
    return m_additionalParams;
}

void QmlAppStarterForWebGL::setAdditionalParams(const QStringList &additionalParams)
{
    if(m_additionalParams != additionalParams) {
        m_additionalParams = additionalParams;
        emit additionalParamsChanged();
    }
}

int QmlAppStarterForWebGL::port() const
{
    return m_port;
}

void QmlAppStarterForWebGL::setPort(const int port)
{
    if(port >= 0 && port <= 65353) {
        m_port = port;
        emit portChanged();
    }
}

bool QmlAppStarterForWebGL::running() const
{
    return m_running;
}

void QmlAppStarterForWebGL::setRunning(const bool running)
{
    if(running && !m_running) {
        m_bIgnoreCrashEvent = false;
        QStringList arguments = m_additionalParams;
        // at the time of writing platform webgl is not supported on Fedora
        // to enable max debug experience: ignore params
#ifndef QT_DEBUG
        arguments.append("-platform");
        arguments.append(QStringLiteral("webgl:%1").arg(m_port));
#endif
        m_process.start(m_applicationPath, arguments);
    }
    else if (!running && m_running) {
        m_bIgnoreCrashEvent = true;
        m_process.kill();
    }
}

bool QmlAppStarterForWebGL::isServer() const
{
    return m_bisServer;
}

void QmlAppStarterForWebGL::setIsServer(const bool isServer)
{
    if(m_bisServer != isServer) {
       m_bisServer = isServer;
       emit isServerChanged();
    }
}

bool QmlAppStarterForWebGL::getSourceEnabled() const
{
    return m_enableSourceControl;
}

void QmlAppStarterForWebGL::setEnableSource(const bool enable)
{
    if(m_enableSourceControl != enable) {
        m_enableSourceControl = enable;
        emit sigEnableSourceControlChanged();
    }
}

void QmlAppStarterForWebGL::processStateChanged(QProcess::ProcessState newState)
{
    bool running = newState == QProcess::Running;
    if(running != m_running) {
        m_running = running;
        emit runningChanged();
    }
}

void QmlAppStarterForWebGL::processErrorOccured(QProcess::ProcessError error)
{
    Q_UNUSED(error) // TODO translation dance?
    if(!m_bIgnoreCrashEvent) {
        qWarning("An error occured starting application %s for webgl!", qPrintable(m_applicationPath));
    }
}

QmlAppStarterForWebGL* QmlAppStarterForWebGL::singletonInstance = nullptr;

QmlAppStarterForWebGL *QmlAppStarterForWebGL::getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
    Q_UNUSED(t_engine)
    Q_UNUSED(t_scriptEngine)
    if(!singletonInstance) {
        singletonInstance = new QmlAppStarterForWebGL();
    }
    return singletonInstance;
}

