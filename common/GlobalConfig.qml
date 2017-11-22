pragma Singleton
import QtQuick 2.0
import ModuleIntrospection 1.0
import ZeraSettings 1.0

Item {

  /**
    * @b default configuration values and utility functions
    */

 ZeraGlobalSettings {
    id: settings
  }

  readonly property var locale: Qt.locale(settings.globalSettings.getOption("locale"))
  function setLocale(newLocale) {
    settings.globalSettings.setOption("locale", newLocale);
  }

  readonly property int decimalPlaces: parseInt(settings.globalSettings.getOption("digits"))
  function setDecimalPlaces(digits) {
    settings.globalSettings.setOption("digits", digits);
  }

  readonly property int showFftAsTable : parseInt(settings.globalSettings.getOption("fft_as_table"))
  function setShowFftAsTable(isTableView) {
    var setValue = isTableView ? 1 : 0;
    settings.globalSettings.setOption("fft_as_table", setValue);
  }

  readonly property bool showRangePeakAsLogAxis : parseInt(settings.globalSettings.getOption("range_peak_logarithmic"))
  function setShowRangePeakAsLogAxis(isLogarithmic) {
    var setValue = isLogarithmic ? 1 : 0;
    settings.globalSettings.setOption("range_peak_logarithmic", setValue)
  }

  function setSystemColorByIndex(index, color) {
    //index starts with 1 not 0
    var realIndex = index-1;
    var availableSystems = ["system1ColorDark", "system2ColorDark", "system3ColorDark", "system1Color", "system2Color", "system3Color"]
    if(realIndex<availableSystems.length && color !== undefined)
    {
      settings.globalSettings.setOption(availableSystems[realIndex], color);
    }
  }

  readonly property color system1ColorBright: settings.globalSettings.getOption("system1Color") //"#EEff7755"
  readonly property color system1ColorDark: settings.globalSettings.getOption("system1ColorDark") // "#EEff0000"

  readonly property color system2ColorBright: settings.globalSettings.getOption("system2Color") //"#EEffffbb"
  readonly property color system2ColorDark: settings.globalSettings.getOption("system2ColorDark") //"#EEffff00"

  readonly property color system3ColorBright: settings.globalSettings.getOption("system3Color") //"#EE58acfa"
  readonly property color system3ColorDark: settings.globalSettings.getOption("system3ColorDark") //"#EE0092ff"

  readonly property color system4ColorBright: settings.globalSettings.getOption("system4Color") //"#EEB08EF5"
  readonly property color system4ColorDark: settings.globalSettings.getOption("system4ColorDark") //"#EE6A25F6"

  readonly property color groupColorVoltage: settings.globalSettings.getOption("groupColor1") //"lightskyblue"
  readonly property color groupColorCurrent: settings.globalSettings.getOption("groupColor2") //"lawngreen"
  readonly property color groupColorReference: settings.globalSettings.getOption("groupColor3") //"darkorange"

  readonly property color tableShadeColor : "#003040"


  function formatNumber(num, decimals) {
    if(typeof num === "string") //parsing strings as number is not desired
    {
      return num;
    }
    else
    {
      var dec = decimals ? decimals : decimalPlaces
      return Number(num).toLocaleString(locale, 'f', dec)
    }
  }

  function systemColorByIndex(index) {
    var retVal
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
    }
    return retVal;
  }

  function getColorByIndex(rangIndex, grouping) {
    var retVal;
    if(grouping)
    {
      var channelName = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+rangIndex+"Range"].ChannelName;
      if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup1.indexOf(channelName)>-1)
      {
        retVal = groupColorVoltage
      }
      else if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup2.indexOf(channelName)>-1)
      {
        retVal = groupColorCurrent
      }
      else if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup3.indexOf(channelName)>-1)
      {
        retVal = groupColorReference
      }
    }
    else
    {
      retVal = systemColorByIndex(rangIndex)
    }
    return retVal;
  }
}
