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
#include <tcpnetworkfactory.h>
#include <vn_networkstatusevent.h>
#include <veinqml.h>
#include <veinqmlwrapper.h>
#include <fontawesome-qml.h>
#include "vfcomponenteventdispatcher.h"
#include "tableeventconsumer.h"
#include "gluelogicpropertymap.h"
#include <zeratranslationplugin.h>
#include <advancednetworkmanager.h>
#include <zeracomponents.h>
#include <zeraveincomponents.h>
#include <vectordiagramqmlregister.h>
#include <jsonsettingsfile.h>
#include "qmlfileio.h"
#include "updatewrapper.h"
#include "qmlappstarterforwebgl.h"
#include "qmlappstarterforwebserver.h"
#include "qmlappstarterforapi.h"
#include "screencapture.h"
#include "authorizationrequesthandler.h"
#include "vfrecorderjsonhelper.h"
#include "axisautoscaler.h"
#include "singlevaluescaler.h"
#include "vs_clientstorageeventsystem.h"
#include "vf_recorder.h"
#include "recordercaching.h"
#include <qwtcharts.h>
#include <declarativejsonitem.h>
#include <zvkeyboardlayout.h>

static void registerQmlExt(QQmlApplicationEngine &engine)
{
    qInfo("Register external QML dependencies...");
    ZeraTranslationPlugin::registerQml();
    FontAwesomeQml::registerFonts(true, true, false);
    FontAwesomeQml::registerFAQml(&engine);
    AdvancedNetworkmanager::registerQml(engine);
    ZeraComponents::registerQml(engine);
    ZeraVeinComponents::registerQml(engine);
    QwtCharts::registerQml();
    VectorDiagramQmlRegister::registerQml();
    qInfo("External QML dependencies registered.");
}

JsonSettingsFile *getJsonSettingsFileInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return JsonSettingsFile::getInstance();
}

QmlFileIO *getQmlFileIOInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return QmlFileIO::getInstance();
}

Vf_Recorder *getVfRecorderInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return Vf_Recorder::getInstance();
}

RecorderCaching *getRecorderCache(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return RecorderCaching::getInstance();
}

static void registerQmlInt()
{
    qInfo("Register internal QML dependencies...");
    QmlAppStarterForWebGL::registerQMLSingleton();
    QmlAppStarterForWebserver::registerQMLSingleton();
    QmlAppStarterForApi::registerQMLSingleton();
    qmlRegisterSingletonType<JsonSettingsFile>("ZeraSettings", 1, 0, "Settings", getJsonSettingsFileInstance);
    qmlRegisterSingletonType<QmlFileIO>("QmlFileIO", 1, 0, "QmlFileIO", getQmlFileIOInstance);
    qmlRegisterSingletonType<Vf_Recorder>("Vf_Recorder", 1, 0, "Vf_Recorder", getVfRecorderInstance);
    qmlRegisterSingletonType<RecorderCaching>("RecorderDataCache", 1, 0, "RecorderDataCache", getRecorderCache);
    qmlRegisterType<DeclarativeJsonItem>("DeclarativeJson", 1, 0, "DeclarativeJsonItem");
    qmlRegisterType<ScreenCapture>("ScreenCapture", 1, 0, "ScreenCapture");
    qmlRegisterType<AuthorizationRequestHandler>("AuthorizationRequestHandler", 1, 0, "AuthorizationRequestHandler");
    qmlRegisterType<VfRecorderJsonHelper>("VfRecorderJsonHelper", 1, 0, "VfRecorderJsonHelper");
    qmlRegisterType<AxisAutoScaler>("AxisAutoScaler", 1, 0, "AxisAutoScaler");
    qmlRegisterType<SingleValueScaler>("SingleValueScaler", 1, 0, "SingleValueScaler");
    qmlRegisterType<UpdateWrapper>("UpdateWrapper", 1, 0, "UpdateWrapper");
    qmlRegisterSingletonType<GlueLogicPropertyMap>("TableEventDistributor", 1, 0, "ZGL", GlueLogicPropertyMap::getStaticInstance);
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/ModuleIntrospection.qml"), "ModuleIntrospection", 1, 0, "ModuleIntrospection");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/SessionState.qml"), "SessionState", 1, 0, "SessionState");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/ColorSettings.qml"), "ColorSettings", 1, 0, "CS");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/GlobalConfig.qml"), "GlobalConfig", 1, 0, "GC");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/FunctionTools.qml"), "FunctionTools", 1, 0, "FT");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/MeasChannelInfo.qml"), "MeasChannelInfo", 1, 0, "MeasChannelInfo");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/AdjustmentState.qml"), "AdjustmentState", 1, 0, "AdjState");
    qmlRegisterSingletonType(QUrl("qrc:/qml/singletons/PowerModuleVeinGetter.qml"), "PowerModuleVeinGetter", 1, 0, "PwrModVeinGetter");
    qmlRegisterSingletonType(QUrl("qrc:/qml/controls/settings/SlowMachineSettingsHelperSingleton.qml"), "SlowMachineSettingsHelper", 1, 0, "SlwMachSettingsHelper");
    qInfo("Internal QML dependencies registered.");
}

