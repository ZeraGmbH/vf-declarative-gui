import QtQuick 2.0

Item {
  //used in VFSpinBox to set validation values from the component introspection metadata
  property real upperBound: 100;
  property real lowerBound: 0.1;
  property real stepSize: 0.1;
  property string unit;
}
