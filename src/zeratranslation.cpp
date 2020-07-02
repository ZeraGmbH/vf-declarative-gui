#include "zeratranslation.h"
#include <QLocale>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUrl>
#include <QCoreApplication>
#include <QDebug>

ZeraTranslation::ZeraTranslation(QObject *parent) : QQmlPropertyMap(this, parent)
{
  setupTranslationFiles();
}

void ZeraTranslation::setStaticInstance(ZeraTranslation *t_instance)
{
  if(s_instance == nullptr)
  {
    s_instance = t_instance;
  }
}

QObject *ZeraTranslation::getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
  Q_UNUSED(t_engine)
  Q_UNUSED(t_scriptEngine)

  return s_instance;
}


void ZeraTranslation::changeLanguage(const QString &t_language)
{
  if(m_currentLanguage != t_language)
  {
    m_currentLanguage = t_language;
    QLocale locale = QLocale(m_currentLanguage);
    QString languageName = QLocale::languageToString(locale.language());
    if(m_translationFilesModel.contains(t_language) || t_language == "C")
    {
      const QString filename = m_translationFilesModel.value(t_language);

      QCoreApplication::instance()->removeTranslator(&m_translator);

      if(m_translator.load(filename))
      {
        QCoreApplication::instance()->installTranslator(&m_translator);
        qDebug() << "Current Language changed to" << languageName << locale << t_language;
        reloadStringTable();
      }
      else
      {
        if(t_language != "C")
        {
          qWarning() << "Language not found:" << t_language << filename.arg(t_language);
        }
        reloadStringTable();
      }
    }
    else if(t_language != "C")
    {
      qWarning() << "Language not found for locale:" << t_language;
    }
  }
}

void ZeraTranslation::setupTranslationFiles()
{
#ifdef QT_DEBUG
  //also load from qrc
  const QStringList searchPaths {":/translations/", "/usr/share/zera/translations/", "/home/operator/translations/"};
#else
  const QStringList searchPaths {"/usr/share/zera/translations/", "/home/operator/translations/"};
#endif

  for(const QString &path : searchPaths)
  {
    QDir searchDir;
    searchDir.setPath(path);
    if(searchDir.exists() && searchDir.isReadable())
    {
      const auto qmList = searchDir.entryInfoList({"*.qm"}, QDir::Files);
      for(const QFileInfo &qmFileInfo : qmList)
      {
        const QString localeName = qmFileInfo.fileName().replace("zera-gui_","").replace(".qm","");
        if(m_translationFilesModel.contains(localeName) == false)
        {
          QFileInfo flagFileInfo;
          flagFileInfo.setFile(QString("%1/flag_%2.png").arg(qmFileInfo.path()).arg(localeName));//currently only supports .png (.svg rasterization is too slow)
          if(flagFileInfo.exists())
          {
            m_translationFilesModel.insert(localeName, qmFileInfo.absoluteFilePath());
            const QUrl flagUrl = QUrl::fromLocalFile(flagFileInfo.absoluteFilePath());
            m_translationFlagsModel.insert(localeName, flagUrl.toString()); //qml image needs url form (qrc:<...> or file://<...>)
          }
          else
          {
            qWarning() << "Flag file for translation:" << qmFileInfo.absoluteFilePath() << "doesn't exist, skipping translation!";
          }
        }
        else
        {
          qWarning() << "Skipping duplicate translation:" << qmFileInfo.absoluteFilePath() << "already loaded file from:" << m_translationFilesModel.value(localeName);
        }
      }
    }
  }
  //export available languages to qml
  insert("TRANSLATION_LOCALES", QVariant::fromValue<QStringList>(m_translationFlagsModel.keys()));
  insert("TRANSLATION_FLAGS", QVariant::fromValue<QStringList>(m_translationFlagsModel.values()));
}

