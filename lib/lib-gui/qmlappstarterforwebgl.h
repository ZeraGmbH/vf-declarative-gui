#ifndef QMLAPPSTARTERFORWEBGL_H
#define QMLAPPSTARTERFORWEBGL_H

#include <QObject>
#include <QProcess>
#include <QQuickItem>

class QmlAppStarterForWebGL : public QObject
{
    Q_OBJECT
public:
    explicit QmlAppStarterForWebGL(QObject *parent = nullptr);

    static void registerQML();
    static void registerQMLSingleton();
    static QmlAppStarterForWebGL *getStaticInstance(QQmlEngine *t_engine=nullptr, QJSEngine *t_scriptEngine=nullptr);

    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(bool isServer READ isServer NOTIFY isServerChanged)
    Q_PROPERTY(bool sourceEnabled READ getSourceEnabled NOTIFY sigEnableSourceControlChanged)

    int port() const;
    void setPort(const int port);

    bool running() const;
    void setRunning(const bool running);

    bool isServer() const;
    void setIsServer(const bool isServer);

    bool getSourceEnabled() const;
    void setEnableSource(const bool enable);
signals:
    void portChanged();
    void runningChanged();
    void isServerChanged();
    void sigEnableSourceControlChanged();
private slots:
    void processStateChanged(QProcess::ProcessState newState);
    void processErrorOccured(QProcess::ProcessError error);

private:
    int m_port = 8080;
    bool m_running = false;
    bool m_bisServer = false;
    bool m_enableSourceControl = false;

    bool m_bIgnoreCrashEvent = false;
    QProcess m_process;
    static QmlAppStarterForWebGL* singletonInstance;
};

#endif // QMLAPPSTARTERFORWEBGL_H
