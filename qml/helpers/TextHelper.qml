import QtQuick 2.0
import GlobalConfig 1.0

Item {
  function strToCLocale(str, isNumeric, isDouble) {
    if(isNumeric) {
      if(!isDouble) {
        return parseInt(str, 10)
      }
      else {
        return str.replace(",", ".")
      }
    }
    else {
      return str
    }
  }
  function strToLocal(str, isNumeric, isDouble) {
    if(isNumeric) {
      if(!isDouble) {
        return parseInt(str)
      }
      else {
        return str.replace(GC.locale.decimalPoint === "," ? "." : ",", GC.locale.decimalPoint)
      }
    }
    else {
      return str
    }
  }
  function hasAlteredValue(isNumeric, isDouble, decimals, fieldText, text) {
    var altered = false
    // Numerical?
    if(isNumeric) {
      if(fieldText !== text && (fieldText === "" || text === "")) {
        altered = true
      }
      else if(isDouble) {
        var expVal = Math.pow(10, decimals)
        var fieldVal = parseFloat(strToCLocale(fieldText, isNumeric, isDouble)) * expVal
        var textVal = parseFloat(text) * expVal
        altered = Math.abs(fieldVal-textVal) > 0.1
      }
      else {
        altered = parseInt(fieldText, 10) !== parseInt(text, 10)
      }
    }
    else {
      altered = fieldText !== text
    }
    return altered
  }

  function hasValidInput(isNumeric, isDouble, hasValidator, bottom, top, valid, text) {
    if (valid && hasValidator) {
      // IntValidator / DoubleValidator
      if(isNumeric) {
        if(isDouble) {
          // Sometimes wrong decimal separator is accepted by DoubleValidator so check for it
          if(GC.locale.decimalPoint === "," ? text.includes(".") : text.includes(",")) {
            valid = false
          }
          else {
            var floatVal = parseFloat(strToCLocale(text, isNumeric, isDouble))
            valid = top>=floatVal && bottom<=floatVal
          }
        }
        else {
          valid = top>=parseInt(text, 10) && bottom<=parseInt(text, 10)
        }
      }
      // RegExpValidator
      else {
        // TODO?
      }
    }
    return valid
  }
}