static void loadSettings(JsonSettingsFile *globalSettingsFile, bool webGlServer)
{
    qInfo("Load settings..");
    globalSettingsFile->setAutoWriteBackEnabled(true);
    QString settingsFile = QStringLiteral("settings.json");
    if(webGlServer)
        settingsFile = QStringLiteral("settings-remote.json");
    if(globalSettingsFile->loadFromStandardLocation(settingsFile) == false) {
        const QString standardPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        const QString targetPath = QString("%1/%2").arg(standardPath, settingsFile);
        QDir standardConfigDirectory;
        if(!standardConfigDirectory.exists(standardPath))
            standardConfigDirectory.mkdir(standardPath);
        // copy from qrc to standard dir
        const QString source = QStringLiteral("://data/settings.json");
        if(QFile::copy(source, targetPath)) {
            qInfo("Deployed default settings file from: qrc://data/settings.json");
            QFile::setPermissions(targetPath, QFlags<QFile::Permission>(0x6644)); //like 644
            globalSettingsFile->loadFromStandardLocation(settingsFile);
        }
    }
    qInfo("Settings loaded.");
}

static void loadQmlEngine(QQmlApplicationEngine &engine)
{
    static bool loadedOnce = false;
    if(!loadedOnce) {
        qInfo("Loading QML engine...");
        engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
        qInfo("QML engine loaded.");
    }
    loadedOnce = true;
}

int main(int argc, char *argv[])
{
    qInfo("Application starts...");

    //qputenv("QSG_RENDER_LOOP", QByteArray("threaded")); //threaded opengl rendering
    //qputenv("QMLSCENE_DEVICE", QByteArray("softwarecontext")); //software renderer

    // We need to pin virtual keyboard on - otherwise Qml complains for unknown
    // Type 'InputPanel'
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard")); //virtual keyboard

    ZVKeyboardLayout::setKeyboardLayoutEnvironment();

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

    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    // WebGL server
    QCommandLineParser parser;
    QCommandLineOption webGlServerOption(QStringList() << "w" << "webgl-server", "Set: Start as webGL server");
    webGlServerOption.setDefaultValue("0");
    parser.addOption(webGlServerOption);
    QCommandLineOption enableSourceControlOption(QStringList() << "s" << "source-control-remote", "Set: Allow source control at remote control");
    enableSourceControlOption.setDefaultValue("0");
    parser.addOption(enableSourceControlOption);
    parser.process(app);
    bool webGlServer = parser.isSet(webGlServerOption);
    bool enableSourceControl = parser.isSet(enableSourceControlOption);
    QmlAppStarterForWebGL *pWGLSingleon = QmlAppStarterForWebGL::getStaticInstance();
    pWGLSingleon->setIsServer(webGlServer);
    pWGLSingleon->setEnableSource(enableSourceControl);
    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArray(webGlServer? "1" : "0"));

    JsonSettingsFile *globalSettingsFile = JsonSettingsFile::getInstance();
    loadSettings(globalSettingsFile, webGlServer);
    ZeraTranslation::setInitialLanguage(globalSettingsFile->getOption("locale", "en_GB"));

    app.setWindowIcon(QIcon(":/data/staticdata/resources/appicon.png"));

    QQmlApplicationEngine engine;
    registerQmlExt(engine);
    registerQmlInt();
    engine.rootContext()->setContextProperty("DESKTOP_SESSION", qgetenv("DESKTOP_SESSION"));

    QTimer networkWatchdog;
    networkWatchdog.setInterval(3000);
    networkWatchdog.setSingleShot(true);