void ZeraTranslation::reloadStringTable()
{
  //insert("something %1", tr("something %1"))...

  //zeragluelogic.cpp
  insert("4LW", tr("4LW", "4 Leiter Wirkleistung = 4 wire active power"));
  insert("3LW", tr("3LW", "3 Leiter Wirkleistung = 3 wire active power"));
  insert("2LW", tr("2LW", "2 Leiter Wirkleistung = 2 wire active power"));

  insert("4LB", tr("4LB", "4 Leiter Blindleistung = 4 wire reactive power"));
  insert("4LBK", tr("4LBK", "4 Leiter Blindleistung künstlicher Nulleiter = 4 wire reactive power artificial zero conductor"));
  insert("3LB", tr("3LB", "3 Leiter Blindleistung = 3 wire reactive power"));
  insert("2LB", tr("2LB", "2 Leiter Blindleistung = 2 wire reactive power"));

  insert("4LS", tr("4LS", "4 Leiter Scheinleistung = 4 wire apparent power"));
  insert("4LSg", tr("4LSg", "4 Leiter Scheinleistung geometrisch = 4 wire apparent power geometric"));
  insert("2LS", tr("2LS", "2 Leiter Scheinleistung = 2 wire apparent power"));
  insert("2LSg", tr("2LSg", "2 Leiter Scheinleistung geometrisch = 2 wire apparent power geometric"));
  insert("QREF", tr("QREF", "Referenz-Modus = reference mode"));

  insert("L1", tr("L1", "measuring system 1"));
  insert("L2", tr("L2", "measuring system 2"));
  insert("L3", tr("L3", "measuring system 3"));
  insert("AUX", tr("AUX", "auxiliary measuring system"));

  insert("REF1", tr("REF1", "reference channel 1"));
  insert("REF2", tr("REF2", "reference channel 2"));
  insert("REF3", tr("REF3", "reference channel 3"));
  insert("REF4", tr("REF4", "reference channel 4"));
  insert("REF5", tr("REF5", "reference channel 5"));
  insert("REF6", tr("REF6", "reference channel 6"));

  insert("UPN", tr("UPN","voltage pase to neutral"));
  insert("UPP", tr("UPP","voltage phase to phase"));
  insert("kU", tr("kU","harmonic distortion on voltage"));
  insert("I", tr("I","current"));
  insert("kI", tr("kI","harmonic distortion on current"));
  insert("∠U", tr("∠U","phase difference of voltage to reference channel"));
  insert("∠I", tr("∠I","phase difference of current to reference channel"));
  insert("∠UI", tr("∠UI","phase difference"));
  insert("λ", tr("λ","power factor"));
  //: needs to be short enough to fit
  insert("P", tr("P","active power"));
  //: needs to be short enough to fit
  insert("Q", tr("Q","reactive power"));
  //: needs to be short enough to fit
  insert("S", tr("S","apparent power"));
  insert("F", tr("F","frequency"));

  insert("Sb", tr("Sb", "standard burden"));
  insert("cos(β)", tr("cos(β)", "cosinus beta"));
  insert("Sn", tr("Sn", "operating burden in %, relative to the nominal burden"));
  insert("BRD1", tr("BRD1", "burden system name"));
  insert("BRD2", tr("BRD2", "burden system name"));
  insert("BRD3", tr("BRD3", "burden system name"));

  //PagePathView.qml
  //: as in "close this view"
  insert("OK", tr("OK"));
  insert("Close", tr("Close", "not open"));
  insert("Accept", tr("Accept"));
  insert("Cancel", tr("Cancel"));
  insert("Save", tr("Save"));
  insert("Default session", tr("Default session"));
  insert("Reference session", tr("Reference session"));
  //: changing energy direction session
  insert("CED session", tr("CED session"));
  insert("mt310s2-meas-session.json", tr("Default session"));
  insert("com5003-meas-session.json", tr("Default session"));
  insert("com5003-ref-session.json", tr("Reference session"));
  //: changing energy direction session
  insert("com5003-ced-session.json", tr("CED session"));

  //RangeMenu.qml
  //: used for a yes / no configuration element
  insert("Range automatic:", tr("Range automatic:"));
  //: measurement channel range overload, e.g. the range is configured for 5V measurement and the measured input voltage is >5V
  insert("Overload", tr("Overload"));
  //: used for a yes / no configuration element
  insert("Range grouping:", tr("Range grouping:"));
  //: manual channel range selection, used when range automatic is disabled
  insert("Manual:", tr("Manual:", "not automatic"));

  //RangePeak.qml
  insert("Peak values", tr("Peak values", "range peak values"));
  //: range peak value diagram scale selection
  insert("Scale visualisation:", tr("Scale visualisation:", "e.g. linear, logscale, relative to channel limit"));
  //: range peak value diagram logarithmic scale visualisation
  insert("Logarithmic scale", tr("Logarithmic scale"));
  //: range peak value diagram linear scale visualisation
  insert("RPV_ABSOLUTE", tr("Absolute"));
  //: range peak value diagram logarithmic scale visualisation
  insert("RPV_ABSOLUTE_LOGSCALE", tr("Logarithmic"));
  //: range peak value diagram relative to channel limit scale visualisation
  insert("RPV_RELATIVE_TO_LIMIT", tr("Relative to channel limit"));

  //Settings.qml
  //: settings specific to the GUI application
  insert("Application Settings", tr("Application Settings"));
  //: used for a yes / no configuration element
  insert("Display harmonic tables relative to the fundamental oscillation:", tr("Display harmonic tables relative to the fundamental oscillation:"));
  //: number of decimals after the decimal separator
  insert("Decimal places:", tr("Decimal places:"));
  //: used for the selection of language via country flag
  insert("Language:", tr("Language:"));
  //: settings specific to the hardware
  insert("Device settings", tr("Device settings"));
  //: settings specific to the network
  insert("Network settings", tr("Network settings"));
  //: measurement channel the phase locked loop uses as base
  insert("PLL channel:", tr("PLL channel:"));
  //: automatic phase locked loop channel selection
  insert("PLL channel automatic:", tr("PLL channel automatic:"));
  //: dft phase reference channel
  insert("DFT reference channel:", tr("DFT reference channel:"));
  //: System = measuring system
  insert("System colors:", tr("System colors:"));
  insert("Frequency input/output configuration:", tr("Frequency input/output configuration:"));
  //: Settings show/hide AUX phases
  insert("Show AUX phase values:", tr("Show AUX phase values:"));

  //: Displayed in Frequency input/output configuration
  insert("Nominal frequency:", tr("Nominal frequency:"));
  //: Displayed in Frequency input/output configuration
  insert("Frequency output constant:", tr("Frequency output constant:"));

  //SettingsInterval.qml
  //: time based integration interval
  insert("Integration time interval:", tr("Integration time interval:"));
  //: measurement period based integration interval
  insert("Integration period interval:", tr("Integration period interval:"));
  //displayed under settings
  insert("seconds", tr("seconds", "integration time interval unit"));
  insert("periods", tr("periods", "integration period interval unit"));

  //main.qml
  insert("Loading...", tr("Loading..."));
  //: progress of loading %1 of %2 objects
  insert("Loading: %1/%2", tr("Loading: %1/%2"));
  //: the measurement view pages e.g. "Vector Diagram", "Oscilloscope view", etc.
  insert("Pages", tr("Pages", "view pages"));
  //: settings for range automatic etc.
  insert("Range", tr("Range", "measuring range"));
  /* currently not used
  //: GUI and device specific configuration
  insert("Settings", tr("Settings", "configuration"));
  //: used when connecting to a remote device server, e.g. when the GUI is used from Android devices
  insert("Remotes", tr("Remotes", "remote servers"));
  //: %1 means the number of notifications
  insert("Notifications (%1)", tr("Notifications (%1)"));
  //: Device status infopage
  insert("Status", tr("Status"));
  */

  //ErrorCalculatorModulePage.qml
  insert("Idle", tr("Idle"));
  //: the state where the device waits for the first pulse / edge to be triggered
  insert("Armed", tr("Armed"));
  insert("Started", tr("Started", "measurement started"));
  //: like finished
  insert("Ready", tr("Ready"));
  insert("Aborted", tr("Aborted", "measurement was aborted"));
  insert("Result:", tr("Result:", "error calculator result"));
  //: switch between time based and period based measurement
  insert("Mode:", tr("Mode:", "error calculator"));
  //: reference channel selection
  insert("Reference input:", tr("Reference input:"));
  //: device input selection (e.g. scanning head)
  insert("Device input:", tr("Device input:"));
  //: device under test constat
  insert("DUT constant:", tr("DUT constant:"));
  //: energy to compare
  insert("Energy:", tr("Energy:"));
  //: value based on the DUT constant
  insert("MRate:", tr("MRate:"));
  insert("Start", tr("Start"));
  insert("Stop", tr("Stop"));
  insert("energy", tr("energy"));
  insert("mrate", tr("mrate"));
  insert("Lower error margin:", tr("Lower error margin:"));
  insert("Upper error margin:", tr("Upper error margin:"));
  insert("Continuous measurement", tr("Continuous measurement"));

  //ErrorRegisterModulePage.qml
  insert("Duration:", tr("Duration:"));
  insert("Start/Stop", tr("Start/Stop"));
  insert("Duration", tr("Duration"));
  insert("Start value:", tr("Start value:"));
  insert("End value:", tr("End value:"));

  //FftModulePage.qml
  //: text must be short enough to fit
  insert("Amp", tr("Amp", "Amplitude of the phasor"));
  //: text must be short enough to fit
  insert("Phase", tr("Phase","Phase of the phasor"));
  //: total harmonic distortion with noise
  insert("THDN:", tr("THDN:"));
  insert("Harmonic table", tr("Harmonic table", "Tab text harmonic table"));
  insert("Harmonic chart", tr("Harmonic chart", "Tab text harmonic chart"));

  //HarmonicPowerModulePage.qml
  insert("Harmonic power table", tr("Harmonic power table", "Tab text harmonic power table"));
  insert("Harmonic power chart", tr("Harmonic power chart", "Tab text harmonic power chart"));


  //: text must be short enough to fit
  insert("UL1", tr("UL1", "channel name"));
  //: text must be short enough to fit
  insert("UL2", tr("UL2", "channel name"));
  //: text must be short enough to fit
  insert("UL3", tr("UL3", "channel name"));
  //: text must be short enough to fit
  insert("IL1", tr("IL1", "channel name"));
  //: text must be short enough to fit
  insert("IL2", tr("IL2", "channel name"));
  //: text must be short enough to fit
  insert("IL3", tr("IL3", "channel name"));
  //: text must be short enough to fit
  insert("UAUX", tr("UAUX", "channel name"));
  //: text must be short enough to fit
  insert("IAUX", tr("IAUX", "channel name"));

  //MeasurementPageModel.qml
  //: polar (amplitude and phase) phasor diagram
  insert("Vector diagram", tr("Vector diagram"));
  insert("Actual values", tr("Actual values"));
  insert("Oscilloscope plot", tr("Oscilloscope plot"));
  //: FFT bar diagrams or tables that show the harmonic component distribution of the measured values
  insert("Harmonics & Curves", tr("Harmonics & Curves"));
  //: measuring mode dependent power values
  insert("Power values", tr("Power values"));
  //: FFT tables that show the real and imaginary parts of the measured power values
  insert("Harmonic power values", tr("Harmonic power values"));
  //: shows the deviation of measured energy between the reference device and the device under test
  insert("Error calculator", tr("Error calculator"));
  //: shows energy comparison between the reference device and the device under test's registers/display
  insert("Comparison measurements", tr("Comparison measurements"));

  //ComparisonTabsView.qml
  //: Comparison tabs label texts
  insert("Meter test", tr("Meter test"));
  insert("Energy comparison", tr("Energy comparison"));
  insert("Energy register", tr("Energy register"));
  insert("Power register", tr("Power register"));

  insert("Burden values", tr("Burden values"));
  insert("Transformer values", tr("Transformer values"));
  //: effective values
  insert("RMS values", tr("RMS values"));

  //BurdenModulePage.qml
  insert("Voltage Burden", tr("Voltage Burden", "Tab title current burden"));
  insert("Current Burden", tr("Current Burden", "Tab title current burden"));
  insert("Nominal burden:", tr("Nominal burden:"));
  insert("Nominal range:", tr("Nominal range:"));
  insert("Wire crosssection:", tr("Wire crosssection:"));
  insert("Wire length:", tr("Wire length:"));

  //ReferencePageModel.qml
  insert("Reference values", tr("Reference values"));

  //CEDPageModel.qml
  insert("CED power values", tr("CED power values"));

  //HarmonicPowerModulePage.qml
  insert("Measuring modes:", tr("Measuring modes:", "label for measuring mode selectors"));

  //TransformerModulePage.qml
  insert("TR1", tr("TR1", "transformer system 1"));
  insert("X-Prim:", tr("X-Prim:"));
  insert("X-Sec:", tr("X-Sec:"));
  insert("Ms-Prim:", tr("Ms-Prim:"));
  insert("Ms-Sec:", tr("Ms-Sec:"));
  insert("Mp-Prim:", tr("Mp-Prim:"));
  insert("Mp-Sec:", tr("Mp-Sec:"));
  insert("X-Ratio", tr("X-Ratio"));
  insert("N-Sec", tr("N-Sec"));
  insert("X-Prim", tr("X-Prim"));
  insert("X-Sec", tr("X-Sec"));
  insert("crad", tr("crad", "centiradian"));
  insert("arcmin", tr("arcmin", "arcminute"));

  //Zera Classes -> zera-basemodule -> errormessages.h
  //: RESMAN = resource manager
  insert("RESMAN ident error", tr("RESMAN ident error"));
  //: RESMAN = resource manager
  insert("RESMAN resourcetype not avail", tr("RESMAN resourcetype not avail"));
  //: RESMAN = resource manager
  insert("RESMAN resource not avail", tr("RESMAN resource not avail"));
  //: RESMAN = resource manager
  insert("RESMAN resource Info error", tr("RESMAN resource Info error"));
  //: RESMAN = resource manager
  insert("RESMAN set resource failed", tr("RESMAN set resource failed"));
  //: RESMAN = resource manager
  insert("RESMAN free resource failed", tr("RESMAN free resource failed"));

  insert("PCB dsp channel read failed", tr("PCB dsp channel read failed"));
  insert("PCB alias read failed", tr("PCB alias read failed"));
  insert("PCB sample rate read failed", tr("PCB sample rate read failed"));
  insert("PCB unit read failed", tr("PCB unit read failed"));
  insert("PCB range list read failed", tr("PCB range list read failed"));
  insert("PCB range alias read failed", tr("PCB range alias read failed"));
  insert("PCB range type read failed", tr("PCB range type read failed"));
  insert("PCB range urvalue read failed", tr("PCB range urvalue read failed"));
  insert("PCB range rejection read failed", tr("PCB range rejection read failed"));
  insert("PCB range overload rejection failed", tr("PCB range overload rejection failed"));
  insert("PCB range avail info read failed", tr("PCB range avail info read failed"));
  insert("PCB set range failed", tr("PCB set range failed"));
  insert("PCB get range failed", tr("PCB get range failed"));
  insert("PCB set measuring mode failed", tr("PCB set measuring mode failed"));
  insert("PCB read gain correction failed", tr("PCB read gain correction failed"));
  insert("PCB set gain node failed", tr("PCB set gain node failed"));
  insert("PCB read offset correction failed", tr("PCB read offset correction failed"));
  insert("PCB set offset node failed", tr("PCB set offset node failed"));
  insert("PCB read phase correction failed", tr("PCB read phase correction failed"));
  insert("PCB set phase node failed", tr("PCB set phase node failed"));
  insert("PCB read channel status failed", tr("PCB read channel status failed"));
  insert("PCB reset channel status failed", tr("PCB reset channel status failed"));
  insert("PCB formfactor read failed", tr("PCB formfactor read failed"));
  insert("PCB register notifier failed", tr("PCB register notifier failed"));
  insert("PCB unregister notifier failed", tr("PCB unregister notifier failed"));
  insert("PCB set pll failed", tr("PCB set pll failed"));
  insert("PCB muxchannel read failed", tr("PCB muxchannel read failed"));
  insert("PCB reference constant read failed", tr("PCB reference constant read failed"));
  insert("PCB adjustment status read failed", tr("PCB adjustment status read failed"));
  insert("PCB adjustment chksum read failed", tr("PCB adjustment chksum read failed"));
  insert("PCB server version read failed", tr("PCB server version read failed"));
  insert("PCB Controler version read failed", tr("PCB Controler version read failed"));
  insert("PCB FPGA version read failed", tr("PCB FPGA version read failed"));
  insert("PCB FPGA version read failed", tr("PCB FPGA version read failed"));
  insert("PCB error messages read failed", tr("PCB error messages read failed"));
  insert("PCB adjustment computation failed", tr("PCB adjustment computation failed"));
  insert("PCB adjustment storage failed", tr("PCB adjustment storage failed"));
  insert("PCB adjustment status setting failed", tr("PCB adjustment status setting failed"));
  insert("PCB adjustment init failed", tr("PCB adjustment init failed"));

  insert("DSP read gain correction failed", tr("DSP read gain correction failed"));
  insert("DSP read phase correction failed", tr("DSP read phase correction failed"));
  insert("DSP read offset correction failed", tr("DSP read offset correction failed"));
  insert("DSP write gain correction failed", tr("DSP write gain correction failed"));
  insert("DSP write phase correction failed", tr("DSP write phase correction failed"));
  insert("DSP write offset corredction failed", tr("DSP write offset corredction failed"));
  insert("DSP write varlist failed", tr("DSP write varlist failed"));
  insert("DSP write cmdlist failed", tr("DSP write cmdlist failed"));
  insert("DSP measure activation failed", tr("DSP measure activation failed"));
  insert("DSP measure deactivation failed", tr("DSP measure deactivation failed"));
  insert("DSP data acquisition failed", tr("DSP data acquisition failed"));
  insert("DSP memory write failed", tr("DSP memory write failed"));
  insert("DSP subdc write failed", tr("DSP subdc write failed"));
  insert("DSP server version read failed", tr("DSP server version read failed"));
  insert("DSP program version read failed", tr("DSP program version read failed"));
  insert("DSP setting sampling system failed", tr("DSP setting sampling system failed"));

  //: SEC = standard error calculator
  insert("SEC fetch ecalculator failed", tr("SEC fetch ecalculator failed"));
  //: SEC = standard error calculator
  insert("SEC free ecalculator failed", tr("SEC free ecalculator failed"));
  //: SEC = standard error calculator
  insert("SEC read register failed", tr("SEC read register failed"));
  //: SEC = standard error calculator
  insert("SEC write register failed", tr("SEC write register failed"));
  //: SEC = standard error calculator
  insert("SEC set sync failed", tr("SEC set sync failed"));
  //: SEC = standard error calculator
  insert("SEC set mux failed", tr("SEC set mux failed"));
  //: SEC = standard error calculator, cmdid = command id
  insert("SEC set cmdid failed", tr("SEC set cmdid failed"));
  //: SEC = standard error calculator
  insert("SEC start measure failed", tr("SEC start measure failed"));
  //: SEC = standard error calculator
  insert("SEC stop measure failed", tr("SEC stop measure failed"));

  insert("Interface JSON Document strange", tr("Interface JSON Document strange"));
  insert("Ethernet interface listen failed", tr("Ethernet interface listen failed"));
  insert("Serial interface not connected", tr("Serial interface not connected"));

  insert("Actual Values not found", tr("Actual Values not found"));
  insert("Release number not found", tr("Release number not found"));

  //StatusView.qml
  insert("Device info", tr("Device info"));
  insert("Device log", tr("Device log"));
  insert("License information", tr("License information"));
  insert("Serial number:", tr("Serial number:"));
  insert("Operating system version:", tr("Operating system version:"));
  insert("PCB server version:", tr("PCB server version:"));
  insert("DSP server version:", tr("DSP server version:"));
  insert("DSP firmware version:", tr("DSP firmware version:"));
  insert("FPGA firmware version:", tr("FPGA firmware version:"));
  insert("Microcontroller firmware version:", tr("Microcontroller firmware version:"));
  insert("Adjustment status:", tr("Adjustment status:"));
  insert("Not adjusted", tr("Not adjusted"));
  insert("Wrong version", tr("Wrong version"));
  insert("Wrong serial number", tr("Wrong serial number"));
  insert("Adjustment checksum:", tr("Adjustment checksum:"));
  insert("IP addresses:", tr("IP addresses:"));

  //Notifications.qml
  insert("Device notifications", tr("Device notifications"));

  //LoggerSettings.qml
  insert("Database Logging", tr("Database Logging"));
  insert("Logging enabled:", tr("Logging enabled:"));
  insert("DB location:", tr("DB location:"));
  insert("Database filename:", tr("Database filename:"));
  //: %1 = database size %2 = filesystem storage available, %2 = total, %3 = percentage available
  insert("<b>%1MB</b> (available <b>%2GB</b> of <b>%3GB</b> / %4%)", tr("<b>%1MB</b> (available <b>%2GB</b> of <b>%3GB</b> / %4%)"));
  insert("Scheduled logging enabled:", tr("Scheduled logging enabled:"));
  //: describes the duration of the recording
  insert("Logging Duration [hh:mm:ss]:", tr("Logging Duration [hh:mm:ss]:"));
  insert("Logger status:", tr("Logger status:"));
  //: describes the ongoing task of recording data into a database
  insert("Logging data", tr("Logging data"));
  insert("Logging disabled", tr("Logging disabled"));
  insert("No database selected", tr("No database selected"));
  insert("Database loaded", tr("Database loaded"));
  insert("Database error", tr("Database error"));
  insert("DB size:", tr("DB size:"));
  //: the user can make a selection of values he wants to log into a database
  insert("Select recorded values:", tr("Select recorded values:"));
  insert("Manage customer data:", tr("Manage customer data:"));
  insert("Snapshot", tr("Snapshot"));
  //: when the system disabled the customer data management, the brackets are for visual distinction from other text
  insert("[customer data is not available]", tr("[customer data is not available]"));
  //: when the customer number is empty, the brackets are for visual distinction from other text
  insert("[customer id is not set]", tr("[customer id is not set]"));
  //: placeholder text for the database path/filename
  insert("<directory name>/<filename>", tr("<directory name>/<filename>"));

  //LoggerDbSearchDialog.qml
  insert("Select file", tr("Select file"));


  //LoggerDatasetSelector.qml
  insert("Regex search", tr("Regex search", "regular expression search"));
  insert("Available for recording", tr("Available for recording", "list of selectable elements"));
  insert("Selected for recording", tr("Selected for recording", "list of selected elements"));
  insert("Description:", tr("Description:"));
  //:shown in the value selection dialog of the database logger
  insert("Unit:", tr("Unit:", "SI or SI derived unit"));

  //LoggerRecordNamePopup.qml
  //: displayed in logger record name popup, visible when the user presses start or snapshot in the logger
  //: the record name is a database field that the user can use to search / filter different recordings
  insert("Select record name", tr("Select record name"));
  //: the record name is a database field that the user can use to search / filter different recordings
  insert("Current record name:", tr("Current record name:"));
  //: the record name is a database field that the user can use to search / filter different recordings
  insert("Preset record name:", tr("Preset record name:"));
  //: the record name is a database field that the user can use to search / filter different recordings
  insert("Custom record name:", tr("Custom record name:"));
  //: shows a preview of the database logger record name
  insert("Preview:", tr("Preview:"));

  //CustomerDataEntry.qml
  insert("Customer data", tr("Customer data"));
  insert("Customer", tr("Customer"));
  //: power meter, not distance
  insert("Meter information", tr("Meter information"));
  insert("Location", tr("Location"));
  insert("Power grid", tr("Power grid"));
  insert("PAR_DatasetIdentifier", tr("Data Identifier:"));
  insert("PAR_DatasetComment", tr("Data Comment:"));
  insert("PAR_CustomerNumber", tr("Customer number:"));
  insert("PAR_CustomerFirstName", tr("Customer First name:"));
  insert("PAR_CustomerLastName", tr("Customer Last name:"));
  insert("PAR_CustomerCountry", tr("Customer Country:"));
  insert("PAR_CustomerCity", tr("Customer City:"));
  insert("PAR_CustomerPostalCode", tr("Customer ZIP code:", "Postal code"));
  insert("PAR_CustomerStreet", tr("Customer Street:"));
  insert("PAR_CustomerComment", tr("Customer Comment:"));
  insert("PAR_LocationNumber", tr("Location Identifier:"));
  insert("PAR_LocationFirstName", tr("Location First name:"));
  insert("PAR_LocationLastName", tr("Location Last name:"));
  insert("PAR_LocationCountry", tr("LocationCountry:"));
  insert("PAR_LocationCity", tr("Location City:"));
  insert("PAR_LocationPostalCode", tr("Location ZIP code:", "Postal code"));
  insert("PAR_LocationStreet", tr("Location Street:"));
  insert("PAR_LocationComment", tr("Location Comment:"));
  insert("PAR_MeterFactoryNumber", tr("Meter Factory number:"));
  insert("PAR_MeterManufacturer", tr("Meter Manufacturer:"));
  insert("PAR_MeterOwner", tr("Meter Owner:"));
  insert("PAR_MeterComment", tr("Meter Comment:"));
  insert("PAR_PowerGridOperator", tr("Power grid Operator:"));
  insert("PAR_PowerGridSupplier", tr("Power grid Supplier:"));
  insert("PAR_PowerGridComment", tr("Power grid Comment:"));

  //CustomerDataBrowser.qml

  insert("Customer data files:", tr("Customer data files:"));
  //: Button text, action to create a file
  insert("New", tr("New", "new file"));
  //: Button text, action to edit a file
  insert("Edit", tr("Edit", "edit file"));
  //: Button text, action to select a file
  insert("Set current", tr("Set current", "Set file selected currently"));
  //: Button text, action to delete a file
  insert("Delete", tr("Delete", "delete (file)"));
  insert("File name:", tr("File name:", "customerdata filename"));
  insert("Search", tr("Search", "search for customerdata files"));
  //: clears input field
  insert("Clear", tr("Clear", "clear search field"));

  insert("Really delete file <b>'%1'</b>?", tr("Really delete file <b>'%1'</b>?", "confirmation to delete customerdata file"));
  //: search customer data file via regular expression, see: https://en.wikipedia.org/wiki/Regular_expression
  insert("Regex search", tr("Regex search"));
  //: search customer data filter label
  insert("Filter:", tr("Filter:"));


  emit sigLanguageChanged();
}

QVariant ZeraTranslation::updateValue(const QString &key, const QVariant &input)
{
  Q_ASSERT(false); //do not change the values from QML
  Q_UNUSED(input)
  return value(key);
}

ZeraTranslation *ZeraTranslation::s_instance=nullptr;
