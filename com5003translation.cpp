#include "com5003translation.h"
#include <QLocale>
#include <QFile>
#include <QApplication>
#include <QDebug>

Com5003Translation::Com5003Translation(QObject *parent) : QQmlPropertyMap(this, parent)
{

}

void Com5003Translation::setStaticInstance(Com5003Translation *t_instance)
{
  if(g_instance == nullptr)
  {
    g_instance = t_instance;
  }
}

QObject *Com5003Translation::getSingletonInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
  Q_UNUSED(t_engine);
  Q_UNUSED(t_scriptEngine);

  return g_instance;
}


void Com5003Translation::changeLanguage(const QString &t_language)
{
  if(m_currentLanguage != t_language)
  {
    m_currentLanguage = t_language;
    QLocale locale = QLocale(m_currentLanguage);
    QLocale::setDefault(locale);
    QString languageName = QLocale::languageToString(locale.language());
    const QString filename = ":/translations/com5003-gui_%1.qm"; ///@todo change to /opt/zera/com5003-gui/lang_%1.qm


    qApp->removeTranslator(&m_translator);

    if(m_translator.load(filename.arg(t_language)))
    {
      qApp->installTranslator(&m_translator);
      qDebug() << "Current Language changed to" << languageName;
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
}

void Com5003Translation::reloadStringTable()
{
  //insert("something %1", tr("something %1"))...

  //PagePathView.qml
  //: as in "close this view"
  insert("Close", tr("Close", "not open"));

  insert("Default session", tr("Default session"));
  insert("Reference session", tr("Reference session"));
  //: changing energy direction session
  insert("CED session", tr("CED session"));

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
  insert("Peak values", tr("Peak values"));
  insert("Logarithmic scale", tr("Logarithmic scale"));

  //Settings.qml
  //: settings specific to the GUI application
  insert("Application Settings", tr("Application Settings"));
  //: used for a yes / no configuration element
  insert("Display Harmonics as table:", tr("Display Harmonics as table:"));
  //: number of decimals after the decimal separator
  insert("Decimal places:", tr("Decimal places:"));
  //: settings specific to the hardware
  insert("Device settings", tr("Device settings"));
  //: measurement channel the phase locked loop uses as base
  insert("PLL channel:", tr("PLL channel:"));
  //: automatic phase locked loop channel selection
  insert("PLL channel automatic:", tr("PLL channel automatic:"));

  //SettingsInterval.qml
  /*: time based integration interval */
  insert("Integration time interval:", tr("Integration time interval:"));
  /*: measurement period based integration interval */
  insert("Integration period interval:", tr("Integration period interval:"));

  //main.qml
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
  insert("Started", tr("Started"));
  //: like finished
  insert("Ready", tr("Ready"));
  insert("Aborted", tr("Aborted"));
  insert("Result:", tr("Result:"));
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

  //FftModulePage.qml
  //: text must be short enough to fit
  insert("Amp", tr("Amp", "Amplitude of the phasor"));
  //: text must be short enough to fit
  insert("Phase", tr("Phase","Phase of the phasor"));

  //MeasurementPageModel.qml
  //: polar (amplitude and phase) phasor diagram
  insert("Vector diagram", tr("Vector diagram"));
  insert("Actual values", tr("Actual values"));
  insert("Oscilloscope plot", tr("Oscilloscope plot"));
  //: FFT bar diagrams or tables that show the harmonic component distribution of the measured values
  insert("Harmonics", tr("Harmonics"));
  //: measuring mode dependent power values
  insert("Power values", tr("Power values"));
  //: FFT tables that show the real and imaginary parts of the measured power values
  insert("Harmonic power values", tr("Harmonic power values"));
  //: shows the deviation of measured energy between the reference device and the device under test
  insert("Error calculator", tr("Error calculator"));

  //BurdenModulePage.qml
  insert("Voltage-Burden", tr("Voltage-Burden"));
  insert("Current-Burden", tr("Current-Burden"));
  insert("Burden values", tr("Burden values"));
  insert("Nominal burden:", tr("Nominal burden:"));
  insert("Nominal range:", tr("Nominal range:"));
  insert("Wire crosssection:", tr("Wire crosssection:"));
  insert("Wire length:", tr("Wire length:"));

  //ReferencePageModel.qml
  insert("Reference values", tr("Reference values"));

  //CEDPageModel.qml
  insert("CED power values", tr("CED power values"));

  //HarmonicPowerModulePage.qml
  insert("Real", tr("Real", "complex number part"));
  insert("Imaginary", tr("Imaginary", "complex number part"));

  //TransformerModulePage.qml
  insert("X-Prim:", tr("X-Prim:"));
  insert("X-Sec:", tr("X-Sec:"));
  insert("Ms-Prim:", tr("Ms-Prim:"));
  insert("Ms-Sec:", tr("Ms-Sec:"));
  insert("Mp-Prim:", tr("Mp-Prim:"));
  insert("Mp-Sec:", tr("Mp-Sec:"));
  insert("crad", tr("crad", "centiradian"));
  insert("arcmin", tr("arcmin", "arcminute"));

  //Zera Classes -> zera-basemodule -> errormessages.h
  //: RESMAN = resource manager
  insert("RESMAN ident error", tr("RESMAN ident error"));
  insert("RESMAN resourcetype not avail", tr("RESMAN resourcetype not avail"));
  insert("RESMAN resource not avail", tr("RESMAN resource not avail"));
  insert("RESMAN resource Info error", tr("RESMAN resource Info error"));
  insert("RESMAN set resource failed", tr("RESMAN set resource failed"));
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
  insert("PCB read offset correction failed", tr("PCB read offset correction failed"));
  insert("PCB read phase correction failed", tr("PCB read phase correction failed"));
  insert("PCB read channel status failed", tr("PCB read channel status failed"));
  insert("PCB reset channel status failed", tr("PCB reset channel status failed"));
  insert("PCB formfactor read failed", tr("PCB formfactor read failed"));
  insert("PCB register notifier failed", tr("PCB register notifier failed"));
  insert("PCB unregister notifier failed", tr("PCB unregister notifier failed"));
  insert("PCB set pll failed", tr("PCB set pll failed"));
  insert("PCB muxchannel read failed", tr("PCB muxchannel read failed"));
  insert("PCB reference constant read failed", tr("PCB reference constant read failed"));
  insert("PCB adjustment status read failed", tr("PCB adjustment status read failed"));
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
  //: SEC = standard error calculator
  insert("SEC fetch ecalculator failed", tr("SEC fetch ecalculator failed"));
  insert("SEC free ecalculator failed", tr("SEC free ecalculator failed"));
  insert("SEC read register failed", tr("SEC read register failed"));
  insert("SEC write register failed", tr("SEC write register failed"));
  insert("SEC set sync failed", tr("SEC set sync failed"));
  insert("SEC set mux failed", tr("SEC set mux failed"));
  insert("SEC set cmdid failed", tr("SEC set cmdid failed"));
  insert("SEC stop measure failed", tr("SEC stop measure failed"));
  insert("Interface JSON Document strange", tr("Interface JSON Document strange"));
  insert("Ethernet interface listen failed", tr("Ethernet interface listen failed"));
  insert("Serial interface not connected", tr("Serial interface not connected"));

  insert("System started", tr("System started"));

  //StatusView.qml
  insert("Device info", tr("Device info"));
  insert("Serial number:", tr("Serial number:"));
  insert("Operating system version:", tr("Operating system version:"));
  insert("PCB server version:", tr("PCB server version:"));
  insert("DSP server version:", tr("DSP server version:"));
  insert("DSP firmware version:", tr("DSP firmware version:"));
  insert("FPGA firmware version:", tr("FPGA firmware version:"));
  insert("Microcontroller firmware version:", tr("Microcontroller firmware version:"));
  insert("Adjustment status:", tr("Adjustment status:"));
  insert("Adjustment checksum:", tr("Adjustment checksum:"));

  //Notifications.qml
  insert("Device notifications", tr("Device notifications"));

}

QVariant Com5003Translation::updateValue(const QString &key, const QVariant &input)
{
  Q_ASSERT(false); //do not change the values from QML
  Q_UNUSED(input);
  return value(key);
}

Com5003Translation *Com5003Translation::g_instance=nullptr;
