import QtQuick 2.0
import GlobalConfig 1.0

// adjust validator to locale selected
DoubleValidator {
  locale: GC.localeName
}
