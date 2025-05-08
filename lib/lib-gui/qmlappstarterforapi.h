#ifndef QMLAPPSTARTERFORAPI_H
#define QMLAPPSTARTERFORAPI_H

#include <QObject>
#include <QProcess>
#include <qqmlengine.h>


class QmlAppStarterForApi : public QObject
{
    Q_OBJECT
public:
    explicit QmlAppStarterForApi();
    static void registerQMLSingleton();
    static QmlAppStarterForApi *getStaticInstance(QQmlEngine *t_engine=nullptr, QJSEngine *t_scriptEngine=nullptr);

    Q_PROPERTY(bool running READ getRunning WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(int port READ getPort CONSTANT)

    Q_INVOKABLE QString calculateThumbnail();

    bool getRunning();
    void setRunning(bool running);
    int getPort();

signals:
    void runningChanged();
    void initDone();
    void certificateCreationDone();

private:
    void startProcedure();

    QString m_apiBinaryPath = "/opt/websam-vein-api/";
    int m_port = 8083;
    bool m_running = false;
    QProcess m_apiProcess;
    QProcess m_certProcess;
    static QmlAppStarterForApi* singletonInstance;

private slots:
    void startApiProcess();
};

#endif // QMLAPPSTARTERFORAPI_H
