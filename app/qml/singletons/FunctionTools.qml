pragma Singleton
import QtQuick 2.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import MeasChannelInfo 1.0
import ZeraLocale 1.0

Item {
    /////////////////////////////////////////////////////////////////////////////
    // Color helper function
    function getColorByIndex(rangIndex, grouping) {
        if(grouping) {
            let channelName = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+rangIndex+"Range"].ChannelName;
            if(MeasChannelInfo.rangeGroupVoltage.indexOf(channelName) >= 0)
                return GC.groupColorVoltage
            if(MeasChannelInfo.rangeGroupCurrent.indexOf(channelName) >= 0)
                return GC.groupColorCurrent
            if(MeasChannelInfo.rangeGroupRef.indexOf(channelName) >= 0)
                return GC.groupColorReference
        }
        return GC.currentColorTable[rangIndex-1]
    }
    function gradientColor(color0, color1, zeroOneVal) {
        let red = (1-zeroOneVal)*color0.r + zeroOneVal*color1.r
        if(red > 1)
            red = 1
        let green = (1-zeroOneVal)*color0.g + zeroOneVal*color1.g
        if(green > 1)
            green = 1
        let blue = (1-zeroOneVal)*color0.b + zeroOneVal*color1.b
        if(blue > 1)
            blue = 1
        let alpha = (1-zeroOneVal)*color0.a + zeroOneVal*color1.a
        if(alpha > 1)
            alpha = 1
        return Qt.rgba(red, green, blue, alpha)
    }

    /////////////////////////////////////////////////////////////////////////////
    // Time helpers ms <-> string
    function msToTime(t_mSeconds) {
        if(t_mSeconds === undefined) {
            t_mSeconds = 0
        }
        var ms = t_mSeconds % 1000
        t_mSeconds = (t_mSeconds - ms) / 1000
        var secs = t_mSeconds % 60;
        t_mSeconds = (t_mSeconds - secs) / 60
        var mins = t_mSeconds % 60;
        var hours = (t_mSeconds - mins) / 60;
        return ("0"+hours).slice(-2) + ':' + ("0"+mins).slice(-2) + ':' + ("0"+secs).slice(-2);// + '.' + ("00"+ms).slice(-3);
    }
    function timeToMs(t_time) {
        var mSeconds = 0;
        var timeData = [];

        if((String(t_time).match(/:/g) || []).length === 2) {
            timeData = t_time.split(':');
            var hours = Number(timeData[0]);
            mSeconds += hours * 3600000;
            var minutes = Number(timeData[1]);
            mSeconds += minutes * 60000;
            var seconds = Number(timeData[2]);
            mSeconds += seconds * 1000;
        }
        return Number(mSeconds);
    }

    /////////////////////////////////////////////////////////////////////////////
    // Auto scale helper functions
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
        if(floatVal < 1e-15*GC.autoScaleLimit) {
            exponent = 0
        }
        else if(floatVal < 1e-12*GC.autoScaleLimit) {
            exponent = -12
        }
        else if(floatVal < 1e-9*GC.autoScaleLimit) {
            exponent = -9
        }
        else if(floatVal < 1e-6*GC.autoScaleLimit) {
            exponent = -6
        }
        else if(floatVal < 1e-3*GC.autoScaleLimit) {
            exponent = -3
        }
        else if(floatVal > 1e12*GC.autoScaleLimit) {
            exponent = 12
        }
        else if(floatVal > 1e9*GC.autoScaleLimit) {
            exponent = 9
        }
        else if(floatVal > 1e6*GC.autoScaleLimit) {
            exponent = 6
        }
        else if(floatVal > 1e3*GC.autoScaleLimit) {
            exponent = 3
        }
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

    /////////////////////////////////////////////////////////////////////////////
    // Number <-> String conversion helpers
    function ceilLog10Of1DividedByX(realNumberX) {
        return Math.ceil(Math.log(1/realNumberX)/Math.LN10)
    }

    function removeDecimalGroupSeparators(strNum) {
        // remove group separators (this is ugly but don't get documented examples to fly here...)
        let groupSepChar = ZLocale.decimalPoint === "," ? "." : ","
        while(strNum.includes(groupSepChar))
            strNum = strNum.replace(groupSepChar, "")
        return strNum
    }

    function formatNumber(num) {
        return formatNumberParam(num, GC.digitsTotal, GC.decimalPlaces)
    }
    function formatNumberForScaledValues(num) {
        return formatNumberParamForScaledValues(num, GC.digitsTotal, GC.decimalPlaces)
    }
    function formatNumberParamForScaledValues(num, _digitsTotal, _decimalPlaces) {
        if(num === undefined)
            return ""
        if(typeof num === "string") //parsing strings as number is not desired
            return num;
        if(isNaN(num))
            return "----";
        let dec = _decimalPlaces
        let leadDigits = Math.floor(Math.abs(num)).toString()
        // leading zero is not a digit
        if(leadDigits === '0')
            leadDigits  = ''
        let preDecimals = leadDigits.length
        if(dec + preDecimals > _digitsTotal) {
            dec = _digitsTotal - preDecimals
            if(dec < 0)
                dec = 0
        }
        return Number(num).toLocaleString(ZLocale.locale, 'f', dec)
    }
    function formatNumberParam(num, _digitsTotal, _decimalPlaces) {
        let formatted = formatNumberParamForScaledValues(num, _digitsTotal, _decimalPlaces)
        return removeDecimalGroupSeparators(formatted)
    }
    function formatNumberCLocale(num, decimalPlacesSet) {
        return formatNumberParamForScaledValues(num, GC.digitsTotal, decimalPlacesSet).replace(",", ".")
    }

}