#ifdef QT_DEBUG
    engine.rootContext()->setContextProperty("BUILD_TYPE", "debug");
#else
    engine.rootContext()->setContextProperty("BUILD_TYPE", "release");
#endif //QT_DEBUG

    GlueLogicPropertyMap *glueLogicMap = new GlueLogicPropertyMap(&app);
    GlueLogicPropertyMap::setStaticInstance(glueLogicMap);

    VeinEvent::EventHandler *evHandler = new VeinEvent::EventHandler(&app);
    std::shared_ptr<TableEventConsumer> consumer = std::make_shared<TableEventConsumer>(glueLogicMap);
    VfComponentEventDispatcher *glueLogicSystem = new VfComponentEventDispatcher(consumer);
    VeinNet::NetworkSystem *netSystem = new VeinNet::NetworkSystem(&app);
    VeinNet::TcpSystem *tcpSystem = new VeinNet::TcpSystem(VeinTcp::TcpNetworkFactory::create(), &app);
    VeinApiQml::VeinQml *qmlApi = new VeinApiQml::VeinQml(&app);
    VeinStorage::ClientStorageEventSystem *storage = new VeinStorage::ClientStorageEventSystem(&app);
    Vf_Recorder::setStorageSystem(storage);
    Vf_Recorder *recorder = Vf_Recorder::getInstance();

    VeinApiQml::VeinQml::setStaticInstance(qmlApi);
    QList<VeinEvent::EventSystem*> subSystems;

    loadQmlEngine(engine);
    QObject::connect(qmlApi, &VeinApiQml::VeinQml::sigStateChanged, [&](VeinApiQml::VeinQml::ConnectionState t_state){
        if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_ERROR)
        {
            engine.quit();
        }
    });

    QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigSendEvent, [&](QEvent *t_event){
        if(t_event->type()==VeinNet::NetworkStatusEvent::getQEventType())
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
    subSystems.append(storage);

    evHandler->setSubsystems(subSystems);

    QString netHost = "127.0.0.1";
    quint16 netPort = 12000;
#ifdef Q_OS_ANDROID
    ///@todo for android: code is needed to fetch a list of possible hosts via QtZeroConf service discovery
#endif //Q_OS_ANDROID

    netHost = globalSettingsFile->getOption("modulemanagerIp", "127.0.0.1");
    netPort = static_cast<quint16>(globalSettingsFile->getOption("modulemanagerPort", "12000").toUInt());

    qInfo("Connecting to modman...");
    tcpSystem->connectToServer(netHost, netPort);

    QObject::connect(&networkWatchdog, &QTimer::timeout, [&]() {
        qInfo("Repeat connecting to modman...");
        tcpSystem->connectToServer(netHost, netPort);
    });

    QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigConnnectionEstablished, [&]() {
        qInfo("Subscribe system entity...");
        qmlApi->entitySubscribeById(0);
    });

    // ATOW application seems to quit silently. To find out when spawn a ping
    QTimer periodicLogTimer;
    periodicLogTimer.setSingleShot(false);
    QObject::connect(&periodicLogTimer, &QTimer::timeout, [] {
        qDebug("Application ping");
    });
    periodicLogTimer.start(10000);

    QObject::connect(&app, &QApplication::aboutToQuit, [&]() {
        engine.quit();
        Vf_Recorder::deleteInstance();
        evHandler->clearSubsystems();
        evHandler->deleteLater();
        //the qmlengine will delete the qmlApi
        subSystems.removeAll(qmlApi);
        for(VeinEvent::EventSystem *toDelete : subSystems) {
            toDelete->deleteLater();
        }
        subSystems.clear();
        qInfo("About to quit application.");
    });
    return app.exec();
}
