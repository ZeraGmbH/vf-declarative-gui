#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QIcon>
#include <QStandardPaths>
#include <QDir>
#include <QCommandLineParser>
#include <ve_eventhandler.h>
#include <vn_networksystem.h>
#include <vn_tcpsystem.h>
#include <vn_networkstatusevent.h>
#include <veinqml.h>
#include <veinqmlwrapper.h>
#include "zeragluelogic.h"
#include "gluelogicpropertymap.h"
#include <zeratranslationplugin.h>
#include "jsonsettingsfile.h"
#include "qmlfileio.h"
#include "qmlappstarterforwebgl.h"
#include <zvkeyboard.h>

int main(int argc, char *argv[])
{
    //qputenv("QSG_RENDER_LOOP", QByteArray("threaded")); //threaded opengl rendering
    //qputenv("QMLSCENE_DEVICE", QByteArray("softwarecontext")); //software renderer

    // We need to pin virtual keyboard on - otherwise Qml complains for unknown
    // Type 'InputPanel'
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard")); //virtual keyboard

    ZVKeyboard::setKeyboardLayoutEnvironment();

    const bool hasQtVirtualKeyboard = (qgetenv("QT_IM_MODULE") == QByteArray("qtvirtualkeyboard"));

    QLocale locale = QLocale("C");
    locale.setNumberOptions(QLocale::OmitGroupSeparator | QLocale::RejectGroupSeparator);
    QLocale::setDefault(locale);

    QStringList loggingFilters = QStringList() << QString("%1.debug=false").arg(VEIN_EVENT().categoryName()) <<
                                                  QString("%1.debug=false").arg(VEIN_NET_VERBOSE().categoryName()) <<
                                                  QString("%1.debug=false").arg(VEIN_NET_INTRO_VERBOSE().categoryName()) << //< Introspection logging is still enabled
                                                  QString("%1.debug=false").arg(VEIN_NET_TCP_VERBOSE().categoryName()) <<
                                                  QString("%1.debug=false").arg(VEIN_API_QML_INTROSPECTION().categoryName()) <<
                                                  QString("%1.debug=false").arg(VEIN_API_QML_VERBOSE().categoryName());// << "qt.qml.binding.removal.info=true"; //debug binding overrides

    QLoggingCategory::setFilterRules(loggingFilters.join("\n"));

    bool loadedOnce = false;
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    // dependencies
    ZeraTranslationPlugin::registerQml();
    // internal
    qmlRegisterSingletonType<GlueLogicPropertyMap>("ZeraGlueLogic", 1, 0, "ZGL", GlueLogicPropertyMap::getStaticInstance);
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/ModuleIntrospection.qml"), "ModuleIntrospection", 1, 0, "ModuleIntrospection");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/GlobalConfig.qml"), "GlobalConfig", 1, 0, "GC");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/FunctionTools.qml"), "FunctionTools", 1, 0, "FT");

    // WebGL server
    QCommandLineParser parser;
    QCommandLineOption webGlServerOption(QStringList() << "w" << "webgl-server", "1: Start as webGL server", "1/0");
    webGlServerOption.setDefaultValue("0");
    parser.addOption(webGlServerOption);
    parser.process(app);
    bool webGlServer = parser.isSet(webGlServerOption);
    QmlAppStarterForWebGL *pWGLSingleon = QmlAppStarterForWebGL::getStaticInstance();
    pWGLSingleon->setIsServer(webGlServer);
    QmlAppStarterForWebGL::registerQMLSingleton();

    app.setWindowIcon(QIcon(":/data/staticdata/resources/appicon.png"));

    QmlFileIO::setStaticInstance(new QmlFileIO(&app));

    GlueLogicPropertyMap *glueLogicMap = new GlueLogicPropertyMap(&app);
    GlueLogicPropertyMap::setStaticInstance(glueLogicMap);

    QQmlApplicationEngine engine;
    QTimer networkWatchdog;
    networkWatchdog.setInterval(3000);
    networkWatchdog.setSingleShot(true);

    JsonSettingsFile *globalSettingsFile = JsonSettingsFile::getInstance();
    globalSettingsFile->setAutoWriteBackEnabled(true);

    // Load settings
    QString settingsFile = QStringLiteral("settings.json");
    if(webGlServer) {
        settingsFile = QStringLiteral("settings-remote.json");
    }
    if(globalSettingsFile->loadFromStandardLocation(settingsFile) == false) {
        const QString standardPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        const QString targetPath = QString("%1/%2").arg(standardPath).arg(settingsFile);
        QDir standardConfigDirectory;

        if(!standardConfigDirectory.exists(standardPath)) {
            standardConfigDirectory.mkdir(standardPath);
        }
#ifndef QT_DEBUG
        // copy from qrc to standard dir
        const QString source = QStringLiteral("://data/settings.json");
#else
        // debugging does not work for standard (localhost) so copy the file from application
        const QString source = QString("%1/%2").arg(standardPath).arg(QStringLiteral("settings.json"));
#endif
        if(QFile::copy(source, targetPath)) {
            qInfo("Deployed default settings file from: qrc://data/settings.json");
            QFile::setPermissions(targetPath, QFlags<QFile::Permission>(0x6644)); //like 644
            globalSettingsFile->loadFromStandardLocation(settingsFile);
        }
    }

