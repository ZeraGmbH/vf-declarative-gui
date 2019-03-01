pragma Singleton
import QtQuick 2.0
import ModuleIntrospection 1.0
import ZeraSettings 1.0
import ZeraTranslation 1.0

Item {
  /**
    * @b default configuration values and utility functions
    * @todo reimplement as QObject with Q_PROPERTY / Q_INVOKABLE to get QtCreator to code complete stuff...
    */

  ZeraGlobalSettings {
    id: settings
  }

  property bool tmpStatusNewErrors: false; //replacement for static variable will not be saved in settings.json

  property int pageViewLastSelectedIndex: 0;

  readonly property var locale: Qt.locale(settings.globalSettings.getOption("locale"))
  readonly property string localeName: settings.globalSettings.getOption("locale")
  onLocaleNameChanged: {
    ZTR.changeLanguage(localeName);
  }

  function setLocale(newLocale) {
    settings.globalSettings.setOption("locale", newLocale, true);
  }

  readonly property int decimalPlaces: parseInt(settings.globalSettings.getOption("digits"))
  function setDecimalPlaces(digits) {
    settings.globalSettings.setOption("digits", digits);
  }

  readonly property int showFftAsTable: parseInt(settings.globalSettings.getOption("fft_as_table"))
  function setShowFftAsTable(isTableView) {
    var setValue = isTableView ? 1 : 0;
    settings.globalSettings.setOption("fft_as_table", setValue);
  }

  readonly property int showFftTableAsRelative: parseInt(settings.globalSettings.getOption("fft_table_as_relative"))
  function setShowFftTableAsRelative(isRelative) {
    var setValue = isRelative ? 1 : 0
    settings.globalSettings.setOption("fft_table_as_relative", setValue, true);
  }

  readonly property var rangePeakVisualisationEnum: {
    "RPV_ABSOLUTE" : 0,
    "RPV_ABSOLUTE_LOGSCALE" : 1,
    "RPV_RELATIVE_TO_LIMIT" : 2
  }

  readonly property var layoutStackEnum: {
    "layoutPageIndex": 0,
    "layoutRangeIndex": 1,
    "layoutLoggerIndex": 2,
    "layoutSettingsIndex": 3,
    "layoutStatusIndex": 4
  }


  readonly property real rangePeakVisualisation: parseInt(settings.globalSettings.getOption("range_peak_logarithmic")) ///@todo rename config key?
  function setRangePeakVisualisation(rangePeakVisualisation) {
    if(typeof rangePeakVisualisation === "number"
        && rangePeakVisualisation >=0
        && rangePeakVisualisation < Object.keys(rangePeakVisualisationEnum).length)
    {
      settings.globalSettings.setOption("range_peak_logarithmic", rangePeakVisualisation);
    }
    else if(rangePeakVisualisationEnum[rangePeakVisualisation] !== undefined)
    {
      settings.globalSettings.setOption("range_peak_logarithmic", rangePeakVisualisationEnum[rangePeakVisualisation], true);
    }
  }

  readonly property bool pagesGridViewDisplay: parseInt(settings.globalSettings.getOption("pages_grid_view"))
  function setPagesGridViewDisplay(isGridView) {
    settings.globalSettings.setOption("pages_grid_view", isGridView ? 1 : 0, true);
  }

  function setSystemColorByIndex(index, color) {
    //index starts with 1 not 0
    var realIndex = index-1;
    var availableSystems = ["system1ColorDark", "system2ColorDark", "system3ColorDark", "system1Color", "system2Color", "system3Color", "system4ColorDark", "system4Color"];
    if(realIndex < availableSystems.length && color !== undefined)
    {
      settings.globalSettings.setOption(availableSystems[realIndex], color, true);
    }
  }

  readonly property color system1ColorBright: settings.globalSettings.getOption("system1Color") //"#EEff7755"
  readonly property color system1ColorDark: settings.globalSettings.getOption("system1ColorDark") // "#EEff0000"

  readonly property color system2ColorBright: settings.globalSettings.getOption("system2Color") //"#EEffffbb"
  readonly property color system2ColorDark: settings.globalSettings.getOption("system2ColorDark") //"#EEffff00"

  readonly property color system3ColorBright: settings.globalSettings.getOption("system3Color") //"#EE58acfa"
  readonly property color system3ColorDark: settings.globalSettings.getOption("system3ColorDark") //"#EE0092ff"

  readonly property color system4ColorBright: settings.globalSettings.getOption("system4Color") //"#EEffffff"
  readonly property color system4ColorDark: settings.globalSettings.getOption("system4ColorDark") //"#EEcccccc"

  readonly property color groupColorVoltage: settings.globalSettings.getOption("groupColor1") //"lightskyblue"
  readonly property color groupColorCurrent: settings.globalSettings.getOption("groupColor2") //"lawngreen"
  readonly property color groupColorReference: settings.globalSettings.getOption("groupColor3") //"darkorange"

  readonly property color tableShadeColor: "#003040"

  Timer {
    id: errorMarginSaneDefaultPropertyBindingLoopAvoidingTimer
    interval: 0
    repeat: false
    running: false
    onTriggered: {
      settings.globalSettings.setOption("errorMarginUpperValue", 10, true); //sane default
      settings.globalSettings.setOption("errorMarginLowerValue", -10, true); //sane default
    }
  }

  readonly property real errorMarginUpperValue: {
    var retVal = parseFloat(settings.globalSettings.getOption("errorMarginUpperValue"));
    if(isNaN(retVal) || isFinite(retVal) === false)
    {
      errorMarginSaneDefaultPropertyBindingLoopAvoidingTimer.start()
    }
    return retVal;
  }


  readonly property real errorMarginLowerValue: {
    var retVal = parseFloat(settings.globalSettings.getOption("errorMarginLowerValue"));
    if(isNaN(retVal) || isFinite(retVal) === false)
    {
      errorMarginSaneDefaultPropertyBindingLoopAvoidingTimer.start()
    }
    return retVal;
  }

  function formatNumber(num, decimals) {
    if(typeof num === "string") //parsing strings as number is not desired
    {
      return num;
    }
    else
    {
      var dec = decimals ? decimals : decimalPlaces
      return Number(num).toLocaleString(Qt.locale("en_US"), 'f', dec) //always use '.' as decimal separator
    }
  }

  readonly property string serverIpAddress: settings.globalSettings.getOption("modulemanagerIp");

  function systemColorByIndex(index) {
    var retVal;
    switch(index) {
    case 1:
      retVal = system1ColorDark;
      break;
    case 2:
      retVal = system2ColorDark;
      break;
    case 3:
      retVal = system3ColorDark;
      break;
    case 4:
      retVal = system1ColorBright;
      break;
    case 5:
      retVal = system2ColorBright;
      break;
    case 6:
      retVal = system3ColorBright;
      break;
    case 7:
      retVal = system4ColorDark;
      break;
    case 8:
      retVal = system4ColorBright;
      break;

    }
    return retVal;
  }

  function getColorByIndex(rangIndex, grouping) {
    var retVal;
    if(grouping)
    {
      var channelName = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+rangIndex+"Range"].ChannelName;
      var group1 = ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup1;
      var group2 = ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup2;
      var group3 = ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup3;

      if(group1 !== undefined && group1.indexOf(channelName)>-1)
      {
        retVal = groupColorVoltage
      }
      else if(group2 !== undefined && group2.indexOf(channelName)>-1)
      {
        retVal = groupColorCurrent
      }
      else if(group3 !== undefined && group3.indexOf(channelName)>-1)
      {
        retVal = groupColorReference
      }
      else //index is not in group
      {
        retVal = systemColorByIndex(rangIndex)
      }
    }
    else
    {
      retVal = systemColorByIndex(rangIndex)
    }
    return retVal;
  }

  function ceilLog10Of1DividedByX(realNumberX) {
    return Math.ceil(Math.log(1/realNumberX)/Math.LN10)
  }

  function setDefaultColors() {
    setSystemColorByIndex(1, "#EEff0000")
    setSystemColorByIndex(2, "#EEffff00")
    setSystemColorByIndex(3, "#EE0092ff")
    setSystemColorByIndex(4, "#EEff7755")
    setSystemColorByIndex(5, "#EEffffbb")
    setSystemColorByIndex(6, "#EE58acfa")
    setSystemColorByIndex(7, "#EEcccccc")
    setSystemColorByIndex(8, "#EEffffff")
  }

  function setErrorMargins(upperLimit, lowerLimit) {
    settings.globalSettings.setOption("errorMarginUpperValue", upperLimit, true);
    settings.globalSettings.setOption("errorMarginLowerValue", lowerLimit, true);
  }

  //not saved to settings
  property string currentViewName: "";
  property string currentSelectedStoragePath: "/home/operator/logger"; //default
}
