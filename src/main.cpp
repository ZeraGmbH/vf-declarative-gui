#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QIcon>
#include <QStandardPaths>
#include <QDir>

#include <ve_eventhandler.h>
#include <vn_networksystem.h>
#include <vn_tcpsystem.h>
#include <vn_networkstatusevent.h>
#include <veinqml.h>
#include <veinqmlwrapper.h>
#include <csignal>

#include "fftbarchart.h"
#include "hpwbarchart.h"
#include "barchart.h"
#include "cbar.h"
#include "zeragluelogic.h"
#include "gluelogicpropertymap.h"
#include "zeratranslation.h"
#include "phasordiagram.h"

#include "jsonglobalsettings.h"
#include "jsonsettingsfile.h"
#include "qmlfileio.h"

void signalHandler(int sig)
{
  if (sig == SIGHUP)
  {
    qWarning("Application terminated by SIGHUP");
  }
  else if (sig == SIGINT)
  {
    qWarning("Application terminated by SIGINT");
  }
  else if (sig == SIGTERM)
  {
    qWarning("Application terminated by SIGTERM");
  }
  QCoreApplication::instance()->quit();
}

int main(int argc, char *argv[])
{
  signal(SIGHUP, signalHandler);
  signal(SIGINT, signalHandler);
  signal(SIGTERM, signalHandler);
  //qputenv("QSG_RENDER_LOOP", QByteArray("threaded")); //threaded opengl rendering
  //qputenv("QMLSCENE_DEVICE", QByteArray("softwarecontext")); //software renderer
  //qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard")); //virtual keyboard
  const bool hasQtVirtualKeyboard = (qgetenv("QT_IM_MODULE") == QByteArray("qtvirtualkeyboard"));

  QStringList loggingFilters = QStringList() << QString("%1.debug=false").arg(VEIN_EVENT().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_NET_VERBOSE().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_NET_INTRO_VERBOSE().categoryName()) << //< Introspection logging is still enabled
                                                QString("%1.debug=false").arg(VEIN_NET_TCP_VERBOSE().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_API_QML_INTROSPECTION().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_API_QML_VERBOSE().categoryName());// << "qt.qml.binding.removal.info=true"; //debug binding overrides

  QLoggingCategory::setFilterRules(loggingFilters.join("\n"));

  bool loadedOnce = false;

  qmlRegisterType<FftBarChart>("QwtChart", 1, 0, "FftBarChart");
  qmlRegisterType<HpwBarChart>("QwtChart", 1, 0, "HpwBarChart");
  qmlRegisterType<BarChart>("QwtChart", 1, 0, "BarChart");
  qmlRegisterType<cBar>("QwtChart", 1, 0, "Bar");
  qmlRegisterType<PhasorDiagram>("PhasorDiagram", 1, 0, "PhasorDiagram");
  qmlRegisterSingletonType<ZeraTranslation>("ZeraTranslation", 1, 0, "ZTR", ZeraTranslation::getStaticInstance);
  qmlRegisterSingletonType<GlueLogicPropertyMap>("ZeraGlueLogic", 1, 0, "ZGL", GlueLogicPropertyMap::getStaticInstance);

  qmlRegisterSingletonType(QUrl("qrc:/components/common/ModuleIntrospection.qml"), "ModuleIntrospection", 1, 0, "ModuleIntrospection");
  qmlRegisterSingletonType(QUrl("qrc:/components/common/GlobalConfig.qml"), "GlobalConfig", 1, 0, "GC");

  qmlRegisterType<JsonSettingsFile>("ZeraSettings", 1, 0, "ZeraSettings");
  qmlRegisterType<JsonGlobalSettings>("ZeraSettings", 1, 0, "ZeraGlobalSettings");

  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);
  app.setWindowIcon(QIcon(":/data/staticdata/resources/appicon.png"));

  ZeraTranslation *zeraTranslation = new ZeraTranslation(&app);
  //load defaults as there could be no language available
  zeraTranslation->changeLanguage("C");
  ZeraTranslation::setStaticInstance(zeraTranslation);
  QmlFileIO::setStaticInstance(new QmlFileIO(&app));

  GlueLogicPropertyMap *glueLogicMap = new GlueLogicPropertyMap(&app);
  GlueLogicPropertyMap::setStaticInstance(glueLogicMap);

  QQmlApplicationEngine engine;
  QTimer networkWatchdog;
  networkWatchdog.setInterval(3000);
  networkWatchdog.setSingleShot(true);

  JsonSettingsFile *globalSettingsFile = JsonSettingsFile::getInstance();

  if(globalSettingsFile->loadFromStandardLocation("settings.json") == false)
  {
    const QString standardPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    const QString targetPath = QString("%1/settings.json").arg(standardPath);
    QDir standardConfigDirectory;

    if(!standardConfigDirectory.exists(standardPath))
    {
      standardConfigDirectory.mkdir(standardPath);
    }
    //copy from qrc to standard dir
    if(QFile::copy("://data/settings.json", targetPath))
    {
      qDebug("Deployed default settings file from: qrc://data/settings.json");
      QFile::setPermissions(targetPath, QFlags<QFile::Permission>(0x6644)); //like 644
      globalSettingsFile->loadFromStandardLocation("settings.json");
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
  ZeraGlueLogic *glueLogicSystem = new ZeraGlueLogic(glueLogicMap, zeraTranslation, &app);
  VeinNet::NetworkSystem *netSystem = new VeinNet::NetworkSystem(&app);
  VeinNet::TcpSystem *tcpSystem = new VeinNet::TcpSystem(&app);
  VeinApiQml::VeinQml *qmlApi = new VeinApiQml::VeinQml(&app);

  VeinApiQml::VeinQml::setStaticInstance(qmlApi);
  QList<VeinEvent::EventSystem*> subSystems;

  QObject::connect(qmlApi, &VeinApiQml::VeinQml::sigStateChanged, [&](VeinApiQml::VeinQml::ConnectionState t_state){
    if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_LOADED && loadedOnce == false)
    {
      engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
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
  int netPort = 12000;
#ifdef Q_OS_ANDROID
  ///@todo for android: code is needed to fetch a list of possible hosts via QtZeroConf service discovery
#endif //Q_OS_ANDROID

  if(globalSettingsFile->hasOption("modulemanagerIp") && globalSettingsFile->hasOption("modulemanagerPort"))
  {
    netHost = globalSettingsFile->getOption("modulemanagerIp");
    netPort = globalSettingsFile->getOption("modulemanagerPort").toInt();
  }

  tcpSystem->connectToServer(netHost, netPort);

  QObject::connect(&networkWatchdog, &QTimer::timeout, [&]() {
    tcpSystem->connectToServer(netHost, netPort);
  });

  QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigConnnectionEstablished, [&]() {
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
    globalSettingsFile->saveToFile(globalSettingsFile->getCurrentFilePath(), true);
  });
  return app.exec();
}