#ifdef QT_DEBUG
    engine.rootContext()->setContextProperty("BUILD_TYPE", "debug");
#else
    if(qgetenv("VF_GUI_DEBUG") == QByteArray("debug_enabled")) //enviroment variable override
    {
        engine.rootContext()->setContextProperty("BUILD_TYPE", "debug");
    }
    else
    {
        engine.rootContext()->setContextProperty("BUILD_TYPE", "release");
    }
#endif //QT_DEBUG

#ifdef Q_OS_ANDROID
    engine.rootContext()->setContextProperty("OS_TYPE", "android");
#else
    engine.rootContext()->setContextProperty("OS_TYPE", "linux");
#endif //Q_OS_ANDROID

    engine.rootContext()->setContextProperty("HAS_QT_VIRTUAL_KEYBOARD", hasQtVirtualKeyboard);
    engine.rootContext()->setContextProperty("QT_VERSION", QT_VERSION);

    VeinEvent::EventHandler *evHandler = new VeinEvent::EventHandler(&app);
    ZeraGlueLogic *glueLogicSystem = new ZeraGlueLogic(glueLogicMap, &app);
    VeinNet::NetworkSystem *netSystem = new VeinNet::NetworkSystem(&app);
    VeinNet::TcpSystem *tcpSystem = new VeinNet::TcpSystem(&app);
    VeinApiQml::VeinQml *qmlApi = new VeinApiQml::VeinQml(&app);

    VeinApiQml::VeinQml::setStaticInstance(qmlApi);
    QList<VeinEvent::EventSystem*> subSystems;

    QObject::connect(qmlApi, &VeinApiQml::VeinQml::sigStateChanged, [&](VeinApiQml::VeinQml::ConnectionState t_state){
        if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_LOADED && loadedOnce == false)
        {

            loadedOnce = true;
        }
        else if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_ERROR)
        {
            engine.quit();
        }
    });

    QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigSendEvent, [&](QEvent *t_event){
        if(t_event->type()==VeinNet::NetworkStatusEvent::getEventType())
        {
            //network not ready, try again in 3 seconds
            qDebug() << "Network failed retrying network connection ...";
            networkWatchdog.start(3000);
        }
    });

    netSystem->setOperationMode(VeinNet::NetworkSystem::VNOM_PASS_THROUGH);

    subSystems.append(glueLogicSystem);
    subSystems.append(netSystem);
    subSystems.append(tcpSystem);
    subSystems.append(qmlApi);

    evHandler->setSubsystems(subSystems);

    QString netHost = "127.0.0.1";
    quint16 netPort = 12000;
#ifdef Q_OS_ANDROID
    ///@todo for android: code is needed to fetch a list of possible hosts via QtZeroConf service discovery
#endif //Q_OS_ANDROID

    netHost = globalSettingsFile->getOption("modulemanagerIp", "127.0.0.1");
    netPort = static_cast<quint16>(globalSettingsFile->getOption("modulemanagerPort", "12000").toUInt());

    tcpSystem->connectToServer(netHost, netPort);

    QObject::connect(&networkWatchdog, &QTimer::timeout, [&]() {
        tcpSystem->connectToServer(netHost, netPort);
    });

    QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigConnnectionEstablished, [&]() {
        engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
        qmlApi->entitySubscribeById(0);
    });

    QObject::connect(&app, &QApplication::aboutToQuit, [&]() {
        engine.quit();
        evHandler->clearSubsystems();
        evHandler->deleteLater();
        //the qmlengine will delete the qmlApi
        subSystems.removeAll(qmlApi);
        for(VeinEvent::EventSystem *toDelete : subSystems) {
            toDelete->deleteLater();
        }
        subSystems.clear();
    });
    return app.exec();
}
