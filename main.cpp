#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QIcon>
#include <QStandardPaths>

#include <ve_eventhandler.h>
#include <vn_networksystem.h>
#include <vn_tcpsystem.h>
#include <vn_networkstatusevent.h>
#include <veinqml.h>
#include <veinqmlwrapper.h>
#include <memory>

#include "fpscounter.h"
#include "fftbarchart.h"
#include "barchart.h"
#include "cbar.h"
#include "com5003gluelogic.h"
#include "com5003translation.h"
#include "phasordiagram.h"

#include "jsonglobalsettings.h"
#include "jsonsettingsfile.h"

int main(int argc, char *argv[])
{
  QStringList loggingFilters = QStringList() << QString("%1.debug=false").arg(VEIN_EVENT().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_NET_VERBOSE().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_NET_INTRO_VERBOSE().categoryName()) << //< Introspection logging is still enabled
                                                QString("%1.debug=false").arg(VEIN_NET_TCP_VERBOSE().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_API_QML_INTROSPECTION().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_API_QML_VERBOSE().categoryName());


  QLoggingCategory::setFilterRules(loggingFilters.join("\n"));

  bool loadedOnce = false;

  qmlRegisterType<FPSCounter>("FPSCounter", 1, 0, "FPSCounter");

  qmlRegisterType<FftBarChart>("QwtChart", 1, 0, "FftBarChart");
  qmlRegisterType<BarChart>("QwtChart", 1, 0, "BarChart");
  qmlRegisterType<cBar>("QwtChart", 1, 0, "Bar");
  qmlRegisterType<PhasorDiagram>("PhasorDiagram", 1, 0, "PhasorDiagram");
  qmlRegisterSingletonType<Com5003Translation>("Com5003Translation", 1, 0, "ZTR", Com5003Translation::getSingletonInstance);

  qmlRegisterSingletonType(QUrl("qrc:/components/common/ModuleIntrospection.qml"), "ModuleIntrospection", 1, 0, "ModuleIntrospection");
  qmlRegisterSingletonType(QUrl("qrc:/components/common/GlobalConfig.qml"), "GlobalConfig", 1, 0, "GC");

  qmlRegisterType<JsonSettingsFile>("ZeraSettings", 1, 0, "ZeraSettings");
  qmlRegisterType<JsonGlobalSettings>("ZeraSettings", 1, 0, "ZeraGlobalSettings");

  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);
  app.setWindowIcon(QIcon(":/data/staticdata/resources/appicon.png"));

  QQmlApplicationEngine engine;
  QTimer networkWatchdog;
  networkWatchdog.setInterval(3000);
  networkWatchdog.setSingleShot(true);

#ifdef QT_DEBUG
  engine.rootContext()->setContextProperty("BUILD_TYPE", "debug");
#else
  engine.rootContext()->setContextProperty("BUILD_TYPE", "release");
#endif //QT_DEBUG

#ifdef Q_OS_ANDROID
  engine.rootContext()->setContextProperty("OS_TYPE", "android");
#else
  engine.rootContext()->setContextProperty("OS_TYPE", "linux");
#endif //Q_OS_ANDROID

  VeinEvent::EventHandler *evHandler = new VeinEvent::EventHandler(&app);
  Com5003GlueLogic *glueLogicSystem = new Com5003GlueLogic(&app);
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


  Com5003Translation *comTranslation = new Com5003Translation(&app);
  comTranslation->changeLanguage(QLocale::system().bcp47Name());
  Com5003Translation::setStaticInstance(comTranslation);


  JsonSettingsFile *globalSettingsFile = JsonSettingsFile::getInstance();

  if(globalSettingsFile->loadFromStandardLocation("settings.json") == false)
  {
    const QString targetPath = QString("%1/settings.json").arg(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation));
    //copy from qrc to standard dir
    if(QFile::copy("://data/settings.json", targetPath))
    {
      qDebug("Deployed default settings file from: qrc://data/settings.json");
      QFile::setPermissions(targetPath, QFlags<QFile::Permission>(0x6644)); //like 644
      globalSettingsFile->loadFromStandardLocation("settings.json");
    }
  }

  QString netHost = "127.0.0.1";
  int netPort = 12000;

  if(globalSettingsFile->hasOption("modulemanagerIp") && globalSettingsFile->hasOption("modulemanagerPort"))
  {
    netHost = globalSettingsFile->getOption("modulemanagerIp");
    netPort = globalSettingsFile->getOption("modulemanagerPort").toInt();
  }

  tcpSystem->connectToServer(netHost, netPort);

  QObject::connect(&networkWatchdog, &QTimer::timeout, [&](){
    tcpSystem->connectToServer(netHost, netPort);
  });

  QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigConnnectionEstablished, [&]() {
    qmlApi->setRequiredIds(QList<int>()<<0<<50);//1012<<1011<<1009<<1007<<1008<<1006<<1005<<1004<<1003<<1002<<1001<<1000<<1010<<1014<<1013<<0<<50);
    glueLogicSystem->startIntrospection();
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
