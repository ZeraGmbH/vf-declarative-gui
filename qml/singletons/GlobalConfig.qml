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

  readonly property int showFftTableAsRelative: parseInt(settings.globalSettings.getOption("fft_table_as_relative"))
  function setShowFftTableAsRelative(isRelative) {
    var setValue = isRelative ? 1 : 0
    settings.globalSettings.setOption("fft_table_as_relative", setValue, true);
  }

  readonly property int showFftTablePhase: parseInt(settings.globalSettings.getOption("fft_table_show_phase"))
  function setShowFftTablePhase(showPhase) {
    var setValue = showPhase ? 1 : 0
    settings.globalSettings.setOption("fft_table_show_phase", setValue, true);
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

  readonly property double standardMargin: 0
  readonly property double standardMarginMin: 1
  readonly property double standardMarginWithMin: standardMargin > standardMarginMin ? standardMargin : standardMarginMin
  readonly property double standardTextHorizMargin: 8
  readonly property double standardTextBottomMargin: 8
  readonly property double standardComboContentScale: 1.2
  property double vkeyboardHeight: 0

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
      settings.globalSettings.setOption("auto_scale_limit", 1.0, true); //sane default
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

  readonly property real autoScaleLimit: {
    var str = settings.globalSettings.getOption("auto_scale_limit")
    if(str === "") {
      str = "1"
      errorMarginSaneDefaultPropertyBindingLoopAvoidingTimer.start()
    }
    return parseFloat(str)
  }

  // Auto scale helper functions

  /* Settings/autoScaleLimit: A float number to set at which limit the value
     changes and unit is prefixed e.g for autoScaleLimit=1.2 value >= 1200 is
     changed to 1.2k */
  function setAutoScaleLimit(limit) {
    if(typeof limit === "string") {
      settings.globalSettings.setOption("auto_scale_limit", limit, true);
    }
    else  {
      settings.globalSettings.setOption("auto_scale_limit", formatNumber(limit, 3), true);
    }
  }
  // Auto scale float value (num) / unit. Return value is an array [value,unit]
  function doAutoScale(num, strUnit) {
    // remove prefix (means calc base unit and value)
    var baseUnitInfo = getExponentAndBaseUnitFromUnit(strUnit)
    var baseValue = num * Math.pow(10, baseUnitInfo[0])
    // calc scaled value and prefixed unit on base values
    var autoScaleExponent = getAutoScaleExponent(baseValue)
    var autoScalePrefix = getPrefixFromExponent(autoScaleExponent)
    var autoScaleValue = baseValue * Math.pow(10, -autoScaleExponent)
    var autoScaleUnit = autoScalePrefix+baseUnitInfo[1]
    return [autoScaleValue, autoScaleUnit]
  }

  function getAutoScaleExponent(num) {
    var floatVal = 0.0
    if(typeof num === "string") {
      floatVal = parseFloat(num)
    }
    else {
      floatVal = num
    }
    floatVal = Math.abs(floatVal)
    var exponent = 0
    // a zero value does not get a prefix
    if(floatVal < 1e-15*autoScaleLimit)
      exponent = 0
    else if(floatVal < 1e-12*autoScaleLimit)
      exponent = -12
    else if(floatVal < 1e-9*autoScaleLimit)
      exponent = -9
    else if(floatVal < 1e-6*autoScaleLimit)
      exponent = -6
    else if(floatVal < 1e-3*autoScaleLimit)
      exponent = -3
    else if(floatVal > 1e3*autoScaleLimit)
      exponent = 3
    else if(floatVal > 1e6*autoScaleLimit)
      exponent = 6
    else if(floatVal > 1e9*autoScaleLimit)
      exponent = 9
    else if(floatVal > 1e12*autoScaleLimit)
      exponent = 12
    return exponent
  }
  function getPrefixFromExponent(exponent) {
    var str = ""
    switch(exponent) {
    case -12:
      str="p"
      break
    case -9:
      str="n"
      break
    case -6:
      str="µ"
      break
    case -3:
      str="m"
      break
    case 3:
      str="k"
      break
    case 6:
      str="M"
      break
    case 9:
      str="G"
      break
    case 12:
      str="T"
      break
    }
    return str
  }
  function getAutoScalePrefix(num) {
    var exponent = getAutoScaleExponent(num)
    return getPrefixFromExponent(exponent)
  }
  function getExponentAndBaseUnitFromUnit(strUnit) {
    var strPrefix = strUnit.substring(0,1)
    var exponent = 0
    switch(strPrefix) {
    case "p":
      exponent = -12
      break
    case "n":
      exponent = -9
      break
    case "µ":
      exponent = -6
      break
    case "m":
      exponent = -3
      break
    case "k":
      exponent = 3
      break
    case "M":
      exponent = 6
      break
    case "G":
      exponent = 9
      break
    case "T":
      exponent = 12
      break
    }
    var strNewUnit = exponent === 0 ? strUnit : strUnit.substring(1)
    return [exponent, strNewUnit]
  }

  function formatNumber(num, decimals) {
    if(typeof num === "string") //parsing strings as number is not desired
    {
      return num;
    }
    else
    {
      var dec = decimals ? decimals : decimalPlaces
      var strNum = Number(num).toLocaleString(locale, 'f', dec)
      // remove thousands separator
      strNum = strNum.replace(locale.decimalPoint === "," ? "." : ",", "")
      return strNum
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
