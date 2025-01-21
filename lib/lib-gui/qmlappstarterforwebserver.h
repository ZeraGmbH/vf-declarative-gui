#ifndef QMLAPPSTARTERFORWEBSERVER_H
#define QMLAPPSTARTERFORWEBSERVER_H

#include <QObject>
#include <QProcess>
#include <QQuickItem>


class QmlAppStarterForWebserver : public QObject
{
    Q_OBJECT
public:
    explicit QmlAppStarterForWebserver(QObject *parent = nullptr);
    static void registerQML();
    static void registerQMLSingleton();
    static QmlAppStarterForWebserver *getStaticInstance(QQmlEngine *t_engine=nullptr, QJSEngine *t_scriptEngine=nullptr);

    Q_PROPERTY(bool running READ getRunning WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(int port READ getPort CONSTANT)

    bool getRunning();
    void setRunning (bool running);
    int getPort();

signals:
    void runningChanged();

private slots:
//    void processStateChanged(QProcess::ProcessState newState);

private:
    int m_port = 8081;
    bool m_running = false;
    bool m_bIgnoreCrashEvent = false;
    QProcess m_process;
    static QmlAppStarterForWebserver* singletonInstance;
};

#endif // QMLAPPSTARTERFORWEBSERVER_H

